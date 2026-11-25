module rxv

import time

fn test_skip_while_resumes_at_first_failed_predicate() {
	mut source := just[int](1, 2, 3, 2)
	mut result := source.skip_while(fn (value int) bool {
		return value < 3
	})
	assert collect_skip_values(mut result) == [3, 2]
}

fn test_skip_until_resumes_after_notifier_emits() {
	mut source := just[int](1, 2, 3)
	mut notifier := just[bool](true)
	mut result := skip_until[int, bool](mut source, mut notifier)
	assert collect_skip_values(mut result) == [1, 2, 3]
}

fn test_skip_until_with_empty_notifier_skips_all_values() {
	mut source := just[int](1, 2, 3)
	mut notifier := empty[string]()
	mut result := skip_until[int, string](mut source, mut notifier)
	assert collect_skip_values(mut result) == []
}

fn collect_skip_values(mut source &ObservableImpl[int]) []int {
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
