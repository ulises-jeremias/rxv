module rxv

import context
import sync

struct CreateIterable {
	next chan Item
	opts []RxOption
mut:
	mutex                    &sync.Mutex
	subscribers              []chan Item
	producer_already_created bool
}

fn new_create_iterable(fs []Producer, opts ...RxOption) Iterable {
	mut options := opts.clone()
	option := parse_options(...options)
	mut ctx := option.build_context(empty_context)
	next := option.build_channel()

	spawn fn (fs []Producer, next chan Item, mut ctx &context.Context) {
		defer {
			next.close()
		}
		for f in fs {
			f(mut ctx, next)
		}
	}(fs, next, mut &ctx)

	return &CreateIterable{
		mutex: sync.new_mutex()
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
		mut ctx := option.build_context(empty_context)
		i.connect(mut ctx)
	}

	ch := option.build_channel()

	i.mutex.@lock()
	i.subscribers << ch
	i.mutex.unlock()

	return ch
}

fn (mut i CreateIterable) connect(mut ctx context.Context) {
	spawn i.produce(mut ctx)
	i.mutex.@lock()
	i.producer_already_created = true
	i.mutex.unlock()
}

fn (mut i CreateIterable) produce(mut ctx context.Context) {
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
			for subscriber in i.subscribers {
				subscriber <- item
			}
		}
	} {
	}
}
