import context
import rxv

fn test_send_items_variadic() {
	ch := chan rxv.Item{cap: 3}
	items := [rxv.ItemValue(1), 2, 3]
	go rxv.send_items(context.background(), ch, .close_channel, items)
}

fn test_send_items_variadic_with_error() {
	ch := chan rxv.Item{cap: 3}
	err := Error{
		msg: 'error'
	}
	items := [rxv.ItemValue(1), err, 3]
	go rxv.send_items(context.background(), ch, .close_channel, items)
}

fn test_send_items_slice() {
	ch := chan rxv.Item{cap: 3}
	mut items_slice := []rxv.ItemValue{}
	items_slice << [rxv.ItemValue(1), 2, 3]
	go rxv.send_items(context.background(), ch, .close_channel, items_slice)
}

fn test_send_items_slice_with_error() {
	ch := chan rxv.Item{cap: 3}
	err := Error{
		msg: 'error'
	}
	mut items_slice := []rxv.ItemValue{}
	items_slice << [rxv.ItemValue(1), err, 3]
	go rxv.send_items(context.background(), ch, .close_channel, items_slice)
}

fn test_item_send_blocking() {
	ch := chan rxv.Item{cap: 1}
	defer {
		ch.close()
	}
	rxv.of(5).send_blocking(ch)
	v := (<-ch).value
}

fn test_item_send_context_true() {
	ch := chan rxv.Item{cap: 1}
	defer {
		ch.close()
	}
	ctx := context.with_cancel(context.background())
	defer {
		context.cancel(ctx)
	}
	assert rxv.of(5).send_context(ctx, ch)
}

fn test_item_send_context_false() {
	ch := chan rxv.Item{cap: 1}
	defer {
		ch.close()
	}
	ctx := context.with_cancel(context.background())
	context.cancel(ctx)
	assert !rxv.of(5).send_context(ctx, ch)
}
