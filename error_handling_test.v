module rxv

import time

fn catch_error_fallback(_err IError) &ObservableImpl[int] {
	return just[int](7, 8)
}

fn test_catch_error_switches_to_fallback() {
	mut source := throw[int](error('source failed'))
	mut result := catch_error_[int](mut source, catch_error_fallback)
	assert collect_error_handling_values(mut result) == [7, 8]
}

fn test_catch_error_preserves_successful_values() {
	mut source := just[int](1, 2)
	mut result := catch_error_[int](mut source, catch_error_fallback)
	assert collect_error_handling_values(mut result) == [1, 2]
}

fn collect_error_handling_values(mut source &ObservableImpl[int]) []int {
	ch := source.observe()
	mut values := []int{}
	for {
		mut item := Item[int]{
			has_value: false
			err:       none
		}
		s := ch.try_pop(mut item)
		if s == .success {
			assert !item.is_error()
			values << item.get_value()
		} else if s == .closed {
			return values
		} else {
			time.sleep(poll_sleep)
		}
	}
}
