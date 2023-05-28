module rxv

import context

struct RangeIterable {
	start int
	count int
mut:
	opts []RxOption
}

fn new_range_iterable(start int, count int, opts ...RxOption) Iterable {
	return &RangeIterable{
		start: start
		count: count
		opts: opts
	}
}

pub fn (i &RangeIterable) observe(opts ...RxOption) chan Item {
	mut options := i.opts.clone()
	options << opts.clone()
	option := parse_options(...options)
	mut ctx := option.build_context(empty_context)
	next := option.build_channel()

	spawn fn (i &RangeIterable, next chan Item, mut ctx context.Context) {
		for idx in i.start .. i.start + i.count {
			cdone := ctx.done()
			select {
				_ := <-cdone {
					return
				}
				next <- unsafe { of(idx) } {}
			}
		}
		next.close()
	}(i, next, mut &ctx)
	return next
}
