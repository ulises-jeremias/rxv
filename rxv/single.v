module rxv

import context

// Single is an observable with a single element
pub interface Single {
	Iterable
	filter(apply Predicate, opts ...RxOption) OptionalSingle
	get(opts ...RxOption) ?Item
	map(apply Func, opts ...RxOption) Single
	run(opts ...RxOption) chan int
}

// DefaultSimpleImpl implements Single
pub struct DefaultSimpleImpl {
	parent context.Context
	iterable Iterable
}
