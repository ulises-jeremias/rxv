module rxv

import context
import sync

struct EventSourceIterable {
	opts []RxOption
mut:
	observers []chan Item
	disposed  bool
	mutex     &sync.Mutex
}

fn new_event_source_iterable(mut ctx context.Context, next chan Item, strategy BackpressureStrategy, opts ...RxOption) Iterable {
	mut iterable := &EventSourceIterable{
		mutex: sync.new_mutex()
		opts: opts
	}

	spawn fn (mut i EventSourceIterable, mut ctx context.Context, next chan Item, strategy BackpressureStrategy) {
		defer {
			i.close_all_observers()
		}

		done := ctx.done()

		for select {
			_ := <-done {
				return
			}
			item := <-next {
				if i.deliver(item, mut ctx, next, strategy) {
					return
				}
			}
		} {
		}
	}(mut iterable, mut ctx, next, strategy)

	return iterable
}

fn (mut i EventSourceIterable) close_all_observers() {
	i.mutex.@lock()
	for observer in i.observers {
		observer.close()
	}
	i.disposed = true
	i.mutex.unlock()
}

fn (mut i EventSourceIterable) deliver(item Item, mut ctx context.Context, next chan Item, strategy BackpressureStrategy) bool {
	i.mutex.@lock()
	match strategy {
		.block {
			for observer in i.observers {
				if !item.send_context(mut ctx, observer) {
					return true
				}
			}
		}
		.drop {
			for observer in i.observers {
				done := ctx.done()
				select {
					_ := <-done {
						return true
					}
					observer <- item {}
					else {}
				}
			}
		}
	}
	i.mutex.unlock()
	return false
}

fn (mut i EventSourceIterable) observe(opts ...RxOption) chan Item {
	mut options := i.opts.clone()
	options << opts.clone()
	option := parse_options(...options)
	next := option.build_channel()

	i.mutex.@lock()
	if i.disposed {
		next.close()
	} else {
		i.observers << next
	}
	i.mutex.unlock()

	return next
}
