import ulises_jeremias.rxv as rxv

fn test_distinct() {
	mut obs := rxv.just[int](1, 2, 2, 3, 1, 3)
	mut result := obs.distinct()
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
	assert results == [1, 2, 3]
}

fn test_distinct_until_changed() {
	mut obs := rxv.just[int](1, 1, 2, 2, 3, 1)
	mut result := obs.distinct_until_changed()
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
	assert results == [1, 2, 3, 1]
}
