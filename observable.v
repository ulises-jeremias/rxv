module rxv

import context
import time

// ObservableImpl[T] is the primary reactive stream type.
//
// DESIGN NOTE — why `chan Item[T]` not `Iterable[T]`:
// V's generic codegen has a bug where assigning to an interface field
// inside a generic function cross-contaminates specializations. Using a
// concrete `chan Item[T]` avoids that.
//
// DESIGN NOTE — why try_pop not select:
// V's select codegen for generic channels allocates the receive-buffer
// with the wrong type when multiple specializations of the same function
// coexist in the same translation unit. try_pop bypasses that.
//
// DESIGN NOTE — for_each and channel-capture pattern:
// V closures capture arrays by copy, not by reference. The workaround:
// 1. User closures capture a `chan T` (results_ch) instead of `[]T`
// 2. main thread drains bridge channel, calling user next_fn on each value
// 3. completed_fn is called after drain
// 4. for_each returns the signal channel
//
// User code receives results by draining results_ch into a local array AFTER
// <-for_each_signal completes. Example:
//    done := obs.for_each(fn [mut results] (v) { results <- v }, ...)
//    <-done
//    for { v := <-results_ch; if closed {break} else { arr << v } }
@[heap]
pub struct ObservableImpl[T] {
mut:
	ch     chan Item[T]
	parent context.Context
}

pub fn (o ObservableImpl[T]) str() string {
	return 'Observable[T]'
}

pub fn (mut o ObservableImpl[T]) observe(opts ...RxOption) chan Item[T] {
	return o.ch
}

const poll_sleep = 10 * time.microsecond

// ---- filter -----------------------------------------------------------------

fn obs_filter_run[T](predicate PredicateFn[T], done chan int, src chan Item[T], next chan Item[T]) {
	for {
		mut dv := int(0)
		ds := done.try_pop(mut dv)
		if ds == .success || ds == .closed {
			break
		}
		mut item := Item[T]{ has_value: false, err: none }
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				item.send_context(done, next)
				break
			}
			if item.has_value && predicate(item.get_value()) {
				item.send_context(done, next)
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	if !next.closed {
		next.close()
	}
}

pub fn (mut o ObservableImpl[T]) filter(predicate PredicateFn[T], opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	mut ctx := option.build_context(o.parent)
	done := ctx.done()
	src := o.ch
	spawn obs_filter_run[T](predicate, done, src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

// ---- take -------------------------------------------------------------------

fn obs_take_run[T](n u32, done chan int, src chan Item[T], next chan Item[T]) {
	mut count := u32(0)
	for count < n {
		mut dv := int(0)
		ds := done.try_pop(mut dv)
		if ds == .success || ds == .closed {
			break
		}
		mut item := Item[T]{ has_value: false, err: none }
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				item.send_context(done, next)
				break
			}
			item.send_context(done, next)
			count++
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	if !next.closed {
		next.close()
	}
}

pub fn (mut o ObservableImpl[T]) take(n u32, opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	mut ctx := option.build_context(o.parent)
	done := ctx.done()
	src := o.ch
	spawn obs_take_run[T](n, done, src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

// ---- for_each ---------------------------------------------------------------
// User closures capture a results channel (chan T), NOT a []T array.
// Call site pattern:
//    results_ch := chan T{cap: 10}
//    done := obs.for_each(
//        fn [results_ch] (v T) { results_ch <- v },
//        fn (err IError) { ... },
//        fn () { results_ch.close() },
//    )
//    <-done
//    // Drain results_ch into your array

fn obs_for_each_bridge[T](bridge chan T, done chan int, src chan Item[T], signal chan int) {
	for {
		mut item := Item[T]{ has_value: false, err: none }
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				break
			}
			if item.has_value {
				bridge <- item.get_value()
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	bridge.close()
	signal <- 0
	signal.close()
}

pub fn (mut o ObservableImpl[T]) for_each(next_fn NextFn[T], err_fn ErrFn, completed_fn CompletedFn, opts ...RxOption) chan int {
	mut option := parse_options(...opts)
	mut ctx := option.build_context(o.parent)
	done := ctx.done()
	src := o.ch
	signal := chan int{cap: 1}

	// Bridge channel carries plain T values from spawned worker
	bridge := chan T{cap: option.buffer_size}
	spawn obs_for_each_bridge[T](bridge, done, src, signal)

	// Drive the loop on the main thread so user closures run on the main thread.
	for {
		mut v := T{}
		s := bridge.try_pop(mut v)
		if s == .success {
			next_fn(v)
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}

	completed_fn()
	return signal
}

// ---- map_ (free function, changes type parameter) ---------------------------
// NOTE: map_ is a free function because method receivers cannot change type
// parameters in V.

fn obs_map_run[T, U](apply MapFn[T, U], done chan int, src chan Item[T], next chan Item[U]) {
	for {
		mut dv := int(0)
		ds := done.try_pop(mut dv)
		if ds == .success || ds == .closed {
			break
		}
		mut item := Item[T]{ has_value: false, err: none }
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				from_error[U](item.err).send_context(done, next)
				break
			}
			if item.has_value {
				result := apply(item.get_value()) or {
					from_error[U](err).send_context(done, next)
					break
				}
				of[U](result).send_context(done, next)
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	if !next.closed {
		next.close()
	}
}

pub fn map_[T, U](mut o ObservableImpl[T], apply MapFn[T, U], opts ...RxOption) &ObservableImpl[U] {
	mut option := parse_options(...opts)
	next := chan Item[U]{cap: option.buffer_size}
	mut bg := context.background()
	done := bg.done()
	src := o.ch
	spawn obs_map_run[T, U](apply, done, src, next)
	return &ObservableImpl[U]{
		ch:     next
		parent: bg
	}
}
