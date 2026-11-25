module rxv

import time

fn test_start_with_prepends_values() {
	mut source := just[int](3, 4)
	result := source.start_with(1, 2)
	ch := result.observe()

	mut values := []int{}
	for {
		mut item := Item[int]{
			has_value: false
			err:       none
		}
		s := ch.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				assert false, 'start_with must preserve a successful source'
			}
			values << item.get_value()
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	assert values == [1, 2, 3, 4]
}

fn test_start_with_preserves_source_errors() {
	mut source := throw[int](error('source failed'))
	result := source.start_with(1)
	ch := result.observe()

	mut item := Item[int]{
		has_value: false
		err:       none
	}
	for {
		s := ch.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				break
			}
		} else if s == .closed {
			assert false
		} else {
			time.sleep(poll_sleep)
		}
	}
	assert item.err.str() == 'source failed'
}
