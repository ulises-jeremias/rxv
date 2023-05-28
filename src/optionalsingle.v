module rxv

import context

// OptionalSingle is an optional single
pub interface OptionalSingle {
	Iterable
mut:
	get(opts ...RxOption) ?Item
	map(apply Func, opts ...RxOption) Single
	run(opts ...RxOption) chan int
}

// OptionalSingleImpl is the default implementation for OptionalSingle
pub struct OptionalSingleImpl {
mut:
	iterable Iterable
	parent   context.Context
}

pub fn (o OptionalSingleImpl) str() string {
	return 'OptionalSingleImpl'
}

// observe observes an OptionalSingle by returning its channel.
fn (mut o OptionalSingleImpl) observe(opts ...RxOption) chan Item {
	return o.iterable.observe(...opts)
}

// get returns the item or rxv.optional_empty. The error returned is if the context has been canceled.
// this method is blocking.
pub fn (mut o OptionalSingleImpl) get(opts ...RxOption) ?Item {
	option := parse_options(...opts)
	mut ctx := option.build_context(o.parent)

	observe := o.observe(...opts)
	done := ctx.done()

	for select {
		_ := <-done {
			err := ctx.err()
			if err is none {
				return empty_item()
			} else {
				return none
			}
		}
		v := <-observe {
			return v
		}
	} {
		// do nothing
	}
	return empty_item()
}

struct MapOperatorOptionalSingle {
	apply Func
}

fn (op &MapOperatorOptionalSingle) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	match item.value {
		ItemValue {
			if res := op.apply(mut ctx, item.value) {
				dst <- of(res)
			} else {
				dst <- from_error(err)
				operator_options.stop()
			}
		}
		else {}
	}
}

fn (op &MapOperatorOptionalSingle) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut ctx, item, dst, operator_options)
}

fn (op &MapOperatorOptionalSingle) end(mut _ context.Context, _ chan Item) {}

fn (op &MapOperatorOptionalSingle) gather_next(mut _ context.Context, item Item, dst chan Item, _ OperatorOptions) {
	match item.value {
		ItemValue {
			if item.value !is MapOperatorOptionalSingle {
				dst <- item
			}
		}
		else {}
	}
}

// map transforms the items emitted by an optional_single by applying a function to each item
pub fn (mut o OptionalSingleImpl) map(apply Func, opts ...RxOption) Single {
	// return single(o.parent, mut o, fn [apply] () Operator {
	// 	return &MapOperatorOptionalSingle{
	// 		apply: apply
	// 	}
	// }, false, true, ...opts)
	return &SingleImpl{}
}

// run creates an observer without consuming the emitted items
pub fn (mut o OptionalSingleImpl) run(opts ...RxOption) chan int {
	dispose := chan int{}
	option := parse_options(...opts)
	mut ctx := option.build_context(o.parent)

	observe := o.observe(...opts)

	spawn fn (dispose chan int, mut ctx context.Context, observe chan Item) {
		defer {
			dispose.close()
		}

		done := ctx.done()
		for select {
			_ := <-done {
				return
			}
			_ := <-observe {}
		} {
			// do nothing
		}
	}(dispose, mut &ctx, observe)

	return dispose
}