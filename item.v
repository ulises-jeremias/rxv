module rxv

import context
import time

pub interface ItemValue {}

pub struct ItemValueImpl<T> {
	val T
}

pub fn new_item_value<T>(val T) ItemValue {
	return ItemValue(&ItemValueImpl<T>{
		val: val
	})
}

// Item is a wrapper having either a value or an error.
pub struct Item {
pub:
	value ItemValue
	err   IError = none
}

// TimestampItem attach a timestamp to an item.
pub struct TimestampItem {
	timestamp time.Time
	value     ItemValue
}

// CloseChannelStrategy indicates a strategy on whether to close a channel.
pub enum CloseChannelStrategy {
	// leave_channel_open indicates to leave the channel open after completion.
	leave_channel_open
	// close_channel indicates to close the channel open after completion.
	close_channel
}

// of creates an item from a value
pub fn of(value ItemValue) Item {
	return Item{
		value: value
	}
}

// error creates an item from an error
[inline]
pub fn error(err IError) Item {
	return from_error(err)
}

// from_error creates an item from an error
pub fn from_error(err IError) Item {
	return Item{
		err: err
	}
}

// send_items is an utility funtion that send a list of ItemValue and indicate
// the strategy on whether to close the channel once the function completes
pub fn send_items(mut ctx context.Context, ch chan Item, strategy CloseChannelStrategy, items []ItemValue) {
	if strategy == .close_channel {
		defer {
			ch.close()
		}
	}
	send(mut &ctx, ch, ...items)
}

fn send(mut ctx context.Context, ch chan Item, items ...ItemValue) {
	for item in items {
		match item {
			Error {
				error(item).send_context(mut &ctx, ch)
			}
			chan ItemValue {
				loop: for {
					select {
						i := <-item {
							match i {
								Error {
									error(i).send_context(mut &ctx, ch)
								}
								else {
									of(i).send_context(mut &ctx, ch)
								}
							}
						}
						else {
							break loop
						}
					}
				}
			}
			[]ItemValue {
				for i in item {
					send(mut &ctx, ch, i)
				}
			}
			else {
				of(item).send_context(mut &ctx, ch)
			}
		}
	}
}

// is_error checks if an item is an error
pub fn (i Item) is_error() bool {
	if isnil(i.err) {
		return false
	}
	if i.err is none {
		return false
	}
	return true
}

// send_blocking sends an item and blocks until it is sent
pub fn (i Item) send_blocking(ch chan Item) {
	ch <- i
}

// send_context sends an item and blocks until it is sent or a context canceled.
// It returns a boolean to indicate wheter the item was sent.
pub fn (i Item) send_context(mut ctx context.Context, ch chan Item) bool {
	done := ctx.done()
	select {
		_ := <-done {
			return false
		}
		else {}
	}
	select {
		ch <- i {
			return true
		}
	}
	return false
}

// send_non_blocking sends an item without blocking.
// It returns a boolean to indicate whether the item was sent.
pub fn (i Item) send_non_blocking(ch chan Item) bool {
	select {
		ch <- i {
			return true
		}
		else {
			return false
		}
	}
	return false
}
