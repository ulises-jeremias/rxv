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
