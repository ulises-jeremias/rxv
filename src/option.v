module rxv

import context
import context.onecontext
import runtime

const (
	empty_context = context.EmptyContext(2)
)

type SerializedFn = fn (ItemValue) int

type FuncOptionMutation = fn (mut fdo FuncOption)

// Options handles configurable options
pub interface RxOption {
	apply(mut fdo FuncOption)
	to_propagate() bool
	is_eager_observation() bool
	get_pool() ?int
	build_channel() chan Item
	build_context(parent context.Context) context.Context
	get_back_pressure_strategy() BackpressureStrategy
	get_error_strategy() OnErrorStrategy
	is_connectable() bool
	is_connect_operation() bool
	is_serialized() ?SerializedFn
}

// DefaultFuncOption
struct FuncOption {
	f FuncOptionMutation
mut:
	is_buffer              bool
	buffer                 int
	ctx                    context.Context
	observation            ObservationStrategy
	pool                   int
	back_pressure_strategy BackpressureStrategy
	on_error_strategy      OnErrorStrategy
	propagate              bool
	connectable            bool
	connect_operation      bool
	serialized             SerializedFn
}

pub fn (o FuncOption) str() string {
	return 'FuncOption'
}

fn (fdo &FuncOption) to_propagate() bool {
	return fdo.propagate
}

fn (fdo &FuncOption) is_eager_observation() bool {
	return fdo.observation == .eager
}

fn (fdo &FuncOption) get_pool() ?int {
	if fdo.pool > 0 {
		return fdo.pool
	}
	return none
}

fn (fdo &FuncOption) build_channel() chan Item {
	if fdo.is_buffer {
		return chan Item{cap: fdo.buffer}
	}
	return chan Item{cap: 1}
}

fn (fdo &FuncOption) build_context(parent context.Context) context.Context {
	println('JEJE ${isnil(fdo.ctx)} ${isnil(parent)}')
	// TODO: check the best way to check if the context is empty
	if !isnil(fdo.ctx) && !isnil(parent) {
		ctx, _ := onecontext.merge(fdo.ctx, parent)
		return ctx
	}

	if !isnil(fdo.ctx) {
		return fdo.ctx
	}

	if !isnil(parent) {
		return parent
	}

	return context.background()
}

fn (fdo &FuncOption) get_back_pressure_strategy() BackpressureStrategy {
	return fdo.back_pressure_strategy
}

fn (fdo &FuncOption) get_error_strategy() OnErrorStrategy {
	return fdo.on_error_strategy
}

fn (fdo &FuncOption) is_connectable() bool {
	return fdo.connectable
}

fn (fdo &FuncOption) is_connect_operation() bool {
	return fdo.connect_operation
}

fn (fdo &FuncOption) apply(mut do FuncOption) {
	fdo.f(mut do)
}

fn (fdo &FuncOption) is_serialized() ?SerializedFn {
	if isnil(fdo.serialized) {
		return none
	}
	return fdo.serialized
}

fn new_func_option(f FuncOptionMutation) RxOption {
	return &FuncOption{
		f: f
	}
}

fn parse_options(opts ...RxOption) RxOption {
	mut o := &FuncOption{}
	for opt in opts {
		opt.apply(mut o)
	}
	return o
}

// with_buffered_channel allows to configure the capacity of a buffered channel.
pub fn with_buffered_channel(capacity int) RxOption {
	func := fn [capacity] (mut options FuncOption) {
		options.is_buffer = true
		options.buffer = capacity
	}
	return new_func_option(FuncOptionMutation(func))
}

// with_context allows to pass a context.
pub fn with_context(mut ctx context.Context) RxOption {
	func := fn [mut ctx] (mut options FuncOption) {
		options.ctx = ctx
	}
	return new_func_option(FuncOptionMutation(func))
}

// with_observation_strategy uses the eager observation mode meaning consuming the items even with_out subscription.
pub fn with_observation_strategy(strategy ObservationStrategy) RxOption {
	func := fn [strategy] (mut options FuncOption) {
		options.observation = strategy
	}
	return new_func_option(FuncOptionMutation(func))
}

// with_pool allows to specify an execution pool.
pub fn with_pool(pool int) RxOption {
	func := fn [pool] (mut options FuncOption) {
		options.pool = pool
	}
	return new_func_option(FuncOptionMutation(func))
}

// with_cpu_pool allows to specify an execution pool based on the number of logical CPUs.
pub fn with_cpu_pool() RxOption {
	func := fn (mut options FuncOption) {
		options.pool = runtime.nr_cpus()
	}
	return new_func_option(FuncOptionMutation(func))
}

// with_back_pressure_strategy sets the back pressure strategy: drop or block.
pub fn with_back_pressure_strategy(strategy BackpressureStrategy) RxOption {
	func := fn [strategy] (mut options FuncOption) {
		options.back_pressure_strategy = strategy
	}
	return new_func_option(FuncOptionMutation(func))
}

// with_error_strategy defines how an observable should deal with_ error.
// This strategy is propagated to the parent observable.
pub fn with_error_strategy(strategy OnErrorStrategy) RxOption {
	func := fn [strategy] (mut options FuncOption) {
		options.on_error_strategy = strategy
	}
	return new_func_option(FuncOptionMutation(func))
}

// with_publish_strategy converts an ordinary Observable into a connectable Observable.
pub fn with_publish_strategy() RxOption {
	func := fn (mut options FuncOption) {
		options.connectable = true
	}
	return new_func_option(FuncOptionMutation(func))
}

// serialize forces an Observable to make serialized calls and to be well-behaved.
pub fn serialize(identifier SerializedFn) RxOption {
	func := fn [identifier] (mut options FuncOption) {
		options.serialized = identifier
	}
	return new_func_option(FuncOptionMutation(func))
}

fn connect() RxOption {
	func := fn (mut options FuncOption) {
		options.connect_operation = true
	}
	return new_func_option(FuncOptionMutation(func))
}
