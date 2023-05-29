module rxv

import context

// Iterable is the basic type that can be observed
pub interface Iterable {
mut:
	observe(opts ...RxOption) chan Item
}
