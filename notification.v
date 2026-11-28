module rxv

import time

// NotificationKind identifies a value or terminal signal in a materialized stream.
pub enum NotificationKind {
	next
	error
	complete
}

// Notification is one value or terminal signal carried by a materialized stream.
pub struct Notification[T] {
pub:
	kind  NotificationKind
	value T
	err   IError
}

// notification_next creates a notification containing a stream value.
pub fn notification_next[T](value T) Notification[T] {
	return Notification[T]{
		kind:  .next
		value: value
		err:   none
	}
}

// notification_error creates a notification containing a stream error.
pub fn notification_error[T](err IError) Notification[T] {
	return Notification[T]{
		kind: .error
		err:  err
	}
}

// notification_complete creates a normal-completion notification.
pub fn notification_complete[T]() Notification[T] {
	return Notification[T]{
		kind: .complete
		err:  none
	}
}

fn obs_materialize_run[T](src chan Item[T], next chan Item[Notification[T]]) {
	for {
		mut item := Item[T]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- of[Notification[T]](notification_error[T](item.err))
				break
			}
			if item.has_value {
				next <- of[Notification[T]](notification_next[T](item.get_value()))
			}
		} else if s == .closed {
			next <- of[Notification[T]](notification_complete[T]())
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// materialize converts values and terminal signals into Notification values.
// An error notification is terminal; normal completion is represented by a
// completion notification before the materialized stream itself closes.
pub fn (mut o ObservableImpl[T]) materialize(opts ...RxOption) &ObservableImpl[Notification[T]] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[Notification[T]]()
	spawn obs_materialize_run[T](o.ch, next)
	return &ObservableImpl[Notification[T]]{
		ch:     next
		parent: o.parent
	}
}

fn obs_dematerialize_run[T](src chan Item[Notification[T]], next chan Item[T]) {
	for {
		mut item := Item[Notification[T]]{
			has_value: false
			err:       none
		}
		s := src.try_pop(mut item)
		if s == .success {
			if item.is_error() {
				next <- from_error[T](item.err)
				break
			}
			if !item.has_value {
				continue
			}
			notification := item.get_value()
			match notification.kind {
				.next {
					next <- of[T](notification.value)
				}
				.error {
					if isnil(notification.err) {
						next <- from_error[T](error('dematerialize: error notification has no error'))
					} else {
						next <- from_error[T](notification.err)
					}
					break
				}
				.complete {
					break
				}
			}
		} else if s == .closed {
			break
		} else {
			time.sleep(poll_sleep)
		}
	}
	next.close()
}

// dematerialize converts Notification values back into values and terminal signals.
pub fn (mut o ObservableImpl[Notification[T]]) dematerialize(opts ...RxOption) &ObservableImpl[T] {
	mut option := parse_options(...opts)
	next := option.build_channel_t[T]()
	spawn obs_dematerialize_run[T](o.ch, next)
	return &ObservableImpl[T]{
		ch:     next
		parent: o.parent
	}
}
