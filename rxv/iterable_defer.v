module rxv

import context

struct DeferIterable {
	fs   []Producer
	opts []RxOption
}

fn new_defer_iterable(fs []Producer, opts ...RxOption) Iterable {
	return &DeferIterable{
		fs: fs
		opts: opts
	}
}

pub fn (i &DeferIterable) observe(opts ...RxOption) chan Item {
	mut options := i.opts.clone()
	options << opts.clone()
	option := parse_options(...options)
	ctx := option.build_context(empty_context)
	next := option.build_channel()

	go fn (i &DeferIterable, next chan Item, ctx context.Context) {
		defer {
			next.close()
		}
		for f in i.fs {
			f(ctx, next)
		}
	}(i, next, ctx)
	return next
}
