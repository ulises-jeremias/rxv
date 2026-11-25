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
