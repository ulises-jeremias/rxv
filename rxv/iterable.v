module rxv

// Iterable is the basic type that can be observed
pub interface Iterable {
	observe(opts ...Option) chan Item
}
