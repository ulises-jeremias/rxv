import rxv

fn test_skip() {
	mut obs := rxv.just[int](1, 2, 3, 4, 5)
	mut result := obs.skip(2)
	ch := result.observe()
	mut item := rxv.Item[int]{
		has_value: false
		err:       none
	}
	mut values := []int{}
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
	assert values == [3, 4, 5]
}

fn test_skip_more_than_total() {
	mut obs := rxv.just[int](1, 2)
	mut result := obs.skip(5)
	ch := result.observe()
	mut item := rxv.Item[int]{
		has_value: false
		err:       none
	}
	mut values := []int{}
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
	assert values == []
}

fn test_take_last() {
	mut obs := rxv.just[int](1, 2, 3, 4, 5)
	mut result := obs.take_last(2)
	ch := result.observe()
	mut item := rxv.Item[int]{
		has_value: false
		err:       none
	}
	mut values := []int{}
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
	assert values == [4, 5]
}

fn test_take_last_one() {
	mut obs := rxv.just[int](10, 20, 30)
	mut result := obs.take_last(1)
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
	assert item.get_value() == 30
}

fn test_take_last_more_than_total() {
	mut obs := rxv.just[int](1, 2)
	mut result := obs.take_last(5)
	ch := result.observe()
	mut item := rxv.Item[int]{
		has_value: false
		err:       none
	}
	mut values := []int{}
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
	assert values == [1, 2]
}
