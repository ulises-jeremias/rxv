module rxv

import context

struct EventSourceIterable {
	opts []RxOption
mut:
	observers shared []chan Item
	disposed  shared bool
}

fn new_event_source_iterable(mut ctx context.Context, next chan Item, strategy BackpressureStrategy, opts ...RxOption) Iterable {
	mut iterable := &EventSourceIterable{
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
	lock i.observers, i.disposed {
		for observer in i.observers {
			observer.close()
		}
		i.disposed = true
	}
}

fn (mut i EventSourceIterable) deliver(item Item, mut ctx context.Context, next chan Item, strategy BackpressureStrategy) bool {
	lock i.observers {
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
	}
	return false
}

fn (mut i EventSourceIterable) observe(opts ...RxOption) chan Item {
	mut options := i.opts.clone()
	options << opts.clone()
	option := parse_options(...options)
	next := option.build_channel()

	lock i.observers, i.disposed {
		if i.disposed {
			next.close()
		} else {
			i.observers << next
		}
	}

	return next
}
