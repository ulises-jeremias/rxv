module rxv

import context

struct CreateIterable {
	next chan Item
	opts []RxOption
mut:
	subscribers              []chan Item
	producer_already_created bool
}

fn new_create_iterable(fs []Producer, opts ...RxOption) Iterable {
	mut options := opts.clone()
	option := parse_options(...options)
	mut ctx := option.build_context(empty_context)
	next := option.build_channel()

	go fn (fs []Producer, next chan Item, mut ctx context.Context) {
		defer {
			next.close()
		}
		for f in fs {
			f(mut &ctx, next)
		}
	}(fs, next, mut &ctx)

	return &CreateIterable{
		next: next
		opts: opts
	}
}

pub fn (shared i CreateIterable) observe(opts ...RxOption) chan Item {
	mut options := i.opts.clone()
	options << opts.clone()
	option := parse_options(...options)

	if !option.is_connectable() {
		return i.next
	}

	if option.is_connect_operation() {
		mut ctx := option.build_context(empty_context)
		i.connect(mut &ctx)
	}

	ch := option.build_channel()

	lock i {
		i.subscribers << ch
	}

	return ch
}

fn (shared i CreateIterable) connect(mut ctx context.Context) {
	go i.produce(ctx)
	lock i {
		i.producer_already_created = true
	}
}

fn (shared i CreateIterable) produce(mut ctx context.Context) {
	defer {
		rlock i {
			for subscriber in i.subscribers {
				subscriber.close()
			}
		}
	}

	cdone := ctx.done()

	for select {
		_ := <-cdone {
			return
		}
		item := <-i.next {
			rlock i {
				for subscriber in i.subscribers {
					subscriber <- item
				}
			}
		}
	} {
	}
}
