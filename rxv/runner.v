module rxv

import context
import sync

type OperatorFactoryFn = fn () Operator

fn run_sequential(ctx context.Context, next chan Item, iterable Iterable, operator_factory OperatorFactoryFn, option RxOption, opts ...RxOption) {
	observe := iterable.observe(...opts)
	go fn (ctx context.Context, next chan Item, observe chan Item, operator_factory OperatorFactoryFn, option RxOption) {
		op := operator_factory()
		stopped := false
		operator := OperatorOptions{
			stop: fn () {
				// @todo: Fix once closures are supported
				// if option.get_error_strategy() == .stop_on_error {
				// 	stopped = true
				// }
			}
			reset_iterable: fn (new_iterable Iterable) {
				// @todo: Fix once closures are supported
				// observe = new_iterable.observe(...opts)
			}
		}

		done := ctx.done()
		loop: for !stopped {
			select {
				_ := <-done {
					break loop
				}
				item := <-observe {
					if item.is_error() {
						op.err(ctx, item, next, operator)
					} else {
						op.gather_next(ctx, item, next, operator)
					}
				}
			}
		}
		op.end(ctx, next)
		next.close()
	}(ctx, next, observe, operator_factory, option)
}

fn run_parallel(ctx context.Context, next chan Item, observe chan Item, operator_factory OperatorFactoryFn, bypass_gather bool, option RxOption, opts ...RxOption) {
	mut wg := sync.new_waitgroup()
	pool := option.get_pool() or { 0 }
	wg.add(pool)

	mut gather := chan Item{}
	if bypass_gather {
		gather = next
	} else {
		gather = chan Item{cap: 1}

		// gather
		go fn (ctx context.Context, next chan Item, gather chan Item, observe chan Item, operator_factory OperatorFactoryFn, bypass_gather bool, option RxOption) {
			op := operator_factory()
			stopped := false
			operator := OperatorOptions{
				stop: fn () {
					// @todo: Fix once closures are supported
					// if option.get_error_strategy() == .stop_on_error {
					// 	stopped = true
					// }
				}
				reset_iterable: fn (new_iterable Iterable) {
					// @todo: Fix once closures are supported
					// observe = new_iterable.observe(...opts)
				}
			}

			for select {
				item := <-gather {
					if stopped {
						break
					}
					if item.is_error() {
						op.err(ctx, item, next, operator)
					} else {
						op.gather_next(ctx, item, next, operator)
					}
				}
			} {
			}
			op.end(ctx, next)
			next.close()
		}(ctx, next, gather, observe, operator_factory, bypass_gather, option)
	}

	// scatter
	for i in 0 .. pool {
		go fn (mut wg sync.WaitGroup, ctx context.Context, gather chan Item, observe chan Item, operator_factory OperatorFactoryFn, option RxOption) {
			op := operator_factory()
			stopped := false
			operator := OperatorOptions{
				stop: fn () {
					// @todo: Fix once closures are supported
					// if option.get_error_strategy() == .stop_on_error {
					// 	stopped = true
					// }
				}
				reset_iterable: fn (new_iterable Iterable) {
					// @todo: Fix once closures are supported
					// observe = new_iterable.observe(...opts)
				}
			}

			defer {
				wg.done()
			}

			done := ctx.done()
			for !stopped {
				select {
					_ := <-done {
						return
					}
					item := <-observe {
						if item.is_error() {
							op.err(ctx, item, gather, operator)
						} else {
							op.gather_next(ctx, item, gather, operator)
						}
					}
				}
			}
		}(mut wg, ctx, gather, observe, operator_factory, option)
	}

	go fn (mut wg sync.WaitGroup, gather chan Item) {
		wg.wait()
		gather.close()
	}(mut wg, gather)
}
