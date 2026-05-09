import ulises_jeremias.rxv

fn test_all_all_match() {
	mut obs := rxv.just[int](2, 4, 6, 8)
	mut result := obs.all(fn (v int) bool {
		return v % 2 == 0
	})
	ch := result.observe()
	mut item := rxv.Item[bool]{
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
	assert item.get_value() == true
}

fn test_all_some_dont_match() {
	mut obs := rxv.just[int](2, 4, 5, 8)
	mut result := obs.all(fn (v int) bool {
		return v % 2 == 0
	})
	ch := result.observe()
	mut item := rxv.Item[bool]{
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
	assert item.get_value() == false
}

fn test_all_empty() {
	mut obs := rxv.empty[int]()
	mut result := obs.all(fn (v int) bool {
		return v > 0
	})
	ch := result.observe()
	mut item := rxv.Item[bool]{
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
	assert item.get_value() == true
}

fn test_any_found() {
	mut obs := rxv.just[int](1, 3, 5, 6)
	mut result := obs.any(fn (v int) bool {
		return v % 2 == 0
	})
	ch := result.observe()
	mut item := rxv.Item[bool]{
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
	assert item.get_value() == true
}

fn test_any_not_found() {
	mut obs := rxv.just[int](1, 3, 5, 7)
	mut result := obs.any(fn (v int) bool {
		return v % 2 == 0
	})
	ch := result.observe()
	mut item := rxv.Item[bool]{
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
	assert item.get_value() == false
}

fn test_any_empty() {
	mut obs := rxv.empty[int]()
	mut result := obs.any(fn (v int) bool {
		return v > 0
	})
	ch := result.observe()
	mut item := rxv.Item[bool]{
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
	assert item.get_value() == false
}

fn test_find_found() {
	mut obs := rxv.just[int](1, 3, 5, 6, 8)
	mut result := obs.find(fn (v int) bool {
		return v % 2 == 0
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
	assert item.get_value() == 6
}

fn test_find_not_found() {
	mut obs := rxv.just[int](1, 3, 5, 7)
	mut result := obs.find(fn (v int) bool {
		return v % 2 == 0
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
	assert item.has_value == false
}
