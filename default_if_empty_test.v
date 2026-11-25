module rxv

import time

fn test_default_if_empty_emits_fallback_for_empty_source() {
	mut source := empty[int]()
	mut result := source.default_if_empty(42)
	assert read_default_value(mut result) == 42
}

fn test_default_if_empty_forwards_non_empty_source() {
	mut source := just[int](1, 2)
	result := source.default_if_empty(42)
	ch := result.observe()
	mut values := []int{}
	for {
		mut item := Item[int]{
			has_value: false
			err:       none
		}
		s := ch.try_pop(mut item)
		if s == .success {
			values << item.get_value()
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	assert values == [1, 2]
}

fn read_default_value(mut source &ObservableImpl[int]) int {
	ch := source.observe()
	mut item := Item[int]{
		has_value: false
		err:       none
	}
	for {
		s := ch.try_pop(mut item)
		if s == .success {
			return item.get_value()
		} else if s == .closed {
			assert false
		} else {
			time.sleep(poll_sleep)
		}
	}
	return 0
}
