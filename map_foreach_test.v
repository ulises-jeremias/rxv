module rxv

import time

fn test_map_foreach() {
	mut base := just[int](1, 2, 3)
	mut mapped := map_[int, string](mut base, fn (v int) ?string {
		return v.str()
	})

	results := chan string{cap: 10}
	done := mapped.for_each(fn [results] (v string) {
		results <- v
	}, fn (err IError) {}, fn [results] () {
		results.close()
	})

	_ = <-done

	mut collected := []string{}
	for {
		mut v := ''
		s := results.try_pop(mut v)
		if s == .success {
			collected << v
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}

	println('collected: ${collected}')
	assert collected == ['1', '2', '3']
}
