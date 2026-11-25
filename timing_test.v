module rxv

import time

fn test_time_interval_reports_elapsed_time() {
	mut source := just[int](1, 2)
	result := source.time_interval()
	ch := result.observe()
	mut intervals := []time.Duration{}
	for {
		mut item := Item[TimeInterval[int]]{
			has_value: false
			err:       none
		}
		s := ch.try_pop(mut item)
		if s == .success {
			assert !item.is_error()
			intervals << item.get_value().interval
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	assert intervals.len == 2
	assert intervals[0] == 0
	assert intervals[1] >= 0
}

fn test_timestamp_tags_values() {
	mut source := just[int](4, 5)
	result := source.timestamp()
	ch := result.observe()
	mut values := []int{}
	mut timestamps := []time.Time{}
	for {
		mut item := Item[Timestamp[int]]{
			has_value: false
			err:       none
		}
		s := ch.try_pop(mut item)
		if s == .success {
			assert !item.is_error()
			timed := item.get_value()
			values << timed.value
			timestamps << timed.timestamp
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	assert values == [4, 5]
	assert timestamps.len == 2
	assert timestamps[0].unix() > 0
	assert timestamps[1].unix() >= timestamps[0].unix()
}

fn test_timing_operators_preserve_errors() {
	mut source := throw[int](error('timing failed'))
	mut result := source.time_interval()
	ch := result.observe()
	mut item := Item[TimeInterval[int]]{
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
	assert item.err.str() == 'timing failed'
}

fn test_debounce_emits_the_last_value_on_completion() {
	mut source := just[int](1, 2, 3)
	mut result := debounce_[int](mut source, 1)
	assert collect_timing_values(mut result) == [3]
}

fn test_sample_handles_an_immediate_burst() {
	mut source := just[int](1, 2, 3)
	mut result := sample[int](mut source, 1)
	assert collect_timing_values(mut result) == [1]
}

fn test_throttle_first_emits_the_first_value_from_a_burst() {
	mut source := just[int](1, 2, 3)
	mut result := throttle_first_[int](mut source, 1)
	assert collect_timing_values(mut result) == [1]
}

fn collect_timing_values(mut source &ObservableImpl[int]) []int {
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
