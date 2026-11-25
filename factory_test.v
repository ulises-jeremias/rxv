module rxv

import time

fn test_factory_operators_emit_expected_values() {
	mut source := just[int](1, 2, 3)
	mut result := source.take(2)
	ch := result.observe()
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
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	assert values == [1, 2]

	mut ranged := range(3, 3)
	assert collect_factory_values(mut ranged) == [3, 4, 5]
}

fn test_from_channel_factory() {
	channel := chan Item[int]{cap: 2}
	channel <- of[int](7)
	channel <- of[int](8)
	channel.close()
	mut source := from_channel[int](channel)
	assert collect_factory_values(mut source) == [7, 8]
}

fn test_empty_and_throw_factories() {
	mut empty_source := empty[int]()
	assert collect_factory_values(mut empty_source) == []

	mut failed := throw[int](error('factory failed'))
	ch := failed.observe()
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
	assert item.err.str() == 'factory failed'
}

fn test_timer_factory_emits_once() {
	mut source := timer(1)
	assert collect_factory_values(mut source) == [0]
}

fn test_timeout_factory_reports_stalled_source() {
	channel := chan Item[int]{cap: 1}
	mut source := from_channel[int](channel).timeout(1)
	ch := source.observe()
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
	assert item.err.str() == 'timeout after 1ms'
}

fn collect_factory_values(mut source &ObservableImpl[int]) []int {
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
