module rxv

import context

// Single is an observable with a single element
pub interface Single {
	Iterable
mut:
	observe(opts ...RxOption) chan Item
	filter(apply Predicate, opts ...RxOption) OptionalSingle
	get(opts ...RxOption) ?Item
	map(apply Func, opts ...RxOption) Single
	run(opts ...RxOption) chan int
}

// SingleImpl implements Single
pub struct SingleImpl {
mut:
	iterable Iterable
	parent   context.Context
}

pub fn (o SingleImpl) str() string {
	return 'SingleImpl'
}

// observe observes an OptionalSingle by returning its channel.
fn (mut o SingleImpl) observe(opts ...RxOption) chan Item {
	return o.iterable.observe(...opts)
}

// get returns the item. The error returned is if the context has been cancelled.
// This method is blocking.
pub fn (mut o SingleImpl) get(opts ...RxOption) ?Item {
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

struct FilterOperatorSingle {
	apply Predicate
}

fn (op &FilterOperatorSingle) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	match item.value {
		ItemValue {
			if op.apply(item.value) {
				item.send_context(mut ctx, dst)
			}
		}
		else {}
	}
}

fn (op &FilterOperatorSingle) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut ctx, item, dst, operator_options)
}

fn (op &FilterOperatorSingle) end(mut _ context.Context, _ chan Item) {}

fn (op &FilterOperatorSingle) gather_next(mut _ context.Context, item Item, dst chan Item, _ OperatorOptions) {}

// filter amits only those items from an Observable that pass a predicate test
pub fn (mut s SingleImpl) filter(apply Predicate, opts ...RxOption) OptionalSingle {
	return optional_single(s.parent, mut s, fn [apply] () Operator {
		return &FilterOperatorSingle{
			apply: apply
		}
	}, true, true, ...opts)
}

struct MapOperatorSingle {
	apply Func
}

fn (op &MapOperatorSingle) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
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

fn (op &MapOperatorSingle) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut ctx, item, dst, operator_options)
}

fn (op &MapOperatorSingle) end(mut _ context.Context, _ chan Item) {}

fn (op &MapOperatorSingle) gather_next(mut _ context.Context, item Item, dst chan Item, _ OperatorOptions) {
	match item.value {
		ItemValue {
			if item.value !is MapOperatorSingle {
				dst <- item
			}
		}
		else {}
	}
}

// map transforms the items emitted by an optional_single by applying a function to each item
pub fn (mut o SingleImpl) map(apply Func, opts ...RxOption) Single {
	return single(o.parent, mut o, fn [apply] () Operator {
		return &MapOperatorSingle{
			apply: apply
		}
	}, false, true, ...opts)
}

// run creates an observer without consuming the emitted items
pub fn (mut o SingleImpl) run(opts ...RxOption) chan int {
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
			else {
				if observe.len == 0 && observe.closed {
					return
				}
			}
		} {
			// do nothing
		}
	}(dispose, mut &ctx, observe)

	return dispose
}
