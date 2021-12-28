module rxv

import context

const (
	empty_context = context.EmptyContext(2)
)

// Iterable is the basic type that can be observed
pub interface Iterable {
mut:
	observe(opts ...RxOption) chan Item
}
