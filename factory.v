module rxv

import context
import time

// just emits each provided value then completes.
pub fn just[T](items ...T) &ObservableImpl[T] {
	mut iter := new_slice_iterable[T](items)
	ch := iter.observe()
	return &ObservableImpl[T]{
		ch:     ch
		parent: context.background()
	}
}

// from_channel wraps an existing channel as an ObservableImpl.
pub fn from_channel[T](ch chan Item[T]) &ObservableImpl[T] {
	return &ObservableImpl[T]{
		ch:     ch
		parent: context.background()
	}
}

// from_slice emits each element of a slice then completes.
fn slice_items_emit[T](items []T, ch chan Item[T]) {
	for v in items {
		ch <- of[T](v)
	}
	ch.close()
}

pub fn from_slice[T](items []T) &ObservableImpl[T] {
	ch := chan Item[T]{cap: items.len + 1}
	spawn slice_items_emit[T](items.clone(), ch)
	return &ObservableImpl[T]{
		ch:     ch
		parent: context.background()
	}
}

// create builds an ObservableImpl from a producer function.
pub fn create[T](producer ProducerFn[T]) &ObservableImpl[T] {
	mut iter := new_create_iterable[T](producer)
	ch := iter.observe()
	return &ObservableImpl[T]{
		ch:     ch
		parent: context.background()
	}
}

// empty completes immediately without emitting any item.
pub fn empty[T]() &ObservableImpl[T] {
	ch := chan Item[T]{cap: 1}
	ch.close()
	return &ObservableImpl[T]{
		ch:     ch
		parent: context.background()
	}
}

// throw emits a single error then completes.
pub fn throw[T](err IError) &ObservableImpl[T] {
	ch := chan Item[T]{cap: 1}
	ch <- from_error[T](err)
	ch.close()
	return &ObservableImpl[T]{
		ch:     ch
		parent: context.background()
	}
}

// range emits integers in [start, start+count).
pub fn range(start int, count int) &ObservableImpl[int] {
	return from_slice[int]([]int{len: count, init: start + index})
}

// repeat emits the same value `count` times.
pub fn repeat[T](value T, count int) &ObservableImpl[T] {
	items := []T{len: count, init: value}
	return from_slice[T](items)
}

// defer_ evaluates the factory lazily on each subscribe.
fn defer_producer_run[T](factory fn () &ObservableImpl[T], done chan int, ch chan Item[T]) {
	mut obs := factory()
	src := obs.observe()
	for {
		mut dv := int(0)
		ds := done.try_pop(mut dv)
		if ds == .success || ds == .closed {
			break
		}
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			item.send_context(done, ch)
		} else if s == .closed {
			break
		} else {
			time.sleep(10 * time.microsecond)
		}
	}
}

pub fn defer_[T](factory fn () &ObservableImpl[T]) &ObservableImpl[T] {
	producer := fn [factory] (mut ctx context.Context, ch chan Item[T]) {
		done := ctx.done()
		defer_producer_run[T](factory, done, ch)
	}
	return create[T](ProducerFn[T](producer))
}

// interval_emit is a named helper for spawn in interval.
fn interval_emit(period_ms int, ch chan Item[int]) {
	mut count := 0
	for {
		time.sleep(time.millisecond * period_ms)
		ch <- of[int](count)
		count++
	}
}

// interval emits sequential integers starting at 0 at each `period_ms` milliseconds.
// The returned observable never completes — use take() to limit emissions.
pub fn interval(period_ms int) &ObservableImpl[int] {
	ch := chan Item[int]{cap: 8}
	spawn interval_emit(period_ms, ch)
	return &ObservableImpl[int]{
		ch:     ch
		parent: context.background()
	}
}

// timer_emit is a named helper for spawn in timer.
fn timer_emit(delay_ms int, ch chan Item[int]) {
	time.sleep(time.millisecond * delay_ms)
	ch <- of[int](0)
	ch.close()
}

// timer emits a single 0 after `delay_ms` milliseconds, then completes.
pub fn timer(delay_ms int) &ObservableImpl[int] {
	ch := chan Item[int]{cap: 1}
	spawn timer_emit(delay_ms, ch)
	return &ObservableImpl[int]{
		ch:     ch
		parent: context.background()
	}
}
