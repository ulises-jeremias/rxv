module rxv

import context
import time

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

// ---- filter ----------------------------------------------------------------

fn obs_filter_run[T](predicate PredicateFn[T], src chan Item[T], next chan Item[T]) {
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- item
				break
			}
			if item.has_value && predicate(item.get_value()) {
				next <- item
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

pub fn (mut o ObservableImpl[T]) filter(predicate PredicateFn[T], opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	src := o.ch
	spawn obs_filter_run[T](predicate, src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

// ---- take -----------------------------------------------------------------

fn obs_take_run[T](n u32, src chan Item[T], next chan Item[T]) {
	mut count := u32(0)
	for count < n {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			next <- item
			count++
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

pub fn (mut o ObservableImpl[T]) take(n u32, opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	src := o.ch
	spawn obs_take_run[T](n, src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

// ---- for_each -------------------------------------------------------------

fn obs_for_each_bridge[T](bridge chan T, src chan Item[T], signal chan int) {
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
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
	src := o.ch
	signal := chan int{cap: 1}

	bridge := chan T{cap: option.buffer_size}
	spawn obs_for_each_bridge[T](bridge, src, signal)

	for {
		mut v := T{}
		sv := bridge.try_pop(mut v)
		if sv == .success {
			next_fn(v)
		} else if sv == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}

	completed_fn()
	return signal
}

// ---- map ------------------------------------------------------------------
// NOTE: map_ is a free function (not a method) because V 0.5.x does not
// support methods with additional type parameters beyond the receiver's T.

fn obs_map_run[T, U](apply MapFn[T, U], src chan Item[T], next chan Item[U]) {
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- from_error[U](item.err)
				continue
			}
			if item.has_value {
				result := apply(item.get_value()) or {
					next <- from_error[U](err)
					continue
				}
				next <- of[U](result)
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

pub fn map_[T, U](mut o ObservableImpl[T], apply MapFn[T, U], opts ...RxOption) &ObservableImpl[U] {
	mut option := parse_options(...opts)
	next := chan Item[U]{cap: option.buffer_size}
	src := o.ch
	spawn obs_map_run[T, U](apply, src, next)
	return &ObservableImpl[U]{
		ch:     next
		parent: o.parent
	}
}

// ---- scan -----------------------------------------------------------------
// Free function — see map_ note above.

fn obs_scan_run[T, U](seed U, accumulator fn (acc U, val T) U, src chan Item[T], next chan Item[U]) {
	mut acc := seed
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- from_error[U](item.err)
				continue
			}
			if item.has_value {
				acc = accumulator(acc, item.get_value())
				next <- of[U](acc)
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// scan_ applies an accumulator over the stream, emitting each intermediate result.
pub fn scan_[T, U](mut o ObservableImpl[T], seed U, accumulator fn (acc U, val T) U, opts ...RxOption) &ObservableImpl[U] {
	mut option := parse_options(...opts)
	next := chan Item[U]{cap: option.buffer_size}
	src := o.ch
	spawn obs_scan_run[T, U](seed, accumulator, src, next)
	return &ObservableImpl[U]{
		ch:     next
		parent: o.parent
	}
}

// ---- reduce ---------------------------------------------------------------
// Free function — see map_ note above.

fn obs_reduce_run[T, U](seed U, accumulator fn (acc U, val T) U, src chan Item[T], next chan Item[U]) {
	mut acc := seed
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- from_error[U](item.err)
				break
			}
			if item.has_value {
				acc = accumulator(acc, item.get_value())
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next <- of[U](acc)
	next.close()
}

// reduce_ applies an accumulator over the entire stream, emitting only the final value.
pub fn reduce_[T, U](mut o ObservableImpl[T], seed U, accumulator fn (acc U, val T) U, opts ...RxOption) &ObservableImpl[U] {
	mut option := parse_options(...opts)
	next := chan Item[U]{cap: option.buffer_size}
	src := o.ch
	spawn obs_reduce_run[T, U](seed, accumulator, src, next)
	return &ObservableImpl[U]{
		ch:     next
		parent: o.parent
	}
}

// ---- count ----------------------------------------------------------------

fn obs_count_run[T](src chan Item[T], next chan Item[int]) {
	mut n := 0
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- from_error[int](item.err)
				break
			}
			if item.has_value {
				n++
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next <- of[int](n)
	next.close()
}

// count_ returns an Observable emitting the number of items emitted by the source.
pub fn count_[T](mut o ObservableImpl[T], opts ...RxOption) &ObservableImpl[int] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[int]()
	src := o.ch
	spawn obs_count_run[T](src, next)
	return &ObservableImpl[int]{
		ch:     next
		parent: o.parent
	}
}

// ---- distinct --------------------------------------------------------------

fn obs_distinct_run[T](src chan Item[T], next chan Item[T]) {
	mut seen := map[string]bool{}
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- item
				break
			}
			if item.has_value {
				key := '${item.get_value()}'
				if !seen[key] {
					seen[key] = true
					next <- item
				}
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// distinct suppresses duplicate items, emitting only items not previously seen.
pub fn (mut o ObservableImpl[T]) distinct(opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	src := o.ch
	spawn obs_distinct_run[T](src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

// ---- distinct_until_changed -----------------------------------------------

fn obs_distinct_until_changed_run[T](src chan Item[T], next chan Item[T]) {
	mut has_prev := false
	mut prev := T{}
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- item
				break
			}
			if item.has_value {
				val := item.get_value()
				if !has_prev || prev != val {
					unsafe {
						prev = val
					}
					has_prev = true
					next <- item
				}
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// distinct_until_changed suppresses consecutive duplicate items.
pub fn (mut o ObservableImpl[T]) distinct_until_changed(opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	src := o.ch
	spawn obs_distinct_until_changed_run[T](src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

// ---- first / last --------------------------------------------------------

fn obs_first_run[T](src chan Item[T], next chan Item[T]) {
	mut found := false
	for !found {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- item
				break
			}
			if item.has_value {
				next <- item
				found = true
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// first emits only the first item from the source.
pub fn (mut o ObservableImpl[T]) first(opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	src := o.ch
	spawn obs_first_run[T](src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

fn obs_last_run[T](src chan Item[T], next chan Item[T]) {
	mut last := Item[T]{
		has_value: false
		err:       none
	}
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- item
				break
			}
			if item.has_value {
				last = item
			}
		} else if s == .closed {
			if last.has_value {
				next <- last
			}
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// last emits only the last item from the source.
pub fn (mut o ObservableImpl[T]) last(opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	src := o.ch
	spawn obs_last_run[T](src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

// ---- skip ----------------------------------------------------------------

fn obs_skip_run[T](n u32, src chan Item[T], next chan Item[T]) {
	mut skipped := u32(0)
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- item
				break
			}
			if item.has_value {
				if skipped < n {
					skipped++
				} else {
					next <- item
				}
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// skip suppresses the first n items emitted by the source.
pub fn (mut o ObservableImpl[T]) skip(n u32, opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	src := o.ch
	spawn obs_skip_run[T](n, src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

// ---- take_last -----------------------------------------------------------

fn obs_take_last_run[T](n u32, src chan Item[T], next chan Item[T]) {
	mut window := []Item[T]{}
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- item
				break
			}
			if item.has_value {
				window << item
				if window.len > int(n) {
					window.delete(0)
				}
			}
		} else if s == .closed {
			for i in 0 .. window.len {
				next <- window[i]
			}
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// take_last emits only the last n items from the source.
pub fn (mut o ObservableImpl[T]) take_last(n u32, opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	src := o.ch
	spawn obs_take_last_run[T](n, src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

// ---- contains -------------------------------------------------------------

fn obs_contains_run[T](pred PredicateFn[T], src chan Item[T], next chan Item[bool]) {
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- of[bool](false)
				break
			}
			if item.has_value && pred(item.get_value()) {
				next <- of[bool](true)
				break
			}
		} else if s == .closed {
			next <- of[bool](false)
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// contains returns true if the source emits an item that satisfies the predicate.
pub fn (mut o ObservableImpl[T]) contains(pred PredicateFn[T], opts ...RxOption) &ObservableImpl[bool] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[bool]()
	src := o.ch
	spawn obs_contains_run[T](pred, src, next)
	return &ObservableImpl[bool]{
		ch:     next
		parent: o.parent
	}
}

// ---- is_empty -------------------------------------------------------------

fn obs_is_empty_run[T](src chan Item[T], next chan Item[bool]) {
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- of[bool](false)
				break
			}
			if item.has_value {
				next <- of[bool](false)
				break
			}
		} else if s == .closed {
			next <- of[bool](true)
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// is_empty returns true if the source Observable completes without emitting any item.
pub fn (mut o ObservableImpl[T]) is_empty(opts ...RxOption) &ObservableImpl[bool] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[bool]()
	src := o.ch
	spawn obs_is_empty_run[T](src, next)
	return &ObservableImpl[bool]{
		ch:     next
		parent: o.parent
	}
}

// ---- element_at -----------------------------------------------------------

fn obs_element_at_run[T](index u32, src chan Item[T], next chan Item[T]) {
	mut idx := u32(0)
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- item
				break
			}
			if item.has_value {
				if idx == index {
					next <- item
					break
				}
				idx++
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// element_at returns the item at the specified index or errors if out of bounds.
pub fn (mut o ObservableImpl[T]) element_at(index u32, opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	src := o.ch
	spawn obs_element_at_run[T](index, src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

// ---- all -----------------------------------------------------------------

fn obs_all_run[T](pred PredicateFn[T], src chan Item[T], next chan Item[bool]) {
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- of[bool](false)
				break
			}
			if item.has_value && !pred(item.get_value()) {
				next <- of[bool](false)
				break
			}
		} else if s == .closed {
			next <- of[bool](true)
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// all returns true if all items satisfy the predicate.
pub fn (mut o ObservableImpl[T]) all(pred PredicateFn[T], opts ...RxOption) &ObservableImpl[bool] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[bool]()
	src := o.ch
	spawn obs_all_run[T](pred, src, next)
	return &ObservableImpl[bool]{
		ch:     next
		parent: o.parent
	}
}

// ---- any -----------------------------------------------------------------

fn obs_any_run[T](pred PredicateFn[T], src chan Item[T], next chan Item[bool]) {
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- of[bool](false)
				break
			}
			if item.has_value && pred(item.get_value()) {
				next <- of[bool](true)
				break
			}
		} else if s == .closed {
			next <- of[bool](false)
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// any returns true if at least one item satisfies the predicate.
pub fn (mut o ObservableImpl[T]) any(pred PredicateFn[T], opts ...RxOption) &ObservableImpl[bool] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[bool]()
	src := o.ch
	spawn obs_any_run[T](pred, src, next)
	return &ObservableImpl[bool]{
		ch:     next
		parent: o.parent
	}
}

// ---- find ----------------------------------------------------------------

fn obs_find_run[T](pred PredicateFn[T], src chan Item[T], next chan Item[T]) {
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- item
				break
			}
			if item.has_value && pred(item.get_value()) {
				next <- item
				break
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// find returns the first item that satisfies the predicate.
pub fn (mut o ObservableImpl[T]) find(pred PredicateFn[T], opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	src := o.ch
	spawn obs_find_run[T](pred, src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

// ---- timeout --------------------------------------------------------------
// NOTE: timeout_ms granularity is ~10µs poll intervals.
// A value of 0 disables the timeout.

fn obs_timeout_run[T](timeout_ms int, src chan Item[T], next chan Item[T]) {
	mut elapsed_us := i64(0)
	limit_us := i64(timeout_ms) * 1000
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			elapsed_us = 0
			next <- item
			if item.is_error() {
				break
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
			elapsed_us += i64(poll_sleep / time.microsecond)
			if limit_us > 0 && elapsed_us >= limit_us {
				next <- from_error[T](error('timeout after ${timeout_ms}ms'))
				break
			}
		}
	}
	next.close()
}

// timeout emits an error if no item is received within `timeout_ms` milliseconds.
pub fn (mut o ObservableImpl[T]) timeout(timeout_ms int, opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	src := o.ch
	spawn obs_timeout_run[T](timeout_ms, src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

// debounce emits an item only after the specified delay has passed without any other item.
pub fn debounce_[T](mut o ObservableImpl[T], delay_ms int, opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	src := o.ch
	debounce[T](delay_ms, src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

fn debounce[T](delay_ms int, src chan Item[T], next chan Item[T]) {
	spawn debounce_inner[T](delay_ms, src, next)
}

fn debounce_inner[T](delay_ms int, src chan Item[T], next chan Item[T]) {
	mut last_item := Item[T]{
		has_value: false
		err:       none
	}
	mut has_last := false
	mut timer_started := false
	mut timer_start_time := i64(0)
	for {
		if has_last && timer_started {
			elapsed := time.now().unix_offset() * 1_000 - timer_start_time
			if elapsed >= i64(delay_ms) * 1_000 {
				next <- last_item
				has_last = false
				timer_started = false
			}
		}
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- item
				break
			}
			if item.has_value {
				last_item = item
				has_last = true
				timer_started = true
				timer_start_time = time.now().unix_offset() * 1_000
			}
		} else if s == .closed {
			if has_last {
				next <- last_item
			}
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// ---- sample ---------------------------------------------------------------
pub fn buffer_[T](mut o ObservableImpl[T], count u32, opts ...RxOption) &ObservableImpl[[]T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[[]T]()
	src := o.ch
	spawn buffer_count_worker(count, src, next)
	return &ObservableImpl[[]T]{
		ch:     next
		parent: o.parent
	}
}

fn buffer_count_worker[U](count u32, src chan Item[U], next chan Item[[]U]) {
	mut buf := []U{}
	for {
		mut item := Item[U]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				if buf.len > 0 {
					next <- of[[]U](buf)
				}
				next <- item
				break
			}
			if item.has_value {
				buf << item.get_value()
				if u32(buf.len) >= count {
					next <- of[[]U](buf)
					buf = []U{}
				}
			}
		} else if s == .closed {
			if buf.len > 0 {
				next <- of[[]U](buf)
			}
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// ---- sample ---------------------------------------------------------------

fn sample_[T](period_ms int, src chan Item[T], next chan Item[T]) {
	spawn sample_worker[T](period_ms, src, next)
}

fn sample_worker[T](period_ms int, src chan Item[T], next chan Item[T]) {
	mut last_item := Item[T]{
		has_value: false
		err:       none
	}
	mut has_last := false
	mut last_sent_time := i64(0)
	mut period_us := i64(period_ms) * 1000
	for {
		now := time.now().unix_offset() * 1_000_000
		if has_last && (now - last_sent_time) >= period_us {
			next <- last_item
			last_sent_time = now
			has_last = false
		}
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- item
				break
			}
			if item.has_value {
				last_item = item
				has_last = true
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// sample emits the most recent item at the specified periodic interval.
pub fn sample[T](mut o ObservableImpl[T], period_ms int, opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	src := o.ch
	sample_[T](period_ms, src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

// throttle_first emits the first item, then ignores subsequent items until delay expires.
pub fn throttle_first_[T](mut o ObservableImpl[T], delay_ms int, opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	src := o.ch
	throttle_first[T](delay_ms, src, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}

fn throttle_first[T](delay_ms int, src chan Item[T], next chan Item[T]) {
	spawn throttle_first_worker[T](delay_ms, src, next)
}

fn throttle_first_worker[T](delay_ms int, src chan Item[T], next chan Item[T]) {
	mut blocked := false
	mut block_start := i64(0)
	mut blocked_duration := i64(delay_ms) * 1_000_000
	for {
		if blocked {
			elapsed := time.now().unix_offset() * 1_000_000 - block_start
			if elapsed >= blocked_duration {
				blocked = false
			}
		}
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- item
				break
			}
			if item.has_value && !blocked {
				next <- item
				blocked = true
				block_start = time.now().unix_offset() * 1_000_000
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// ---- buffer_with_time ----------------------------------------------------

// buffer_with_time collects items into a buffer and emits it every `period_ms` ms.
pub fn buffer_time_[T](mut o ObservableImpl[T], period_ms int, opts ...RxOption) &ObservableImpl[[]T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[[]T]()
	src := o.ch
	buffer_time[T](period_ms, src, next)
	return &ObservableImpl[[]T]{
		ch:     next
		parent: o.parent
	}
}

fn buffer_time[T](period_ms int, src chan Item[T], next chan Item[[]T]) {
	spawn buffer_time_worker(period_ms, src, next)
}

fn buffer_time_worker[U](period_ms int, src chan Item[U], next chan Item[[]U]) {
	mut buf := []U{}
	mut last_flush := time.now()
	for {
		mut item := Item[U]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				if buf.len > 0 {
					next <- of[[]U](buf)
				}
				next <- item
				break
			}
			if item.has_value {
				buf << item.get_value()
			}
		} else if s == .closed {
			if buf.len > 0 {
				next <- of[[]U](buf)
			}
			break
		} else {
			now := time.now()
			if now.unix_offset_ms() - last_flush.unix_offset_ms() >= i64(period_ms) && buf.len > 0 {
				next <- of[[]U](buf)
				buf = []U{}
				last_flush = now
			} else {
				time.sleep(poll_sleep)
			}
		}
	}
	next.close()
}

// ---- average_f64 ---------------------------------------------------------

fn obs_average_f64_run(src chan Item[f64], next chan Item[f64]) {
	mut sum := f64(0)
	mut count := 0
	for {
		mut item := Item[f64]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- from_error[f64](item.err)
				break
			}
			if item.has_value {
				sum += item.get_value()
				count++
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	if count > 0 {
		next <- of[f64](sum / f64(count))
	}
	next.close()
}

// average_f64 computes the average of f64 values emitted by the source.
pub fn (mut o ObservableImpl[f64]) average_f64(opts ...RxOption) &ObservableImpl[f64] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[f64]()
	src := o.ch
	spawn obs_average_f64_run(src, next)
	return &ObservableImpl[f64]{
		ch:     next
		parent: o.parent
	}
}

// ---- sum_f64 -------------------------------------------------------------

fn obs_sum_f64_run(src chan Item[f64], next chan Item[f64]) {
	mut sum := f64(0)
	for {
		mut item := Item[f64]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- from_error[f64](item.err)
				break
			}
			if item.has_value {
				sum += item.get_value()
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next <- of[f64](sum)
	next.close()
}

// sum_f64 computes the sum of f64 values emitted by the source.
pub fn (mut o ObservableImpl[f64]) sum_f64(opts ...RxOption) &ObservableImpl[f64] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[f64]()
	src := o.ch
	spawn obs_sum_f64_run(src, next)
	return &ObservableImpl[f64]{
		ch:     next
		parent: o.parent
	}
}
