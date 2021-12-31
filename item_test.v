module rxv

import context

fn test_send_items_variadic() {
	ch := chan Item{cap: 3}
	items := [new_item_value(1), new_item_value(2), new_item_value(3)]
	mut bctx := context.background()
	mut iter := new_channel_iterable(ch)
	go send_items(mut &bctx, ch, .close_channel, items)
	assert_iterable(mut &bctx, mut &iter, has_items(...items), has_no_error())
}

fn test_send_items_variadic_with_error() {
	ch := chan Item{cap: 3}
	err := &Error{
		msg: 'error'
	}
	items := [new_item_value(1), ItemValue(err), new_item_value(3)]
	mut bctx := context.background()
	mut iter := new_channel_iterable(ch)
	go send_items(mut &bctx, ch, .close_channel, items)
	assert_iterable(mut &bctx, mut &iter, has_items(items[0], items[1]), has_error(err))
}

fn test_send_items_slice() {
	ch := chan Item{cap: 3}
	mut items_slice := []ItemValue{}
	items_slice << [new_item_value(1), new_item_value(2), new_item_value(3)]
	mut iter := new_channel_iterable(ch)
	mut bctx := context.background()
	go send_items(mut &bctx, ch, .close_channel, items_slice)
	assert_iterable(mut &bctx, mut &iter, has_items(...items_slice), has_no_error())
}

fn test_send_items_slice_with_error() {
	ch := chan Item{cap: 3}
	err := &Error{
		msg: 'error'
	}
	mut items_slice := []ItemValue{}
	items_slice << [new_item_value(1), ItemValue(err), new_item_value(3)]
	mut iter := new_channel_iterable(ch)
	mut bctx := context.background()
	go send_items(mut &bctx, ch, .close_channel, items_slice)
	assert_iterable(mut &bctx, mut &iter, has_items(items_slice[0], items_slice[1]), has_error(err))
}

fn test_item_send_blocking() {
	ch := chan Item{cap: 1}
	defer {
		ch.close()
	}
	of(5).send_blocking(ch)
	v := (<-ch).value
}

fn test_item_send_context_true() {
	ch := chan Item{cap: 1}
	defer {
		ch.close()
	}
	mut bctx := context.background()
	mut ctx, cancel := context.with_cancel(mut &bctx)
	defer {
		cancel()
	}
	assert of(5).send_context(mut &ctx, ch)
}

fn test_item_send_context_false() {
	ch := chan Item{cap: 1}
	defer {
		ch.close()
	}
	mut bctx := context.background()
	mut ctx, cancel := context.with_cancel(mut &bctx)
	cancel()
	assert !of(5).send_context(mut &ctx, ch)
}

fn test_item_send_non_blocking() {
	ch := chan Item{cap: 1}
	defer {
		ch.close()
	}
	assert of(5).send_non_blocking(ch)
	assert !of(5).send_non_blocking(ch)
}
