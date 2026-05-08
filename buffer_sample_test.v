import rxv

// buffer emits batches of exactly 2 items
fn test_buffer_exact_count() {
	mut obs := rxv.just[int](1, 2, 3, 4, 5)
	mut result := rxv.buffer_(mut obs, 2)
	ch := result.observe()
	mut item := rxv.Item[[]int]{
		has_value: false
		err:       none
	}
	mut values := [][]int{}
	for {
		s := ch.try_pop(mut item)
		if s == .success {
			if item.has_value {
				values << item.get_value()
			}
		} else if s == .closed {
			break
		} else {
			continue
		}
	}
	assert values.len == 3
	assert values[0] == [1, 2]
	assert values[1] == [3, 4]
	assert values[2] == [5]
}

// buffer with count larger than stream emits single batch
fn test_buffer_count_larger_than_stream() {
	mut obs := rxv.just[int](1, 2)
	mut result := rxv.buffer_(mut obs, 5)
	ch := result.observe()
	mut item := rxv.Item[[]int]{
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
	assert item.get_value() == [1, 2]
}
