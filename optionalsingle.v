module rxv

import context

pub const (
	// optional_single_empty is the constant returned when an OptionalSingle is empty
	optional_single_empty = Item{}
)

// OptionalSingle is an optional single
pub interface OptionalSingle {
	Iterable
mut:
	get(opts ...RxOption) ?Item
	map(apply Func, opts ...RxOption) Single
	run(opts ...RxOption) chan int
}
