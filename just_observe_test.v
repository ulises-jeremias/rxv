module rxv

import time

fn test_just_observe() {
	mut obs := just[int](1, 2, 3)
	ch := obs.observe()

	mut count := 0
	for i := 0; i < 50; i++ {
		mut item := Item[int]{
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
