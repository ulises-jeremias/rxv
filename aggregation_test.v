import ulises_jeremias.rxv as rxv

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
