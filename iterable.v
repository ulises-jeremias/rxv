module rxv

const (
	empty_context = voidptr(0)
)

// Iterable is the basic type that can be observed
pub interface Iterable {
mut:
	observe(opts ...RxOption) chan Item
}
