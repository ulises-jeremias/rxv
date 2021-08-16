module rxv

import context

struct CreateIterable {
	next                     chan Item
	opts                     []RxOption
	subscribers              shared []chan Item
	producer_already_created shared bool
}

fn new_create_iterable(fs []Producer, opts ...RxOption) Iterable {
	mut options := opts.clone()
	option := parse_options(...options)
	ctx := option.build_context(empty_context)
	next := option.build_channel()

	go fn (fs []Producer, next chan Item, ctx context.Context) {
		defer {
			next.close()
		}
		for f in fs {
			f(ctx, next)
		}
	}(fs, next, ctx)

	return &CreateIterable{
		next: next
		opts: opts
	}
}

pub fn (mut i CreateIterable) observe(opts ...RxOption) chan Item {
	mut options := i.opts.clone()
	options << opts.clone()
	option := parse_options(...options)

	if !option.is_connectable() {
		return i.next
	}

	if option.is_connect_operation() {
		i.connect(option.build_context(empty_context))
	}

	ch := option.build_channel()

	lock i.subscribers {
		i.subscribers << ch
	}

	return ch
}

fn (mut i CreateIterable) connect(ctx context.Context) {
	lock i.producer_already_created {
		go i.produce(ctx)
		i.producer_already_created = true
	}
}

fn (mut i CreateIterable) produce(ctx context.Context) {
	defer {
		rlock i.subscribers {
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
			rlock i.subscribers {
				for subscriber in i.subscribers {
					subscriber <- item
				}
			}
		}
	} {
	}
}
