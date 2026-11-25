module rxv

import time

fn test_tap_runs_side_effect_and_forwards_values() {
	mut source := just[int](1, 2, 3)
	seen := chan int{cap: 3}
	result := source.tap(fn [seen] (value int) {
		seen <- value
	})
	ch := result.observe()

	mut values := []int{}
	for {
		mut item := Item[int]{
			has_value: false
			err:       none
		}
		s := ch.try_pop(mut item)
		if s == .success {
			values << item.get_value()
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	assert values == [1, 2, 3]
	mut observed := []int{}
	for {
		mut value := 0
		if seen.try_pop(mut value) == .success {
			observed << value
		} else {
			break
		}
	}
	assert observed == [1, 2, 3]
}
