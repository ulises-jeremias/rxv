module rxv

import time

fn test_just_emit_directly() {
	ch := chan Item[int]{cap: 3}

	spawn fn [ch] () {
		for i := 1; i <= 3; i++ {
			ch <- of[int](i)
		}
		ch.close()
	}()

	mut count := 0
	for i := 0; i < 50; i++ {
		mut item := Item[int]{
			has_value: false
			err:       none
		}
		s := ch.try_pop(mut item)
		if s == .success && item.has_value {
			println('got ${item.get_value()}')
			count++
		} else if s == .closed {
			println('closed')
			break
		} else {
			time.sleep(10 * time.microsecond)
		}
	}
	println('count: ${count}')
	assert count == 3
}
