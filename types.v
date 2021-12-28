module rxv

import context

struct OperatorOptions {
	stop           fn ()
	reset_iterable fn (mut Iterable)
}

// Comparator defines a func that returns an int:
// - 0 if two elements are equals
// - A negative value if the first argument is less than the second
// - A positive value if the first argument is greater than the second
pub type Comparator = fn (a ItemValue, b ItemValue) int

// ItemToObservable defines a function that computes an observable from an item.
// pub type ItemToObservable = fn (item Item) Observable

// ErrorToObservable defines a function that transforms an observable from an string.
// pub type ErrorToObservable = fn (err IError) Observable

// Func defines a function that computes a value from an input value.
pub type Func = fn (mut ctx context.Context, arg ItemValue) ?ItemValue

// Func2 defines a function that computes a value from two input values.
pub type Func2 = fn (mut ctx context.Context, a ItemValue, b ItemValue) ?ItemValue

// FuncN defines a function that computes a value from N input values.
pub type FuncN = fn (args ...ItemValue) ItemValue

// ErrorFunc defines a function that computes a value from an string.
pub type ErrorFunc = fn (err IError) ItemValue

// Predicate defines a func that returns a bool from an input value.
pub type Predicate = fn (ItemValue) bool

// Marshaller defines a marshaller type (ItemValue to []byte).
pub type Marshaller = fn (ItemValue) ?[]byte

// Unmarshaller defines an unmarshaller type ([]byte to interface).
pub type Unmarshaller = fn ([]byte, ItemValue) string

// Producer defines a producer implementation.
pub type Producer = fn (mut ctx context.Context, next chan Item)

// Supplier defines a function that supplies a result from nothing.
pub type Supplier = fn (mut ctx context.Context) Item

// Disposed is a notification channel indicating when an Observable is closed.
// pub type Disposed = chan int

// Disposable is a function to be called in order to dispose a subscription.
// pub type Disposable = context.CancelFn

// NextFunc handles a next item in a stream.
pub type NextFunc = fn (arg ItemValue)

// ErrFunc handles an string in a stream.
pub type ErrFunc = fn (err IError)

// CompletedFunc handles the end of a stream.
pub type CompletedFunc = fn ()

// BackpressureStrategy is the backpressure strategy type.
pub enum BackpressureStrategy {
	// block blocks until the channel is available.
	block
	// drop drops the message.
	drop
}

// OnErrorStrategy is the Observable error strategy.
pub enum OnErrorStrategy {
	// stop_on_error is the default error strategy.
	// An operator will stop processing items on error.
	stop_on_error
	// continue_on_error means an operator will continue processing items after an error.
	continue_on_error
}

// ObservationStrategy defines the strategy to consume from an Observable.
pub enum ObservationStrategy {
	// lazy is the default observation strategy, when an Observer subscribes.
	lazy
	// eager means consuming as soon as the Observable is created.
	eager
}
