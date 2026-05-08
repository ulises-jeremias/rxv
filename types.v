module rxv

import context

// ProducerFn[T] sends items onto a channel given a context.
pub type ProducerFn[T] = fn (mut ctx context.Context, ch chan Item[T])

// MapFn[T, U] transforms a T value into a U, or returns an error.
pub type MapFn[T, U] = fn (value T) ?U

// PredicateFn[T] tests a value; return true to keep it.
pub type PredicateFn[T] = fn (value T) bool

// NextFn[T] is called for each next value in for_each.
pub type NextFn[T] = fn (value T)

// ErrFn is called when an error item is received.
pub type ErrFn = fn (err IError)

// CompletedFn is called when the stream completes.
pub type CompletedFn = fn ()

// BackpressureStrategy controls how full channels are handled.
pub enum BackpressureStrategy {
	block
	drop
}

// OnErrorStrategy controls operator behaviour on errors.
pub enum OnErrorStrategy {
	stop_on_error
	continue_on_error
}

// ObservationStrategy controls eager vs lazy subscription.
pub enum ObservationStrategy {
	lazy
	eager
}
