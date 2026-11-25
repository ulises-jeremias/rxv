import ulises_jeremias.rxv
import time

fn test_count() {
	mut obs := rxv.just[int](1, 2, 3, 4, 5)
	mut result_obs := rxv.count_[int](mut obs)
	ch := result_obs.observe()
	mut item := rxv.Item[int]{
		has_value: false
		err:       none
	}
	for {
		s := ch.try_pop(mut item)
		if s == .success || s == .closed {
			break
		}
	}
	assert item.has_value
	assert item.get_value() == 5
}

fn test_scan() {
	mut obs := rxv.just[int](1, 2, 3, 4)
	mut result := rxv.scan_[int, int](mut obs, 0, fn (acc int, val int) int {
		return acc + val
	})
	ch := result.observe()
	mut results := []int{}
	for {
		mut item := rxv.Item[int]{
			has_value: false
			err:       none
		}
		s := ch.try_pop(mut item)
		if s == .success {
			if item.has_value {
				results << item.get_value()
			}
		} else if s == .closed {
			break
		}
	}
	assert results == [1, 3, 6, 10]
}

fn test_reduce() {
	mut obs := rxv.just[int](1, 2, 3, 4)
	mut result := rxv.reduce_[int, int](mut obs, 0, fn (acc int, val int) int {
		return acc + val
	})
	ch := result.observe()
	mut item := rxv.Item[int]{
		has_value: false
		err:       none
	}
	for {
		s := ch.try_pop(mut item)
		if s == .success || s == .closed {
			break
		}
	}
	assert item.has_value
	assert item.get_value() == 10
}

fn test_average_f64() {
	mut obs := rxv.just[f64](1.0, 2.0, 4.0)
	mut result := obs.average_f64()
	ch := result.observe()
	mut item := rxv.Item[f64]{
		has_value: false
		err:       none
	}
	for {
		s := ch.try_pop(mut item)
		if s == .success || s == .closed {
			break
		}
		time.sleep(10 * time.microsecond)
	}
	assert item.has_value
	assert item.get_value() == 7.0 / 3.0
}

fn test_sum_f64() {
	mut obs := rxv.just[f64](1.5, 2.25, 4.0)
	mut result := obs.sum_f64()
	ch := result.observe()
	mut item := rxv.Item[f64]{
		has_value: false
		err:       none
	}
	for {
		s := ch.try_pop(mut item)
		if s == .success || s == .closed {
			break
		}
		time.sleep(10 * time.microsecond)
	}
	assert item.has_value
	assert item.get_value() == 7.75
}
