import ulises_jeremias.rxv

fn test_contains_found() {
	mut obs := rxv.just[int](1, 2, 3, 4, 5)
	mut result := obs.contains(fn (v int) bool {
		return v == 3
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

fn test_contains_not_found() {
	mut obs := rxv.just[int](1, 2, 3, 4, 5)
	mut result := obs.contains(fn (v int) bool {
		return v == 99
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

fn test_is_empty_true() {
	mut obs := rxv.empty[int]()
	mut result := obs.is_empty()
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

fn test_is_empty_false() {
	mut obs := rxv.just[int](42)
	mut result := obs.is_empty()
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

fn test_element_at_valid() {
	mut obs := rxv.just[int](10, 20, 30, 40)
	mut result := obs.element_at(2)
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

fn test_element_at_out_of_bounds() {
	mut obs := rxv.just[int](10, 20)
	mut result := obs.element_at(5)
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

fn test_element_at_zero() {
	mut obs := rxv.just[int](100, 200)
	mut result := obs.element_at(0)
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
	assert item.get_value() == 100
}
