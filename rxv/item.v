module rxv

import context
import sync
import time

pub type ItemValue = voidptr | string | chan ItemValue | []ItemValue

// Item is a wrapper having either a value or an error.
pub struct Item {
        value ItemValue
        err string
}

// TimestampItem attach a timestamp to an item.
pub struct TimestampItem {
        timestamp time.Time
        value ItemValue
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
        return Item{value: value}
}

// error creates an item from an error
pub fn error(err string) Item {
        return Item{err: err}
}

// send_items is an utility funtion that send a list of ItemValue and indicate
// the strategy on whether to close the channel once the function completes
pub fn send_items(ctx context.Context, ch chan Item, strategy CloseChannelStrategy, items ...ItemValue) {
        if strategy == .close_channel {
                defer {
                        ch.close()
                }
        }
        send(ctx, ch, ...items)
}

fn send(ctx context.Context, ch chan Item, items ...ItemValue) {
        for item in items {
                match item {
                        string {
                                error(item).send_context(ctx, ch)
                        }
                        chan ItemValue {
                                loop: for {
                                        select {
                                                i := <-item {
                                                        match i {
                                                                string {
                                                                        error(i).send_context(ctx, ch)
                                                                }
                                                                else {
                                                                        of(i).send_context(ctx, ch)    
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
                                        send(ctx, ch, i)
                                }
                        }
                        else { of(item).send_context(ctx, ch) }
                }
        }
}

// is_error checks if an item is an error
pub fn (i Item) is_error() bool {
        return i.err != ''
}

// send_blocking sends an item and blocks until it is sent
pub fn (i Item) send_blocking(ch chan Item) {
        ch <- i
}

// send_context sends an item and blocks until it is sent or a context canceled.
// It returns a boolean to indicate wheter the item was sent.
pub fn (i Item) send_context(ctx context.Context, ch chan Item) bool {
        idone := ctx.done()
        select {
                _ := <- idone {
                        // Context's done channel has the highest priority
                        return false
                }
                else {
                        idone_ := ctx.done()
                        select {
                                _ := <- idone_ {
                                        return false
                                }
                                ch <- i {
                                        return true
                                }
                        }
                }
        }
        return false
}

// send_non_blocking sends an item without blocking.
// It returns a boolean to indicate whether the item was sent.
pub fn (i Item) send_non_blocking(ch chan Item) bool {
        select {
                else {
                        return false
                }
                ch <- i {
                        return true
                }
        }
        return false
}

