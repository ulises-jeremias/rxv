module rxv

import time

pub struct Item[T] {
pub:
	value     T
	has_value bool
	err       IError
}

pub fn of[T](value T) Item[T] {
	return Item[T]{
		value:     value
		has_value: true
		err:       none
	}
}

pub fn from_error[T](err IError) Item[T] {
	return Item[T]{
		has_value: false
		err:       err
	}
}

pub fn (i Item[T]) is_error() bool {
	return i.err !is none
}

pub fn (i Item[T]) get_value() T {
	return i.value
}

pub fn (i Item[T]) send_context(done chan int, ch chan Item[T]) bool {
	for {
		mut dv := int(0)
		ds := done.try_pop(mut dv)
		if ds == .success || ds == .closed {
			return false
		}
		ps := ch.try_push(i)
		if ps == .success {
			return true
		} else if ps == .closed {
			return false
		}
		time.sleep(10 * time.microsecond)
	}
	return false
}

pub enum CloseChannelStrategy {
	leave_channel_open
	close_channel
}
