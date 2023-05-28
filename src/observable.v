module rxv

import context
import time

pub type DistributionFn = fn (item Item) int

pub type DistributionStrFn = fn (item Item) string

pub type FactoryFn = fn () ItemValue

pub type IdentifierFn = fn (value ItemValue) int

pub type IterableFactoryFn = fn (mut ctx context.Context, next chan Item, option RxOption, opts ...RxOption)

pub type RetryFn = fn (err IError) bool

pub type TimeExtractorFn = fn (value ItemValue) time.Time

// Observable is the standard interface for Observables.
pub interface Observable {
	Iterable
}
