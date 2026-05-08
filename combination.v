module rxv

import context
import time

// ---- merge ----------------------------------------------------------------

fn obs_merge_run[T](src1 chan Item[T], src2 chan Item[T], next chan Item[T]) {
	mut src1_done := false
	mut src2_done := false
	for !src1_done || !src2_done {
		if !src1_done {
			mut item := Item[T]{ has_value: false, err: none }
			s := src1.try_pop(mut item)
			if s == .success {
				if item.is_error() {
					next <- item
					src1_done = true
					continue
				}
				if item.has_value {
					next <- item
				}
			} else if s == .closed {
				src1_done = true
			}
		}
		if !src2_done {
			mut item := Item[T]{ has_value: false, err: none }
			s := src2.try_pop(mut item)
			if s == .success {
				if item.is_error() {
					next <- item
					src2_done = true
					continue
				}
				if item.has_value {
					next <- item
				}
			} else if s == .closed {
				src2_done = true
			}
		}
		if !src1_done || !src2_done {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// merge combines two observables by interleaving their emissions.
pub fn merge[T](mut o1 ObservableImpl[T], mut o2 ObservableImpl[T], opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	src1 := o1.ch
	src2 := o2.ch
	spawn obs_merge_run[T](src1, src2, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: context.background()
	}
}

// ---- concat ---------------------------------------------------------------

fn obs_concat_run[T](sources []chan Item[T], next chan Item[T]) {
	for src in sources {
		for {
			mut item := Item[T]{ has_value: false, err: none }
			s := src.try_pop(mut item)
			if s == .success {
				if item.is_error() {
					next <- item
					next.close()
					return
				}
				next <- item
			} else if s == .closed {
				break
			} else {
				time.sleep(poll_sleep)
			}
		}
	}
	next.close()
}

// concat concatenates multiple observables sequentially.
pub fn concat[T](observables []&ObservableImpl[T], opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	mut sources := []chan Item[T]{}
	for obs in observables {
		sources << obs.ch
	}
	spawn obs_concat_run[T](sources, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: context.background()
	}
}
