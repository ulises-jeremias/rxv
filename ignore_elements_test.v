module rxv

import time

fn test_ignore_elements_discards_values() {
	mut source := just[int](1, 2, 3)
	result := source.ignore_elements()
	ch := result.observe()

	mut item := Item[int]{
		has_value: false
		err:       none
	}
	for {
		s := ch.try_pop(mut item)
		if s == .closed {
			break
		} else if s == .success {
			assert false, 'ignore_elements must not emit values'
		} else {
			time.sleep(poll_sleep)
		}
	}
}

fn test_ignore_elements_preserves_errors() {
	mut source := throw[int](error('ignored source failed'))
	result := source.ignore_elements()
	ch := result.observe()

	mut item := Item[int]{
		has_value: false
		err:       none
	}
	for {
		s := ch.try_pop(mut item)
		if s == .success {
			break
		} else if s == .closed {
			assert false
		} else {
			time.sleep(poll_sleep)
		}
	}
	assert item.is_error()
	assert item.err.str() == 'ignored source failed'
}
