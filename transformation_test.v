import ulises_jeremias.rxv

fn test_flat_map() {
	mut obs := rxv.just[int](1, 2, 3)
	mut result := rxv.flat_map_[int, int](mut obs, fn (v int) &rxv.ObservableImpl[int] {
		return rxv.just[int](v, v * 10)
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
	assert results.len == 6
	assert 1 in results
	assert 10 in results
	assert 2 in results
	assert 20 in results
	assert 3 in results
	assert 30 in results
}

fn test_concat_map() {
	mut obs := rxv.just[int](1, 2, 3)
	mut result := rxv.concat_map_[int, int](mut obs, fn (v int) &rxv.ObservableImpl[int] {
		return rxv.just[int](v, v * 10)
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
	// concat_map preserves order: 1, 10, 2, 20, 3, 30
	assert results == [1, 10, 2, 20, 3, 30]
}
