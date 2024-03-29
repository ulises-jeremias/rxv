module rxv

import context
import time

// ItemValue is a type that can be used as a value in a reactive expression.
pub interface ItemValue {}

// Item is a wrapper around a value that can be used as a value in a reactive
// expression. It is a reference type, so it can be used to wrap values that
// are not reference types.
pub struct Item {
pub:
	value ItemValue|none = none
	err   IError|none    = none
}

// TimestampedItem is a wrapper around a value that can be used as a value in
// a reactive expression. It is a reference type, so it can be used to wrap
// values that are not reference types.
pub struct TimestampedItem {
pub:
	value     ItemValue
	timestamp time.Time
}

// CloseChannelStrategy indicates a strategy on whether to close a channel.
pub enum CloseChannelStrategy {
	// leave_channel_open indicates to leave the channel open after completion.
	leave_channel_open
	// close_channel indicates to close the channel open after completion.
	close_channel
}

// empty_item is an empty item
fn empty_item() Item {
	return Item{}
}

// of creates an item from a value
pub fn of(value ItemValue) Item {
	return Item{
		value: value
	}
}

// from_error creates an item from an error
pub fn from_error(err IError) Item {
	return Item{
		err: err
	}
}

// send_items is a helper function to send items to a channel.
pub fn send_items(mut ctx context.Context, ch chan Item, strategy CloseChannelStrategy, items []ItemValue) {
	if strategy == .close_channel {
		defer {
			ch.close()
		}
	}

	send(mut ctx, ch, items)
}

fn send(mut ctx context.Context, ch chan Item, items []ItemValue) {
	for item in items {
		match item {
			Error {
				from_error(item).send_context(mut ctx, ch)
			}
			MessageError {
				from_error(item).send_context(mut ctx, ch)
			}
			chan ItemValue {
				for select {
					i := <-item {
						match i {
							Error {
								from_error(i as IError).send_context(mut ctx, ch)
							}
							MessageError {
								from_error(i as IError).send_context(mut ctx, ch)
							}
							else {
								of(i as ItemValue).send_context(mut ctx, ch)
							}
						}
					}
					else {
						if item.len == 0 && item.closed {
							break
						}
					}
				} {
					// do nothing
				}
			}
			[]ItemValue {
				for i in item {
					send(mut ctx, ch, [i])
				}
			}
			else {
				of(item).send_context(mut ctx, ch)
			}
		}
	}
}

// is_error checks if an item is an error
pub fn (i Item) is_error() bool {
	match i.err {
		none { return false }
		else { return true }
	}
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
		_ := <-done {
			return false
		}
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
