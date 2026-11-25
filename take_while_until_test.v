module rxv

import time

fn test_take_while_completes_at_first_failed_predicate() {
	mut source := just[int](1, 2, 3, 4)
	mut result := source.take_while(fn (value int) bool {
		return value < 3
	})
	assert collect_take_values(mut result) == [1, 2]
}

fn test_take_while_preserves_source_errors() {
	mut source := throw[int](error('take_while failed'))
	mut result := source.take_while(fn (_value int) bool {
		return true
	})
	ch := result.observe()
	mut item := Item[int]{
		has_value: false
		err:       none
	}
	for {
		s := ch.try_pop(mut item)
		if s == .success {
			assert item.is_error()
			break
		} else if s == .closed {
			assert false
		} else {
			time.sleep(poll_sleep)
		}
	}
	assert item.err.str() == 'take_while failed'
}

fn test_take_until_stops_when_notifier_emits() {
	mut source := just[int](1, 2, 3)
	mut notifier := just[bool](true)
	mut result := take_until[int, bool](mut source, mut notifier)
	assert collect_take_values(mut result) == []
}

fn test_take_until_completes_when_notifier_is_empty() {
	mut source := just[int](1, 2, 3)
	mut notifier := empty[string]()
	mut result := take_until[int, string](mut source, mut notifier)
	assert collect_take_values(mut result) == [1, 2, 3]
}

fn collect_take_values(mut source &ObservableImpl[int]) []int {
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
