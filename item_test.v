module rxv

import context

struct Value {
	val int
}

fn test_send_items_variadic() {
	ch := chan Item{cap: 3}
	items := [ItemValue(&Value{
		val: 1
	}), ItemValue(&Value{
		val: 2
	}),
		ItemValue(&Value{
		val: 3
	})]
	mut bctx := context.background()
	mut iter := new_channel_iterable(ch)
	go send_items(mut &bctx, ch, .close_channel, items)
	test(mut &bctx, mut &iter, has_items(items), has_no_error())
}

fn test_send_items_variadic_with_error() {
	ch := chan Item{cap: 3}
	err := &Error{
		msg: 'error'
	}
	items := [ItemValue(&Value{
		val: 1
	}), ItemValue(err), ItemValue(&Value{
		val: 3
	})]
	mut bctx := context.background()
	go send_items(mut &bctx, ch, .close_channel, items)
}

fn test_send_items_slice() {
	ch := chan Item{cap: 3}
	mut items_slice := []ItemValue{}
	items_slice << [ItemValue(&Value{
		val: 1
	}), ItemValue(&Value{
		val: 2
	}),
		ItemValue(&Value{
		val: 3
	})]
	mut bctx := context.background()
	go send_items(mut &bctx, ch, .close_channel, items_slice)
}

fn test_send_items_slice_with_error() {
	ch := chan Item{cap: 3}
	err := &Error{
		msg: 'error'
	}
	mut items_slice := []ItemValue{}
	items_slice << [ItemValue(&Value{
		val: 1
	}), ItemValue(err), ItemValue(&Value{
		val: 3
	})]
	mut bctx := context.background()
	go send_items(mut &bctx, ch, .close_channel, items_slice)
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
