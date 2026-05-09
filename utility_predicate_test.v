import ulises_jeremias.rxv

// test all items match predicate
fn test_all_match() {
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

// test all fails on non-matching item
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

// test all on empty stream returns true
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

// test any finds a match
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

// test any on no match returns false
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

// test find returns first matching item
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

// test find on no match completes without value
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

// test contains found
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

// test contains not found
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

// test is_empty on non-empty stream
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

// test is_empty on empty stream
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

// test element_at valid index
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

// test element_at out of bounds
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

// test element_at zero
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

// test skip
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

// test skip more than total
fn test_skip_more_than_total() {
	mut obs := rxv.just[int](1, 2)
	mut result := obs.skip(5)
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

// test take_last
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

// test take_last more than total
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
