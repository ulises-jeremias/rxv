module rxv

// Iterable[T] is the base interface for anything that can be observed.
pub interface Iterable[T] {
mut:
	observe(opts ...RxOption) chan Item[T]
}

// NOTE: Observable[T] as a generic interface with generic method params (like
// filter(PredicateFn[T])) is not yet fully supported by the V compiler — the
// interface check fails to substitute T in method signatures. We therefore
// expose ObservableImpl[T] directly as the public API. The Observable[T]
// interface is kept minimal (only observe) for use where a common supertype
// is needed without operators.
pub interface Observable[T] {
	Iterable[T]
}
