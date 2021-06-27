module rxv

import context

pub const (
	// optional_single_empty is the constant returned when an OptionalSingle is empty
	optional_single_empty = Item{}
)

// OptionalSingle is an optional single
pub interface OptionalSingle {
	Iterable
	get(opts ...RxOption) ?Item
	map(apply Func, opts ...RxOption) Single
	run(opts ...RxOption) chan int
}

// OptionalSingleImpl is the default implementation for OptionalSingle
pub struct OptionalSingleImpl {
	iterable Iterable
	parent   context.Context
}

// observe observes an OptionalSingle by returning its channel.
fn (o &OptionalSingleImpl) observe(opts ...RxOption) chan Item {
	return o.iterable.observe(...opts)
}

// get returns the item or rxv.optional_empty. The error returned is if the context has been canceled.
// this method is blocking.
pub fn (o &OptionalSingleImpl) get(opts ...RxOption) ?Item {
	option := parse_options(...opts)
	ctx := option.build_context(o.parent)

	observe := o.observe(...opts)
	done := ctx.done()

	for {
		select {
			_ := <-done {
				err := ctx.err()
				if err is none {
					return Item{}
				}
				return err
			}
			v := <-observe {
				return v
			}
		}
	}
	return rxv.optional_single_empty
}

// map transforms the items emitted by an optional_single by applying a function to each item
pub fn (o &OptionalSingleImpl) map(apply Func, opts ...RxOption) OptionalSingle {
	return optional_single(o.parent, o, fn () {
		return &MapOperatorOptionalSingle{
			apply: unsafe { voidptr(0) } // apply
		}
	}, false, true, ...opts)
}

// run creates an observer without consuming the emitted items
pub fn (o &OptionalSingleImpl) run(opts ...RxOption) chan int {
	dispose := chan int{}
	option := parse_options(...opts)
	ctx := option.build_context(o.parent)

	observe := o.observe(...opts)

	go fn (dispose chan int, ctx context.Context, observe chan Item) {
		defer {
			dispose.close()
		}

		done := ctx.done()
		for {
			select {
				_ := <-done {
					return
				}
				_ := <-observe {}
			}
		}
	}(dispose, ctx, observe)

	return dispose
}
