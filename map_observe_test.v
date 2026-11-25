module rxv

import time

fn test_map_observe() {
	mut base := just[int](1, 2, 3)
	mut mapped := map_[int, string](mut base, fn (v int) ?string {
		return v.str()
	})
	ch := mapped.observe()

	mut count := 0
	for i := 0; i < 50; i++ {
		mut item := Item[string]{
			has_value: false
			err:       none
		}
		s := ch.try_pop(mut item)
		if s == .success && item.has_value {
			count++
		} else if s == .closed {
			break
		} else {
			time.sleep(10 * time.microsecond)
		}
	}
	println('count: ${count}')
	assert count == 3
}

fn test_map_observe_error() {
	mut base := just[int](1)
	mut mapped := map_[int, string](mut base, fn (v int) ?string {
		return none
	})
	ch := mapped.observe()

	mut item := Item[string]{
		has_value: false
		err:       none
	}
	for {
		s := ch.try_pop(mut item)
		if s == .success {
			break
		} else if s == .closed {
			assert false
		}
		time.sleep(10 * time.microsecond)
	}
	assert item.is_error()
	assert item.err.str() == 'map function returned no value'
}
