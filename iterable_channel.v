module rxv

import context
import sync

struct ChannelIterable {
	next chan Item
	opts []RxOption
mut:
	mutex                    &sync.Mutex
	subscribers              []chan Item
	producer_already_created bool
}

fn new_channel_iterable(next chan Item, opts ...RxOption) Iterable {
	return &ChannelIterable{
		mutex: sync.new_mutex()
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
		i.connect(mut &ctx)
	}

	ch := option.build_channel()

	i.mutex.@lock()
	i.subscribers << ch
	i.mutex.unlock()

	return ch
}

fn (mut i ChannelIterable) connect(mut ctx context.Context) {
	go i.produce(ctx)
	i.mutex.@lock()
	i.producer_already_created = true
	i.mutex.unlock()
}

fn (mut i ChannelIterable) produce(mut ctx context.Context) {
	defer {
		for subscriber in i.subscribers {
			subscriber.close()
		}
	}

	cdone := ctx.done()

	for select {
		_ := <-cdone {
			return
		}
		item := <-i.next {
			// i.mutex.@lock()
			for subscriber in i.subscribers {
				subscriber <- item
			}
			// i.mutex.unlock()
		}
	} {
	}
}
