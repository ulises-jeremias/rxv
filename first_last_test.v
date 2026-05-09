import ulises_jeremias.rxv as rxv

fn test_first() {
	mut obs := rxv.just[int](10, 20, 30)
	mut result := obs.first()
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
	assert item.get_value() == 10
}

fn test_last() {
	mut obs := rxv.just[int](10, 20, 30)
	mut result := obs.last()
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
