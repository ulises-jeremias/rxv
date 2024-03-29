module rxv

struct JustIterable {
mut:
	items []ItemValue
	opts  []RxOption
}

fn new_just_iterable(items ...ItemValue) fn (opts ...RxOption) Iterable {
	return fn [items] (opts ...RxOption) Iterable {
		return &JustIterable{
			items: items
			opts: opts
		}
	}
}

pub fn (i &JustIterable) observe(opts ...RxOption) chan Item {
	mut options := i.opts.clone()
	options << opts.clone()
	option := parse_options(...options)
	next := option.build_channel()
	mut ctx := option.build_context(empty_context)

	go send_items(mut &ctx, next, .close_channel, i.items)
	return next
}
