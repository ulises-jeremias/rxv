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
		for !stopped {
			select {
				_ := <-done {
					break
				}
				item := <-observe {
					if item.is_error() {
						op.err(mut ctx, item, next, operator)
					} else {
						op.next(mut ctx, item, next, operator)
					}
				}
				else {
					break
				}
			}
		}
		op.end(mut ctx, next)
		next.close()
	}(mut ctx, next, operator_factory, option)
}

fn run_parallel(mut ctx context.Context, next chan Item, observe chan Item, operator_factory OperatorFactoryFn, bypass_gather bool, option RxOption, opts ...RxOption) {
	mut wg := sync.new_waitgroup()
	mut observe_copy := observe
	pool := option.get_pool() or { 0 }
	wg.add(pool)

	mut gather := next
	if !bypass_gather {
		gather = chan Item{cap: 1}

		// gather
		go fn [mut observe_copy, opts, gather] (mut ctx context.Context, next chan Item, operator_factory OperatorFactoryFn, option RxOption) {
			mut op := operator_factory()
			mut stopped := false
			operator := OperatorOptions{
				stop: fn [option, mut stopped] () {
					if option.get_error_strategy() == .stop_on_error {
						stopped = true
					}
				}
				reset_iterable: fn [mut observe_copy, opts] (mut new_iterable Iterable) {
					observe_copy = new_iterable.observe(...opts)
				}
			}

			for select {
				item := <-gather {
					if stopped {
						break
					}
					if item.is_error() {
						op.err(mut ctx, item, next, operator)
					} else {
						op.gather_next(mut ctx, item, next, operator)
					}
				}
			} {
				// do nothing
			}
			op.end(mut ctx, next)
			next.close()
		}(mut ctx, next, operator_factory, option)
	}

	// scatter
	for i in 0 .. pool {
		go fn [mut observe_copy, opts, gather, bypass_gather] (mut wg sync.WaitGroup, mut ctx context.Context, operator_factory OperatorFactoryFn, option RxOption) {
			mut op := operator_factory()
			mut stopped := false
			operator := OperatorOptions{
				stop: fn [option, mut stopped] () {
					if option.get_error_strategy() == .stop_on_error {
						stopped = true
					}
				}
				reset_iterable: fn [mut observe_copy, opts] (mut new_iterable Iterable) {
					observe_copy = new_iterable.observe(...opts)
				}
			}

			defer {
				wg.done()
			}

			done := ctx.done()
			for !stopped {
				select {
					_ := <-done {
						break
					}
					item := <-observe_copy {
						if item.is_error() {
							op.err(mut ctx, item, gather, operator)
						} else {
							op.gather_next(mut ctx, item, gather, operator)
						}
					}
					else {
						if observe_copy.len == 0 && observe_copy.closed {
							if !bypass_gather {
								of(op as ItemValue).send_context(mut ctx, gather)
							}
							break
						}
					}
				}
			}
		}(mut wg, mut ctx, operator_factory, option)
	}

	go fn (mut wg sync.WaitGroup, gather chan Item) {
		wg.wait()
		gather.close()
	}(mut wg, gather)
}

fn run_first_item(mut ctx context.Context, f IdentifierFn, notif chan Item, observe chan Item, next chan Item, mut iterable Iterable, operator_factory OperatorFactoryFn, option RxOption, opts ...RxOption) {
	mut observe_copy := observe
	go fn [mut observe_copy, opts, f, notif] (mut ctx context.Context, next chan Item, operator_factory OperatorFactoryFn, option RxOption) {
		mut op := operator_factory()
		mut stopped := false
		operator := OperatorOptions{
			stop: fn [option, mut stopped] () {
				if option.get_error_strategy() == .stop_on_error {
					stopped = true
				}
			}
			reset_iterable: fn [mut observe_copy, opts] (mut new_iterable Iterable) {
				observe_copy = new_iterable.observe(...opts)
			}
		}

		done := ctx.done()
		for !stopped {
			select {
				_ := <-done {
					break
				}
				item := <-observe_copy {
					if item.is_error() {
						op.err(mut ctx, item, next, operator)
					} else {
						op.gather_next(mut ctx, item, next, operator)
						next_val := f(unsafe { item.value })
						of(next_val).send_context(mut ctx, notif)
					}
				}
				else {
					break
				}
			}
		}
		op.end(mut ctx, next)
		next.close()
	}(mut ctx, next, operator_factory, option)
}
