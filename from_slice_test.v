import rxv

fn test_from_slice() {
	mut obs := rxv.from_slice[int]([10, 20, 30])
	ch := obs.observe()
	mut results := []int{}
	for {
		mut item := rxv.Item[int]{ has_value: false, err: none }
		s := ch.try_pop(mut item)
		if s == .success {
			if item.has_value {
				results << item.get_value()
			}
		} else if s == .closed {
			break
		}
	}
	assert results == [10, 20, 30]
}

fn test_repeat() {
	mut obs := rxv.repeat[string]('hello', 3)
	ch := obs.observe()
	mut results := []string{}
	for {
		mut item := rxv.Item[string]{ has_value: false, err: none }
		s := ch.try_pop(mut item)
		if s == .success {
			if item.has_value {
				results << item.get_value()
			}
		} else if s == .closed {
			break
		}
	}
	assert results == ['hello', 'hello', 'hello']
}
