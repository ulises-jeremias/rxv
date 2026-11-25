module rxv

import time

fn test_on_error_resume_next_continues_with_fallback() {
	mut source := throw[int](error('source failed'))
	mut fallback := just[int](4, 5)
	mut result := on_error_resume_next[int](mut source, mut fallback)
	assert collect_finally_values(mut result) == [4, 5]
}

fn test_finally_runs_after_success() {
	callback := chan int{cap: 1}
	mut source := just[int](1, 2)
	mut result := finally_[int](mut source, fn [callback] () {
		callback <- 1
	})
	assert collect_finally_values(mut result) == [1, 2]
	mut callback_value := 0
	assert callback.try_pop(mut callback_value) == .success
}

fn test_finally_runs_after_error_and_preserves_it() {
	callback := chan int{cap: 1}
	mut source := throw[int](error('final failed'))
	mut result := finally_[int](mut source, fn [callback] () {
		callback <- 1
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
	mut callback_value := 0
	for {
		if callback.try_pop(mut callback_value) == .success {
			break
		}
		time.sleep(poll_sleep)
	}
	assert item.err.str() == 'final failed'
}

fn collect_finally_values(mut source &ObservableImpl[int]) []int {
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
