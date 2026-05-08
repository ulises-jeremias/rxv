module rxv

import context

// RxOption is a functional option applied to an Options struct.
pub type RxOption = fn (mut options Options)

// Options holds resolved operator configuration.
pub struct Options {
mut:
	buffer_size    int
	pool           int
	ctx            context.Context
	eager          bool
	error_strategy OnErrorStrategy
}

// parse_options merges a list of RxOption functions into an Options value.
pub fn parse_options(opts ...RxOption) Options {
	mut o := Options{
		ctx: context.background()
	}
	for opt in opts {
		opt(mut o)
	}
	return o
}

// build_channel_t creates a typed buffered channel.
pub fn (o Options) build_channel_t[T]() chan Item[T] {
	return chan Item[T]{cap: o.buffer_size}
}

// build_context returns the context for an operator.
pub fn (mut o Options) build_context(parent context.Context) context.Context {
	// If a custom ctx was set and isn't cancelled, prefer it; otherwise use parent.
	if o.ctx.err() !is none {
		return o.ctx
	}
	return parent
}

// get_pool returns the pool size if set.
pub fn (o Options) get_pool() ?int {
	if o.pool > 0 {
		return o.pool
	}
	return none
}

pub fn (o Options) is_eager_observation() bool {
	return o.eager
}

// --- built-in option constructors ---

pub fn with_buffer_size(n int) RxOption {
	return fn [n] (mut o Options) {
		o.buffer_size = n
	}
}

pub fn with_pool(n int) RxOption {
	return fn [n] (mut o Options) {
		o.pool = n
	}
}

pub fn with_context(ctx context.Context) RxOption {
	return fn [ctx] (mut o Options) {
		o.ctx = ctx
	}
}

pub fn with_eager_observation() RxOption {
	return fn (mut o Options) {
		o.eager = true
	}
}

pub fn with_error_strategy(strategy OnErrorStrategy) RxOption {
	return fn [strategy] (mut o Options) {
		o.error_strategy = strategy
	}
}
