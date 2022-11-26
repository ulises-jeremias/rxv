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
	mut ctx := option.build_context(empty_context)
	next := option.build_channel()

	spawn fn (i &DeferIterable, next chan Item, mut ctx context.Context) {
		defer {
			next.close()
		}
		for f in i.fs {
			f(mut ctx, next)
		}
	}(i, next, mut &ctx)
	return next
}
