module rxv

import time

fn test_materialize_values_and_completion() {
	mut source := just[int](1, 2)
	mut result := source.materialize()
	notifications := collect_materialized_values(mut result)
	assert notifications.len == 3
	assert notifications[0].kind == .next
	assert notifications[0].value == 1
	assert notifications[1].kind == .next
	assert notifications[1].value == 2
	assert notifications[2].kind == .complete
}

fn test_observe_handles_nested_generic_values() {
	mut source := from_slice[Notification[int]]([
		notification_next[int](1),
		notification_complete[int](),
	])
	notifications := collect_materialized_values(mut source)
	assert notifications.len == 2
	assert notifications[0].value == 1
	assert notifications[1].kind == .complete
}

fn test_materialize_error_as_terminal_notification() {
	mut source := throw[int](error('source failed'))
	mut result := source.materialize()
	notifications := collect_materialized_values(mut result)
	assert notifications.len == 1
	assert notifications[0].kind == .error
	assert !isnil(notifications[0].err)
	assert notifications[0].err.msg() == 'source failed'
}

fn test_dematerialize_restores_values_and_completion() {
	mut source := from_slice[Notification[int]]([
		notification_next[int](1),
		notification_next[int](2),
		notification_complete[int](),
		notification_next[int](3),
	])
	mut result := source.dematerialize()
	assert collect_materialized_values(mut result) == [1, 2]
}

fn test_dematerialize_restores_error_and_stops() {
	mut source := from_slice[Notification[int]]([
		notification_next[int](1),
		notification_error[int](error('materialized failure')),
		notification_next[int](2),
	])
	mut result := source.dematerialize()
	ch := result.observe()
	mut first := Item[int]{
		has_value: false
		err:       none
	}
	for {
		if ch.try_pop(mut first) == .success {
			break
		}
		time.sleep(poll_sleep)
	}
	assert first.has_value
	assert first.value == 1
	mut terminal := Item[int]{
		has_value: false
		err:       none
	}
	for {
		s := ch.try_pop(mut terminal)
		if s == .success || s == .closed {
			break
		}
		time.sleep(poll_sleep)
	}
	assert terminal.is_error()
	assert terminal.err.msg() == 'materialized failure'
}

fn test_materialize_then_dematerialize_round_trip() {
	mut source := just[string]('a', 'b', 'c')
	mut materialized := source.materialize()
	mut restored := materialized.dematerialize()
	assert collect_materialized_values(mut restored) == ['a', 'b', 'c']
}

fn collect_materialized_values[T](mut source &ObservableImpl[T]) []T {
	ch := source.observe()
	mut values := []T{}
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := ch.try_pop(mut item)
		if s == .success {
			assert !item.is_error()
			values << item.get_value()
		} else if s == .closed {
			return values
		} else {
			time.sleep(poll_sleep)
		}
	}
	return values
}
