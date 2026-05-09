import ulises_jeremias.rxv

fn test_merge() {
	mut obs1 := rxv.just[int](1, 2)
	mut obs2 := rxv.just[int](3, 4)
	mut merged := rxv.merge[int](mut obs1, mut obs2)
	ch := merged.observe()
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
	results.sort()
	assert results == [1, 2, 3, 4]
}

fn test_concat() {
	obs1 := rxv.just[int](1, 2)
	obs2 := rxv.just[int](3, 4)
	mut concatted := rxv.concat[int]([obs1, obs2])
	ch := concatted.observe()
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
	assert results == [1, 2, 3, 4]
}
