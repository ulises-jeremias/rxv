module rxv

import time

// ---- flat_map_ ------------------------------------------------------------
// Free function — V 0.5.x does not support methods with extra type params.
// Usage: flat_map_(mut obs, fn(x T) &ObservableImpl[U] { ... })

fn obs_flat_map_run[T, U](mapper fn (t T) &ObservableImpl[U], src chan Item[T], next chan Item[U]) {
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
				mut obs := mapper(item.get_value())
				inner := obs.observe()
				for {
					mut inner_item := Item[U]{
						has_value: false
						err:       none
					}
					ps := inner.try_pop(mut inner_item)
					if ps == .success {
						if inner_item.is_error() {
							next <- inner_item
							break
						}
						if inner_item.has_value {
							next <- inner_item
						}
					} else if ps == .closed {
						break
					} else {
						time.sleep(poll_sleep)
					}
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

// flat_map_ transforms each item by applying a function that returns an observable,
// then merges all inner observables into a single stream.
pub fn flat_map_[T, U](mut o ObservableImpl[T], mapper fn (t T) &ObservableImpl[U], opts ...RxOption) &ObservableImpl[U] {
	mut option := parse_options(...opts)
	next := chan Item[U]{cap: option.buffer_size}
	src := o.ch
	spawn obs_flat_map_run[T, U](mapper, src, next)
	return &ObservableImpl[U]{
		ch:     next
		parent: o.parent
	}
}

// ---- concat_map_ ----------------------------------------------------------

fn obs_concat_map_run[T, U](mapper fn (t T) &ObservableImpl[U], src chan Item[T], next chan Item[U]) {
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
				mut obs := mapper(item.get_value())
				inner := obs.observe()
				for {
					mut inner_item := Item[U]{
						has_value: false
						err:       none
					}
					ps := inner.try_pop(mut inner_item)
					if ps == .success {
						if inner_item.is_error() {
							next <- inner_item
							break
						}
						if inner_item.has_value {
							next <- inner_item
						}
					} else if ps == .closed {
						break
					} else {
						time.sleep(poll_sleep)
					}
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

// concat_map_ transforms each item by applying a function that returns an observable,
// and flattens them sequentially (one inner completes before the next starts).
pub fn concat_map_[T, U](mut o ObservableImpl[T], mapper fn (t T) &ObservableImpl[U], opts ...RxOption) &ObservableImpl[U] {
	mut option := parse_options(...opts)
	next := chan Item[U]{cap: option.buffer_size}
	src := o.ch
	spawn obs_concat_map_run[T, U](mapper, src, next)
	return &ObservableImpl[U]{
		ch:     next
		parent: o.parent
	}
}
