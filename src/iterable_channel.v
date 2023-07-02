module rxv

import context

struct ChannelIterable {
	next chan Item
	opts []RxOption
mut:
	subscribers              shared []chan Item
	producer_already_created shared bool
}

fn new_channel_iterable(next chan Item, opts ...RxOption) Iterable {
	return &ChannelIterable{
		next: next
		opts: opts
	}
}

pub fn (mut i ChannelIterable) observe(opts ...RxOption) chan Item {
	mut options := i.opts.clone()
	options << opts.clone()
	option := parse_options(...options)

	if !option.is_connectable() {
		return i.next
	}

	if option.is_connect_operation() {
		mut ctx := option.build_context(empty_context)
		i.connect(mut ctx)
	}

	ch := option.build_channel()

	lock i.subscribers {
		i.subscribers << ch
	}

	return ch
}

fn (mut i ChannelIterable) connect(mut ctx context.Context) {
	lock i.producer_already_created {
		if i.producer_already_created {
			return
		}
		go i.produce(mut ctx)
		i.producer_already_created = true
	}
}

fn (mut i ChannelIterable) produce(mut ctx context.Context) {
	defer {
		lock i.subscribers {
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
			lock i.subscribers {
				for subscriber in i.subscribers {
					subscriber <- item
				}
			}
		}
		else {
			if i.next.len == 0 && i.next.closed {
				return
			}
		}
	} {
		// do nothing
	}
}
