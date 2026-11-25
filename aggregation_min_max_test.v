module rxv

import time

fn test_min_and_max_use_comparator() {
	mut source_min := just[int](4, 1, 3, 2)
	mut source_max := just[int](4, 1, 3, 2)
	mut minimum := min_[int](mut source_min, fn (a int, b int) bool {
		return a < b
	})
	mut maximum := max_[int](mut source_max, fn (a int, b int) bool {
		return a < b
	})

	assert read_single_int(mut minimum) == 1
	assert read_single_int(mut maximum) == 4
}

fn test_min_and_max_preserve_source_errors() {
	mut source_min := throw[int](error('minimum failed'))
	mut source_max := throw[int](error('maximum failed'))
	mut minimum := min_[int](mut source_min, fn (a int, b int) bool {
		return a < b
	})
	mut maximum := max_[int](mut source_max, fn (a int, b int) bool {
		return a < b
	})

	assert read_single_error(mut minimum) == 'minimum failed'
	assert read_single_error(mut maximum) == 'maximum failed'
}

fn read_single_int(mut source &ObservableImpl[int]) int {
	ch := source.observe()
	mut item := Item[int]{
		has_value: false
		err:       none
	}
	for {
		s := ch.try_pop(mut item)
		if s == .success || s == .closed {
			break
		}
		time.sleep(poll_sleep)
	}
	assert item.has_value
	return item.get_value()
}

fn read_single_error(mut source &ObservableImpl[int]) string {
	ch := source.observe()
	mut item := Item[int]{
		has_value: false
		err:       none
	}
	for {
		s := ch.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				return item.err.str()
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	assert false
	return ''
}
