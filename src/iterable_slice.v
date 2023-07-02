module rxv

import context

struct SliceIterable {
mut:
	items []Item
	opts  []RxOption
}

fn new_slice_iterable(items []Item, opts ...RxOption) Iterable {
	return &SliceIterable{
		items: items
		opts: opts
	}
}

pub fn (i &SliceIterable) observe(opts ...RxOption) chan Item {
	mut options := i.opts.clone()
	options << opts.clone()
	option := parse_options(...options)
	next := option.build_channel()
	mut ctx := option.build_context(empty_context)

	go fn (i &SliceIterable, next chan Item, mut ctx context.Context) {
		for item in i.items {
			cdone := ctx.done()
			select {
				_ := <-cdone {
					return
				}
				next <- item {}
			}
		}
		next.close()
	}(i, next, mut &ctx)
	return next
}
