module rxv

import context
import sync

type OperatorFactoryFn = fn () Operator

fn run_sequential(mut ctx context.Context, next chan Item, mut iterable Iterable, operator_factory OperatorFactoryFn, option RxOption, opts ...RxOption) {
	mut observe := iterable.observe(...opts)
	go fn [mut observe, opts] (mut ctx context.Context, next chan Item, operator_factory OperatorFactoryFn, option RxOption) {
		mut op := operator_factory()
		mut stopped := false
		operator := OperatorOptions{
			stop: fn [option, mut stopped] () {
				if option.get_error_strategy() == .stop_on_error {
					stopped = true
				}
			}
			reset_iterable: fn [mut observe, opts] (mut new_iterable Iterable) {
				observe = new_iterable.observe(...opts)
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
						op.err(mut &ctx, item, next, operator)
					} else {
						op.gather_next(mut &ctx, item, next, operator)
					}
				}
			}
		}
		op.end(mut &ctx, next)
		next.close()
	}(mut &ctx, next, operator_factory, option)
}

fn run_parallel(mut ctx context.Context, next chan Item, observe chan Item, operator_factory OperatorFactoryFn, bypass_gather bool, option RxOption, opts ...RxOption) {
	mut wg := sync.new_waitgroup()
	mut observe_ := observe
	pool := option.get_pool() or { 0 }
	wg.add(pool)

	mut gather := chan Item{}
	if bypass_gather {
		gather = next
	} else {
		gather = chan Item{cap: 1}

		// gather
		go fn [mut observe_, opts] (mut ctx context.Context, next chan Item, gather chan Item, operator_factory OperatorFactoryFn, bypass_gather bool, option RxOption) {
			mut op := operator_factory()
			mut stopped := false
			operator := OperatorOptions{
				stop: fn [option, mut stopped] () {
					if option.get_error_strategy() == .stop_on_error {
						stopped = true
					}
				}
				reset_iterable: fn [mut observe_, opts] (mut new_iterable Iterable) {
					observe_ = new_iterable.observe(...opts)
				}
			}

			for select {
				item := <-gather {
					if stopped {
						break
					}
					if item.is_error() {
						op.err(mut &ctx, item, next, operator)
					} else {
						op.gather_next(mut &ctx, item, next, operator)
					}
				}
			} {
			}
			op.end(mut &ctx, next)
			next.close()
		}(mut &ctx, next, gather, operator_factory, bypass_gather, option)
	}

	// scatter
	for i in 0 .. pool {
		go fn [mut observe_, opts] (mut wg sync.WaitGroup, mut ctx context.Context, gather chan Item, operator_factory OperatorFactoryFn, option RxOption) {
			mut op := operator_factory()
			mut stopped := false
			operator := OperatorOptions{
				stop: fn [option, mut stopped] () {
					if option.get_error_strategy() == .stop_on_error {
						stopped = true
					}
				}
				reset_iterable: fn [mut observe_, opts] (mut new_iterable Iterable) {
					observe_ = new_iterable.observe(...opts)
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
					item := <-observe_ {
						if item.is_error() {
							op.err(mut &ctx, item, gather, operator)
						} else {
							op.gather_next(mut &ctx, item, gather, operator)
						}
					}
				}
			}
		}(mut wg, mut &ctx, gather, operator_factory, option)
	}

	go fn (mut wg sync.WaitGroup, gather chan Item) {
		wg.wait()
		gather.close()
	}(mut wg, gather)
}

fn run_first_item(mut ctx context.Context, f IdentifierFn, notif chan Item, observe chan Item, next chan Item, mut iterable Iterable, operator_factory OperatorFactoryFn, option RxOption, opts ...RxOption) {
	mut observe_ := observe
	go fn [mut observe_, opts] (mut ctx context.Context, f IdentifierFn, notif chan Item, next chan Item, operator_factory OperatorFactoryFn, option RxOption) {
		mut op := operator_factory()
		mut stopped := false
		operator := OperatorOptions{
			stop: fn [option, mut stopped] () {
				if option.get_error_strategy() == .stop_on_error {
					stopped = true
				}
			}
			reset_iterable: fn [mut observe_, opts] (mut new_iterable Iterable) {
				observe_ = new_iterable.observe(...opts)
			}
		}

		done := ctx.done()
		loop: for !stopped {
			select {
				_ := <-done {
					break loop
				}
				item := <-observe_ {
					if item.is_error() {
						op.err(mut &ctx, item, next, operator)
						item.send_context(mut &ctx, notif)
					} else {
						op.gather_next(mut &ctx, item, next, operator)
						of(f(item.value)).send_context(mut &ctx, notif)
					}
				}
			}
		}
		op.end(mut &ctx, next)
		next.close()
	}(mut &ctx, f, notif, next, operator_factory, option)
}
