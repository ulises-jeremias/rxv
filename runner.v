module rxv

import context

type OperatorFactoryFn = fn () Operator

fn run_sequential(mut ctx context.Context, next chan Item, mut iterable Iterable, operator_factory OperatorFactoryFn, option RxOption, opts ...RxOption) {
	go fn (mut ctx context.Context, next chan Item, mut iterable Iterable, operator_factory OperatorFactoryFn, option RxOption, opts []RxOption) {
		mut observe := iterable.observe(...opts)
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
	}(mut &ctx, next, mut iterable, operator_factory, option, opts)
}

fn run_first_item(mut ctx context.Context, f IdentifierFn, notif chan Item, observe chan Item, next chan Item, mut iterable Iterable, operator_factory OperatorFactoryFn, option RxOption, opts ...RxOption) {
	go fn (mut ctx context.Context, f IdentifierFn, notif chan Item, observe chan Item, next chan Item, operator_factory OperatorFactoryFn, option RxOption, opts []RxOption) {
		mut observe_ := observe
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
						id := f(item.value)
						of(id).send_context(mut &ctx, notif)
					}
				}
			}
		}
		op.end(mut &ctx, next)
		next.close()
	}(mut &ctx, f, notif, observe, next, operator_factory, option, opts)
}
