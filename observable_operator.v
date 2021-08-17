module rxv

import context
import time

// all determines whether all items emitted by an Observable meet some criteria
pub fn (o &ObservableImpl) all(predicate Predicate, opts ...RxOption) Single {
	return single(o.parent, o, fn () Operator {
		return &AllOperator{
			// pr, false, false, ...optsedicate: predicate
			all: true
		}
	}, false, false, ...opts)
}

struct AllOperator {
	predicate Predicate
mut:
	all bool
}

fn (mut op AllOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if !op.predicate(item.value) {
		of(false).send_context(ctx, dst)
		op.all = false
		operator_options.stop()
	}
}

fn (op &AllOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

fn (op &AllOperator) end(ctx context.Context, dst chan Item) {
	if op.all {
		of(true).send_context(ctx, dst)
	}
}

fn (mut op AllOperator) gather_next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value as bool
	if value == false {
		of(false).send_context(ctx, dst)
		op.all = false
		operator_options.stop()
	}
}

// average_f32 calculates the average of numbers emitted by an Observable and emits the average f32
pub fn (o &ObservableImpl) average_f32(opts ...RxOption) Single {
	return single(o.parent, o, fn () Operator {
		return &AverageF32Operator{}
	}, false, false, ...opts)
}

struct AverageF32Operator {
mut:
	count f32
	sum   f32
}

fn (mut op AverageF32Operator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value
	match value {
		int {
			op.sum += f32(value)
			op.count++
		}
		f32 {
			op.sum += value
			op.count++
		}
		f64 {
			op.sum += f32(value)
			op.count++
		}
		else {
			error(new_illegal_input_error('expected type: f32, f64 or int, got $item')).send_context(ctx,
				dst)
			operator_options.stop()
		}
	}
}

fn (op &AverageF32Operator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

fn (op &AverageF32Operator) end(ctx context.Context, dst chan Item) {
	if op.count == 0 {
		of(f32(0)).send_context(ctx, dst)
	} else {
		of(f32(op.sum / op.count)).send_context(ctx, dst)
	}
}

fn (mut op AverageF32Operator) gather_next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := &AverageF32Operator(item.value as voidptr)
	op.sum += value.sum
	op.count += value.count
}

// average_f64 calculates the average of numbers emitted by an Observable and emits the average f64
pub fn (o &ObservableImpl) average_f64(opts ...RxOption) Single {
	return single(o.parent, o, fn () Operator {
		return &AverageF64Operator{}
	}, false, false, ...opts)
}

struct AverageF64Operator {
mut:
	count f64
	sum   f64
}

fn (mut op AverageF64Operator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value
	match value {
		int {
			op.sum += f64(value)
			op.count++
		}
		f32 {
			op.sum += f64(value)
			op.count++
		}
		f64 {
			op.sum += value
			op.count++
		}
		else {
			error(new_illegal_input_error('expected type: f32, f64 or int, got $item')).send_context(ctx,
				dst)
			operator_options.stop()
		}
	}
}

fn (op &AverageF64Operator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

fn (op &AverageF64Operator) end(ctx context.Context, dst chan Item) {
	if op.count == 0 {
		of(0.0).send_context(ctx, dst)
	} else {
		of(op.sum / op.count).send_context(ctx, dst)
	}
}

fn (mut op AverageF64Operator) gather_next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := &AverageF64Operator(item.value as voidptr)
	op.sum += value.sum
	op.count += value.count
}

// average_i32 calculates the average of numbers emitted by an Observable and emits the average i32
pub fn (o &ObservableImpl) average_i32(opts ...RxOption) Single {
	return single(o.parent, o, fn () Operator {
		return &AverageIntOperator{}
	}, false, false, ...opts)
}

// average_int calculates the average of numbers emitted by an Observable and emits the average int
pub fn (o &ObservableImpl) average_int(opts ...RxOption) Single {
	return single(o.parent, o, fn () Operator {
		return &AverageIntOperator{}
	}, false, false, ...opts)
}

struct AverageIntOperator {
mut:
	count int
	sum   int
}

fn (mut op AverageIntOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value
	match value {
		int {
			op.sum += value
			op.count++
		}
		else {
			error(new_illegal_input_error('expected type: int, got $item')).send_context(ctx,
				dst)
			operator_options.stop()
		}
	}
}

fn (op &AverageIntOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

fn (op &AverageIntOperator) end(ctx context.Context, dst chan Item) {
	if op.count == 0 {
		of(0).send_context(ctx, dst)
	} else {
		of(op.sum / op.count).send_context(ctx, dst)
	}
}

fn (mut op AverageIntOperator) gather_next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := &AverageIntOperator(item.value as voidptr)
	op.sum += value.sum
	op.count += value.count
}

// average_i16 calculates the average of numbers emitted by an Observable and emits the average i16
pub fn (o &ObservableImpl) average_i16(opts ...RxOption) Single {
	return single(o.parent, o, fn () Operator {
		return &AverageI16Operator{}
	}, false, false, ...opts)
}

struct AverageI16Operator {
mut:
	count i16
	sum   i16
}

fn (mut op AverageI16Operator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value
	match value {
		i16 {
			op.sum += value
			op.count++
		}
		else {
			error(new_illegal_input_error('expected type: i16, got $item')).send_context(ctx,
				dst)
			operator_options.stop()
		}
	}
}

fn (op &AverageI16Operator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

fn (op &AverageI16Operator) end(ctx context.Context, dst chan Item) {
	if op.count == 0 {
		of(0).send_context(ctx, dst)
	} else {
		of(op.sum / op.count).send_context(ctx, dst)
	}
}

fn (mut op AverageI16Operator) gather_next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := &AverageI16Operator(item.value as voidptr)
	op.sum += value.sum
	op.count += value.count
}

// average_i64 calculates the average of numbers emitted by an Observable and emits the average i64
pub fn (o &ObservableImpl) average_i64(opts ...RxOption) Single {
	return single(o.parent, o, fn () Operator {
		return &AverageI64Operator{}
	}, false, false, ...opts)
}

struct AverageI64Operator {
mut:
	count i64
	sum   i64
}

fn (mut op AverageI64Operator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value
	match value {
		i64 {
			op.sum += value
			op.count++
		}
		else {
			error(new_illegal_input_error('expected type: i64, got $item')).send_context(ctx,
				dst)
			operator_options.stop()
		}
	}
}

fn (op &AverageI64Operator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

fn (op &AverageI64Operator) end(ctx context.Context, dst chan Item) {
	if op.count == 0 {
		of(0).send_context(ctx, dst)
	} else {
		of(op.sum / op.count).send_context(ctx, dst)
	}
}

fn (mut op AverageI64Operator) gather_next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := &AverageI64Operator(item.value as voidptr)
	op.sum += value.sum
	op.count += value.count
}

// buffer_with_count returns an Observable that emits buffers of items it collects
// from the source Observable.
// The resulting Observable emits buffers every skip items, each containing a slice of count items.
// When the source Observable completes or encounters an error,
// the resulting Observable emits the current buffer and propagates
// the notification from the source Observable
pub fn (o &ObservableImpl) buffer_with_count(count int, opts ...RxOption) Observable {
	if count <= 0 {
		return thrown(new_illegal_input_error('count must be positive'))
	}

	return observable(o.parent, o, fn [count] () Operator {
		return &BufferWithCountOperator{
			count: count
			buffer: []ItemValue{len: count}
		}
	}, true, false, ...opts)
}

struct BufferWithCountOperator {
mut:
	count   int
	i_count int
	buffer  []ItemValue
}

fn (mut op BufferWithCountOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	op.buffer[op.i_count] = item.value
	op.i_count++
	if op.i_count == op.count {
		of(op.buffer).send_context(ctx, dst)
		op.i_count = 0
		op.buffer = []ItemValue{len: op.count}
	}
}

fn (op &BufferWithCountOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

fn (op &BufferWithCountOperator) end(ctx context.Context, dst chan Item) {
	if op.i_count != 0 {
		of(op.buffer[..op.i_count]).send_context(ctx, dst)
	}
}

fn (op &BufferWithCountOperator) gather_next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {}

// buffer_with_time returns an Observable that emits buffers of items it collects from the source
// Observable. The resulting Observable starts a new buffer periodically, as determined by the
// timeshift argument. It emits each buffer after a fixed timespan, specified by the timespan argument.
// When the source Observable completes or encounters an error, the resulting Observable emits
// the current buffer and propagates the notification from the source Observable.
pub fn (o &ObservableImpl) buffer_with_time(timespan Duration, opts ...RxOption) Observable {
	f := fn [timespan] (ctx context.Context, next chan Item, option Option, opts ...RxOption) {
		observe := o.observe(...opts)
		mut buffer := []ItemValue{}
		stop := chan int{cap: 1}
		mut mutex := sync.new_mutex()

		check_buffer := fn [mut buffer, mut mutex] () {
			mutex.@lock()
			if buffer.len != 0 {
				if !of(buffer).send_context(ctx, next) {
					mutex.unlock()
					return
				}
				buffer = []ItemValue{}
			}
			mutex.unlock()
		}

		go fn [check_buffer] (ctx context.Context, next chan Item, stop chan int, timespan Duration) {
			defer {
				next <- 0
				next.close()
			}

			duration := timespan.duration()
			done := ctx.done()

			for select {
					_ := <-stop {
						check_buffer()
						return
					}
					_ := <-done {
						return
					}
					duration {
						check_buffer()
					}
			} {}
		}(ctx, next, stop, timespan)

		done := ctx.done()

		for select {
			_ := <-done {
				stop <- 0
				stop.close()
				return
			}
			item := <-observe {
				if item.is_error() {
					item.send_context(ctx, next)
					if option.get_error_strategy() == .stop_on_error {
						stop <- 0
						stop.close()
						return
					}
				} else {
					mutex.@lock()
					buffer << item.value
					mutex.unlock()
				}
			}
		} {}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// buffer_with_time_or_count returns an Observable that emits buffers of items it collects from the source
// Observable either from a given count or at a given time interval.
pub fn (o &ObservableImpl) buffer_with_time_or_count(timespan Duration, count int, opts ...RxOption) Observable {
	if count <= 0 {
		return thrown(new_illegal_input_error("count must be positive"))
	}

	f := fn [timespan, count] (ctx context.Context, next chan Item, option Option, opts ...RxOption) {
		observe := o.observe(...opts)
		buffer := []ItemValue{}
		stop := chan int{cap: 1}
		send := chan int{cap: 1}
		mutex := sync.new_mutex()

		check_buffer := fn [mut buffer, mut mutex] () {
			mutex.@lock()
			if buffer.len != 0 {
				if !of(buffer).send_context(ctx, next) {
					mutex.unlock()
					return
				}
				buffer = []ItemValue{}
			}
			mutex.unlock()
		}

		go fn [check_buffer] (ctx context.Context, next chan Item, stop chan int, send chan int, timespan Duration) {
			defer {
				next <- 0
				next.close()
			}

			duration := timespan.duration()
			done := ctx.done()

			for select {
					_ := <-send {
						check_buffer()
					}
					_ := <-stop {
						check_buffer()
						return
					}
					_ := <-done {
						return
					}
					duration {
						check_buffer()
					}
			} {}
		}(ctx, next, stop, send, timespan)

		done := ctx.done()

		for select {
			_ := <-done {
				return
			}
			item := <-observe {
				if item.is_error() {
					item.send_context(ctx, next)
					if option.get_error_strategy() == .stop_on_error {
						stop <- 0
						send <- 0
						stop.close()
						send.close()
						return
					}
				} else {
					mutex.@lock()
					buffer << item.value
					if buffer.len == count {
						mutex.unlock()
						send <- 0
					} else {
						mutex.unlock()
					}
				}
			}
		} {}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// connect instructs a connectable Observable to begin emitting items to its subscribers.
pub fn (o &ObservableImpl) connect(ctx context.Context) (context.Context, Disposable) {
	cancel_ctx := context.with_cancel(ctx)
	cancel := fn [cancel_ctx] () {
		context.cancel(cancel_ctx)
	}
	o.observe(with_context(cancel_ctx), connect())
	return cancel_ctx, Disposable(cancel)
}

// contains determines whether an Observable emits a particular item or not.
pub fn (o &ObservableImpl) contains(equal Predicate, opts ...RxOption) Single {
	return single(o.parent, o, fn [equal] () Operator {
		return &ContainsOperator{
			equal:    equal,
			contains: false,
		}
	}, false, false, ...opts)
}

struct ContainsOperator {
	equal    Predicate
mut:
	contains bool
}

pub fn (mut op ContainsOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if op.equal(item.value) {
		of(true).send_context(ctx, dst)
		op.contains = true
		operator_options.stop()
	}
}

pub fn (op &ContainsOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &ContainsOperator) end(ctx context.Context, dst chan Item) {
	if !op.contains {
		of(false).send_context(ctx, dst)
	}
}

pub fn (mut op ContainsOperator) gather_next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if item.value == true {
		of(true).send_context(ctx, dst)
		operator_options.stop()
		op.contains = true
	}
}

// count counts the number of items emitted by the source Observable and emit only this value.
pub fn (o &ObservableImpl) count(opts ...RxOption) Single {
	return single(o.parent, o, fn () Operator {
		return &CountOperator{}
	}, true, false, ...opts)
}

struct CountOperator {
mut:
	count i64
}

pub fn (mut op CountOperator) next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
	op.count++
}

pub fn (op &CountOperator) err(_ context.Context, _ Item, _ chan Item, operator_options OperatorOptions) {
	operator_options.stop()
}

pub fn (op &CountOperator) end(ctx context.Context, dst chan Item) {
	of(op.count).send_context(ctx, dst)
}

pub fn (op &CountOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// debounce only emits an item from an Observable if a particular timespan has passed without it emitting another item.
pub fn (o &ObservableImpl) debounce(timespan Duration, opts ...RxOption) Observable {
	f := fn [timespan] (ctx context.Context, next chan Item, option Option, opts ...RxOption) {
		defer {
			next.close()
		}
		observe := o.observe(...opts)
		mut latest := ItemValue(voidptr(0))

		duration := timespan.duration()
		done := ctx.done()

		for select {
			_ := <-done {
				return
			}
			item := <-observe {
				if item.is_error() {
					if !item.send_context(ctx, next) {
						return
					}
					if option.get_error_strategy() == .stop_on_error {
						return
					}
				} else {
					latest = item.value
				}
			}
			duration {
				if latest is voidptr {
					if isnil(latest) {
						continue
					}
				}
				if !of(latest).send_context(ctx, next) {
					return
				}
				latest = ItemValue(voidptr(0))
			}
		} {}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// default_if_empty returns an Observable that emits the items emitted by the source
// Observable or a specified default item if the source Observable is empty.
pub fn (o &ObservableImpl) default_if_empty(default_value ItemValue, opts ...RxOption) Observable {
	return observable(o.parent, o, fn [default_value] () Operator {
		return &DefaultIfEmptyOperator{
			default_value: default_value,
			empty:        true,
		}
	}, true, false, ...opts)
}

struct DefaultIfEmptyOperator {
	default_value ItemValue
	empty        bool
}

pub fn (op &DefaultIfEmptyOperator) next(ctx context.Context, item Item, dst chan Item, _ operator_options) {
	op.empty = false
	item.send_context(ctx, dst)
}

pub fn (op &DefaultIfEmptyOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &DefaultIfEmptyOperator) end(ctx context.Context, dst chan Item) {
	if op.empty {
		of(op.default_value).send_context(ctx, dst)
	}
}

pub fn (op &DefaultIfEmptyOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// distinct suppresses duplicate items in the original Observable and returns
// a new Observable.
pub fn (o &ObservableImpl) distinct(apply Func, opts ...RxOption) Observable {
	return observable(o.parent, o, fn [apply] () Operator {
		return &DistinctOperator{
			apply:  apply,
			keyset: map[ItemValue]ItemValue{},
		}
	}, false, false, ...opts)
}

struct DistinctOperator {
	apply  Func
	keyset map[ItemValue]ItemValue
}

pub fn (mut op DistinctOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	key := op.apply(ctx, item.value) or {
		error(err).send_context(ctx, dst)
		operator_options.stop()
		return
	}

	if key !in op.keyset {
		item.send_context(ctx, dst)
	}
	op.keyset[key] = true
}

pub fn (op &DistinctOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &DistinctOperator) end(_ context.Context, _ chan Item) {
}

pub fn (mut op DistinctOperator) gather_next(ctx context.Context, item Item, dst chan Item, _ operator_options) {
	if item.value !is DistinctOperator {
		return
	}

	if item.value !in op.keyset {
		of(item.value).send_context(ctx, dst)
		op.keyset[item.value] = true
	}
}

// distinct_until_changed suppresses consecutive duplicate items in the original Observable.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) distinct_until_changed(apply Func, opts ...RxOption) Observable {
	return observable(o.parent, o, fn [apply] () Operator {
		return &DistinctUntilChangedOperator{
			apply: apply,
		}
	}, true, false, ...opts)
}

struct DistinctUntilChangedOperator {
	apply   Func
	current ItemValue
}

pub fn (mut op DistinctUntilChangedOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	key := op.apply(ctx, item.value) or {
		error(err).send_context(ctx, dst)
		operator_options.stop()
		return
	}
	if op.current != key {
		item.send_context(ctx, dst)
		op.current = key
	}
}

pub fn (op &DistinctUntilChangedOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &DistinctUntilChangedOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &DistinctUntilChangedOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// do_on_completed registers a callback action that will be called once the Observable terminates.
pub fn (o &ObservableImpl) do_on_completed(handle_complete CompletedFunc, opts ...RxOption) Disposed {
	dispose := chan int{cap: 1}

	handler := fn [dispose, handle_complete] (ctx context.Context, src chan Item) {
		defer {
			dispose <- 0
			dispose.close()
		}
		defer {
			handle_complete()
		}

		done := ctx.done()

		for select {
			_ := done {
				return
			}
			i <-src {
				if i.is_error() {
					return
				}
			}
		} {}
	}

	option := parse_options(...opts)
	ctx := option.build_context(o.parent)
	go handler(ctx, o.observe(...opts))
	return dispose
}

// do_on_error registers a callback action that will be called if the Observable terminates abnormally.
pub fn (o &ObservableImpl) do_on_error(handle_err ErrFunc, opts ...RxOption) Disposed {
	dispose := chan int{cap: 1}

	handler := fn [dispose, handle_err] (ctx context.Context, src chan Item) {
		defer {
			dispose <- 0
			dispose.close()
		}

		done := ctx.done()

		for select {
			_ := <-done {
				return
			}
			i <-src {
				if i.is_error() {
					handle_err(i.err)
					return
				}
			}
		} {}
	}

	option := parse_options(...opts)
	ctx := option.build_context(o.parent)
	go handler(ctx, o.observe(...opts))
	return dispose
}

// do_on_next registers a callback action that will be called on each item emitted by the Observable.
pub fn (o &ObservableImpl) do_on_next(handle_next NextFunc, opts ...RxOption) Disposed {
	dispose := chan int{cap: 1}

	handler := fn [dispose, handle_next] (ctx context.Context, src chan Item) {
		defer {
			dispose <- 0
			dispose.close()
		}

		done := ctx.done()

		for select {
			_ := <-done {
				return
			}
			i <-src {
				if i.is_error() {
					return
				}
				handle_next(i.value)
			}
		} {}
	}

	option := parse_options(...opts)
	ctx := option.build_context(o.parent)
	go handler(ctx, o.observe(...opts))
	return dispose
}

// element_at emits only item n emitted by an Observable.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) element_at(index u32, opts ...RxOption) Single {
	return single(o.parent, o, fn [index] () Operator {
		return &ElementAtOperator{
			index: index,
		}
	}, true, false, ...opts)
}

struct ElementAtOperator {
mut:
	index     u32
	take_count int
	sent      bool
}

pub fn (mut op ElementAtOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if op.take_count == int(op.index) {
		item.send_context(ctx, dst)
		op.sent = true
		operator_options.stop()
		return
	}
	op.take_count++
}

pub fn (op &ElementAtOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &ElementAtOperator) end(ctx context.Context, dst chan Item) {
	if !op.sent {
		error(new_illegal_input_error("")).send_context(ctx, dst)
	}
}

pub fn (op &ElementAtOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// error returns the eventual Observable error.
// This method is blocking.
pub fn (o &ObservableImpl) error(opts ...RxOption) IError {
	option := parse_options(...opts)
	ctx := option.build_context(o.parent)
	observe := o.iterable.observe(...opts)

	done := ctx.done()

	for select {
		_ := <-done {
			return ctx.err()
		}
		item := <-observe {
			if item.is_error() {
				return item.err
			}
		}
	} {}

	return none
}

// errors returns an eventual list of Observable errors.
// This method is blocking
pub fn (o &ObservableImpl) errors(opts ...RxOption) []IError {
	option := parse_options(...opts)
	ctx := option.build_context(o.parent)
	observe := o.iterable.observe(...opts)
	mut errs := []IError{}

	for select {
		_ := <-done {
			return [ctx.err()]
		}
		item := <-observe {
			if item.is_error() {
				errs << item.err
			}
		}
	} {}

	return errs
}

// filter emits only those items from an Observable that pass a predicate test.
pub fn (o &ObservableImpl) filter(apply Predicate, opts ...RxOption) Observable {
	return observable(o.parent, o, fn [apply] () Operator {
		return &FilterOperator{apply: apply}
	}, false, true, ...opts)
}

struct FilterOperator {
	apply Predicate
}

pub fn (op &FilterOperator) next(ctx context.Context, item Item, dst chan Item, _ operator_options) {
	if op.apply(item.value) {
		item.send_context(ctx, dst)
	}
}

pub fn (op &FilterOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &FilterOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &FilterOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// find emits the first item passing a predicate then complete.
pub fn (o &ObservableImpl) find(find Predicate, opts ...RxOption) OptionalSingle {
	return optionalSingle(o.parent, o, fn [find] () Operator {
		return &FindOperator{
			find: find,
		}
	}, true, true, ...opts)
}

struct FindOperator {
	find Predicate
}

pub fn (op &FindOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if op.find(item.value) {
		item.send_context(ctx, dst)
		operator_options.stop()
	}
}

pub fn (op &FindOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &FindOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &FindOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// first returns new Observable which emit only first item.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) first(opts ...RxOption) OptionalSingle {
	return optionalSingle(o.parent, o, fn () Operator {
		return &FirstOperator{}
	}, true, false, ...opts)
}

struct FirstOperator {}

pub fn (op &FirstOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	item.send_context(ctx, dst)
	operator_options.stop()
}

pub fn (op &FirstOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &FirstOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &FirstOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// first_or_default returns new Observable which emit only first item.
// If the observable fails to emit any items, it emits a default value.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) first_or_default(default_value ItemValue, opts ...RxOption) Single {
	return single(o.parent, o, fn [default_value] () Operator {
		return &FirstOrDefaultOperator{
			default_value: default_value,
		}
	}, true, false, ...opts)
}

struct FirstOrDefaultOperator {
	default_value ItemValue
mut:
	sent         bool
}

pub fn (mut op FirstOrDefaultOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	item.send_context(ctx, dst)
	op.sent = true
	operator_options.stop()
}

pub fn (op &FirstOrDefaultOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &FirstOrDefaultOperator) end(ctx context.Context, dst chan Item) {
	if !op.sent {
		of(op.default_value).send_context(ctx, dst)
	}
}

pub fn (op &FirstOrDefaultOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// flat_map transforms the items emitted by an Observable into Observables, then flatten the emissions from those into a single Observable.
pub fn (o &ObservableImpl) flat_map(apply ItemToObservable, opts ...RxOption) Observable {
	f := fn [apply] (ctx context.Context, next chan Item, option Option, opts ...RxOption) {
		defer {
			next.close()
		}

		observe := o.observe(...opts)
		done := ctx.done()

		for select {
			_ := <-done {
				return
			}
			item := <-observe {
				observe2 := apply(item).observe(...opts)
			}
			loop2:
				for select {
					_ := <-done {
						return
					}
					item := <-observe2 {
						if item.is_error() {
							item.send_context(ctx, next)
							if option.get_error_strategy() == .stop_on_error {
								return
							}
						} else {
							if !item.send_context(ctx, next) {
								return
							}
						}
					}
				} {} else {
					break loop2
				}
			}
		}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// for_each subscribes to the Observable and receives notifications for each element.
pub fn (o &ObservableImpl) for_each(handle_next NextFunc, handle_err ErrFunc, handle_complete CompletedFunc, opts ...RxOption) Disposed {
	dispose := chan int{cap: 1}

	handler := fn [dispose, handle_next, handle_err, handle_complete] (ctx context.Context, src chan Item) {
		defer {
			dispose <- 0
			dispose.close()
		}

		done := ctx.done()

		for select {
			_ := <-done {
				handle_complete()
				return
			}
			i <-src {
				if i.is_error() {
					return
				}
				handle_next(i.value)
			}
		} {} else {
			handle_complete()
		}
	}

	mut ctx := o.parent
	if isnil(ctx) {
		ctx = context.background()
	}
	go handler(ctx, o.observe(...opts))
	return dispose
}

// ignore_elements ignores all items emitted by the source ObservableSource except for the errors.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) ignore_elements(opts ...RxOption) Observable {
	return observable(o.parent, o, fn () Operator {
		return &IgnoreElementsOperator{}
	}, true, false, ...opts)
}

struct IgnoreElementsOperator {}

pub fn (op &IgnoreElementsOperator) next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

pub fn (op &IgnoreElementsOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &IgnoreElementsOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &IgnoreElementsOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// abs returns absolute value for i64
fn abs(n i64) i64 {
	y := n >> 63
	return (n ^ y) - y
}

// Join combines items emitted by two Observables whenever an item from one Observable is emitted during
// a time window defined according to an item emitted by the other Observable.
// The time is extracted using a timeExtractor function.
pub fn (o &ObservableImpl) join(joiner Func2, right Observable, timeExtractor fn (interface{}) time.Time, window Duration, opts ...RxOption) Observable {
	f := fn (ctx context.Context, next chan Item, option Option, opts ...RxOption) {
		defer {
			next.close()
		}
		windowDuration := i64(window.duration())
		rBuf := make([]Item, 0)

		lObserve := o.observe()
		rObserve := right.observe()
	lLoop:
		for select {
			case <-ctx.done():
				return
			case lItem, ok := <-lObserve:
				if lItem.V == nil && !ok {
					return
				}
				if lItem.is_error() {
					lItem.send_context(ctx, next)
					if option.get_error_strategy() == .stop_on_error {
						return
					}
					continue
				}
				lTime := timeExtractor(lItem.V).UnixNano()
				cutPoint := 0
				for i, rItem := range rBuf {
					rTime := timeExtractor(rItem.V).UnixNano()
					if abs(lTime-rTime) <= windowDuration {
						i, err := joiner(ctx, lItem.V, rItem.V)
						if err != nil {
							error(err).send_context(ctx, next)
							if option.get_error_strategy() == .stop_on_error {
								return
							}
							continue
						}
						of(i).send_context(ctx, next)
					}
					if lTime > rTime+windowDuration {
						cutPoint = i + 1
					}
				}

				rBuf = rBuf[cutPoint:]

				for {
					select {
					case <-ctx.done():
						return
					case rItem, ok := <-rObserve:
						if rItem.V == nil && !ok {
							continue lLoop
						}
						if rItem.is_error() {
							rItem.send_context(ctx, next)
							if option.get_error_strategy() == .stop_on_error {
								return
							}
							continue
						}

						rBuf = append(rBuf, rItem)
						rTime := timeExtractor(rItem.V).UnixNano()
						if abs(lTime-rTime) <= windowDuration {
							i, err := joiner(ctx, lItem.V, rItem.V)
							if err != nil {
								error(err).send_context(ctx, next)
								if option.get_error_strategy() == .stop_on_error {
									return
								}
								continue
							}
							of(i).send_context(ctx, next)

							continue
						}
						continue lLoop
					}
				}
			}
		}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// GroupBy divides an Observable into a set of Observables that each emit a different group of items from the original Observable, organized by key.
pub fn (o &ObservableImpl) group_by(length int, distribution fn (Item) int, opts ...RxOption) Observable {
	option := parse_options(...opts)
	ctx := option.build_context(o.parent)

	s := make([]Item, length)
	chs := make([]chan Item, length)
	for i := 0; i < length; i++ {
		ch := option.buildChannel()
		chs[i] = ch
		s[i] = of(&ObservableImpl{
			iterable: newChannelIterable(ch),
		})
	}

	go fn () {
		observe := o.observe(...opts)
		defer fn () {
			for i := 0; i < length; i++ {
				close(chs[i])
			}
		}()

		for select {
			case <-ctx.done():
				return
			item := <-observe:
				if !ok {
					return
				}
				idx := distribution(item)
				if idx >= length {
					err := error(IndexOutofBoundError{error: fmt.Sprintf("index %d, length %d", idx, length)})
					for i := 0; i < length; i++ {
						err.send_context(ctx, chs[i])
					}
					return
				}
				item.send_context(ctx, chs[idx])
			}
		}
	}()

	return &ObservableImpl{
		iterable: newSliceIterable(s, ...opts),
	}
}

// GroupedObservable is the observable type emitted by the GroupByDynamic operator.
struct GroupedObservable {
	Observable
	// Key is the distribution key
	Key string
}

// GroupByDynamic divides an Observable into a dynamic set of Observables that each emit GroupedObservable from the original Observable, organized by key.
pub fn (o &ObservableImpl) group_by_dynamic(distribution fn (Item) string, opts ...RxOption) Observable {
	option := parse_options(...opts)
	next := option.buildChannel()
	ctx := option.build_context(o.parent)
	chs := make(map[string]chan Item)

	go fn () {
		observe := o.observe(...opts)
	loop:
		for select {
			case <-ctx.done():
				break loop
			case i, ok := <-observe:
				if !ok {
					break loop
				}
				idx := distribution(i)
				ch, contains := chs[idx]
				if !contains {
					ch = option.buildChannel()
					chs[idx] = ch
					of(GroupedObservable{
						Observable: &ObservableImpl{
							iterable: newChannelIterable(ch),
						},
						Key: idx,
					}).send_context(ctx, next)
				}
				i.send_context(ctx, ch)
			}
		}
		for _, ch := range chs {
			close(ch)
		}
		close(next)
	}()

	return &ObservableImpl{
		iterable: newChannelIterable(next),
	}
}

// Last returns a new Observable which emit only last item.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) last(opts ...RxOption) OptionalSingle {
	return optionalSingle(o.parent, o, fn () Operator {
		return &LastOperator{
			empty: true,
		}
	}, true, false, ...opts)
}

struct LastOperator {
	last  Item
	empty bool
}

pub fn (op &LastOperator) next(_ context.Context, item Item, _ chan Item, _ operator_options) {
	op.last = item
	op.empty = false
}

pub fn (op &LastOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &LastOperator) end(ctx context.Context, dst chan Item) {
	if !op.empty {
		op.last.send_context(ctx, dst)
	}
}

pub fn (op &LastOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// LastOrDefault returns a new Observable which emit only last item.
// If the observable fails to emit any items, it emits a default value.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) last_or_default(default_value interface{}, opts ...RxOption) Single {
	return single(o.parent, o, fn () Operator {
		return &LastOrDefaultOperator{
			default_value: default_value,
			empty:        true,
		}
	}, true, false, ...opts)
}

struct LastOrDefaultOperator {
	default_value interface{}
	last         Item
	empty        bool
}

pub fn (op &LastOrDefaultOperator) next(_ context.Context, item Item, _ chan Item, _ operator_options) {
	op.last = item
	op.empty = false
}

pub fn (op &LastOrDefaultOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &LastOrDefaultOperator) end(ctx context.Context, dst chan Item) {
	if !op.empty {
		op.last.send_context(ctx, dst)
	} else {
		of(op.default_value).send_context(ctx, dst)
	}
}

pub fn (op &LastOrDefaultOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// Map transforms the items emitted by an Observable by applying a function to each item.
pub fn (o &ObservableImpl) map(apply Func, opts ...RxOption) Observable {
	return observable(o.parent, o, fn () Operator {
		return &MapOperator{apply: apply}
	}, false, true, ...opts)
}

struct MapOperator {
	apply Func
}

pub fn (op &MapOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	res, err := op.apply(ctx, item.value)
	if err != nil {
		error(err).send_context(ctx, dst)
		operator_options.stop()
		return
	}
	of(res).send_context(ctx, dst)
}

pub fn (op &MapOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &MapOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &MapOperator) gather_next(ctx context.Context, item Item, dst chan Item, _ operator_options) {
	switch item.value.(type) {
	case *mapOperator:
		return
	}
	item.send_context(ctx, dst)
}

// Marshal transforms the items emitted by an Observable by applying a marshalling to each item.
pub fn (o &ObservableImpl) marshal(marshaller Marshaller, opts ...RxOption) Observable {
	return o.Map(fn (_ context.Context, i interface{}) (interface{}, error) {
		return marshaller(i)
	}, ...opts)
}

// Max determines and emits the maximum-valued item emitted by an Observable according to a comparator.
pub fn (o &ObservableImpl) max(comparator Comparator, opts ...RxOption) OptionalSingle {
	return optionalSingle(o.parent, o, fn () Operator {
		return &MaxOperator{
			comparator: comparator,
			empty:      true,
		}
	}, false, false, ...opts)
}

struct MaxOperator {
	comparator Comparator
	empty      bool
	max        interface{}
}

pub fn (op &MaxOperator) next(_ context.Context, item Item, _ chan Item, _ operator_options) {
	op.empty = false

	if op.max == nil {
		op.max = item.value
	} else {
		if op.comparator(op.max, item.value) < 0 {
			op.max = item.value
		}
	}
}

pub fn (op &MaxOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &MaxOperator) end(ctx context.Context, dst chan Item) {
	if !op.empty {
		of(op.max).send_context(ctx, dst)
	}
}

pub fn (op &MaxOperator) gather_next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	op.next(ctx, of(item.value.(*maxOperator).max), dst, operator_options)
}

// Min determines and emits the minimum-valued item emitted by an Observable according to a comparator.
pub fn (o &ObservableImpl) min(comparator Comparator, opts ...RxOption) OptionalSingle {
	return optionalSingle(o.parent, o, fn () Operator {
		return &MinOperator{
			comparator: comparator,
			empty:      true,
		}
	}, false, false, ...opts)
}

struct MinOperator {
	comparator Comparator
	empty      bool
	max        interface{}
}

pub fn (op &MinOperator) next(_ context.Context, item Item, _ chan Item, _ operator_options) {
	op.empty = false

	if op.max == nil {
		op.max = item.value
	} else {
		if op.comparator(op.max, item.value) > 0 {
			op.max = item.value
		}
	}
}

pub fn (op &MinOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &MinOperator) end(ctx context.Context, dst chan Item) {
	if !op.empty {
		of(op.max).send_context(ctx, dst)
	}
}

pub fn (op &MinOperator) gather_next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	op.next(ctx, of(item.value.(*minOperator).max), dst, operator_options)
}

// Observe observes an Observable by returning its channel.
pub fn (o &ObservableImpl) observe(opts ...RxOption) chan Item {
	return o.iterable.observe(...opts)
}

// OnErrorResumeNext instructs an Observable to pass control to another Observable rather than invoking
// onError if it encounters an error.
pub fn (o &ObservableImpl) on_error_resume_next(resumeSequence ErrorToObservable, opts ...RxOption) Observable {
	return observable(o.parent, o, fn () Operator {
		return &OnErrorResumeNextOperator{resumeSequence: resumeSequence}
	}, true, false, ...opts)
}

struct OnErrorResumeNextOperator {
	resumeSequence ErrorToObservable
}

pub fn (op &OnErrorResumeNextOperator) next(ctx context.Context, item Item, dst chan Item, _ operator_options) {
	item.send_context(ctx, dst)
}

pub fn (op &OnErrorResumeNextOperator) err(_ context.Context, item Item, _ chan Item, operator_options OperatorOptions) {
	operator_options.resetIterable(op.resumeSequence(item.err))
}

pub fn (op &OnErrorResumeNextOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &OnErrorResumeNextOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// OnErrorReturn instructs an Observable to emit an item (returned by a specified function)
// rather than invoking onError if it encounters an error.
pub fn (o &ObservableImpl) on_error_return(resumeFunc ErrorFunc, opts ...RxOption) Observable {
	return observable(o.parent, o, fn () Operator {
		return &OnErrorReturnOperator{resumeFunc: resumeFunc}
	}, true, false, ...opts)
}

struct OnErrorReturnOperator {
	resumeFunc ErrorFunc
}

pub fn (op &OnErrorReturnOperator) next(ctx context.Context, item Item, dst chan Item, _ operator_options) {
	item.send_context(ctx, dst)
}

pub fn (op &OnErrorReturnOperator) err(ctx context.Context, item Item, dst chan Item, _ operator_options) {
	of(op.resumeFn (item.err)).send_context(ctx, dst)
}

pub fn (op &OnErrorReturnOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &OnErrorReturnOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// OnErrorReturnItem instructs on Observable to emit an item if it encounters an error.
pub fn (o &ObservableImpl) on_error_return_item(resume interface{}, opts ...RxOption) Observable {
	return observable(o.parent, o, fn () Operator {
		return &OnErrorReturnItemOperator{resume: resume}
	}, true, false, ...opts)
}

struct OnErrorReturnItemOperator {
	resume interface{}
}

pub fn (op &OnErrorReturnItemOperator) next(ctx context.Context, item Item, dst chan Item, _ operator_options) {
	item.send_context(ctx, dst)
}

pub fn (op &OnErrorReturnItemOperator) err(ctx context.Context, _ Item, dst chan Item, _ operator_options) {
	of(op.resume).send_context(ctx, dst)
}

pub fn (op &OnErrorReturnItemOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &OnErrorReturnItemOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// Reduce applies a function to each item emitted by an Observable, sequentially, and emit the final value.
pub fn (o &ObservableImpl) reduce(apply Func2, opts ...RxOption) OptionalSingle {
	return optionalSingle(o.parent, o, fn () Operator {
		return &ReduceOperator{
			apply: apply,
			empty: true,
		}
	}, false, false, ...opts)
}

struct ReduceOperator {
	apply Func2
	acc   interface{}
	empty bool
}

pub fn (op &ReduceOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	op.empty = false
	v, err := op.apply(ctx, op.acc, item.value)
	if err != nil {
		error(err).send_context(ctx, dst)
		operator_options.stop()
		op.empty = true
		return
	}
	op.acc = v
}

pub fn (op &ReduceOperator) err(_ context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	dst <- item
	operator_options.stop()
	op.empty = true
}

pub fn (op &ReduceOperator) end(ctx context.Context, dst chan Item) {
	if !op.empty {
		of(op.acc).send_context(ctx, dst)
	}
}

pub fn (op &ReduceOperator) gather_next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	op.next(ctx, of(item.value.(*reduceOperator).acc), dst, operator_options)
}

// Repeat returns an Observable that repeats the sequence of items emitted by the source Observable
// at most count times, at a particular frequency.
// Cannot run in parallel.
pub fn (o &ObservableImpl) repeat(count i64, frequency Duration, opts ...RxOption) Observable {
	if count != Infinite {
		if count < 0 {
			return thrown(IllegalInputError{error: "count must be positive"})
		}
	}

	return observable(o.parent, o, fn () Operator {
		return &RepeatOperator{
			count:     count,
			frequency: frequency,
			seq:       make([]Item, 0),
		}
	}, true, false, ...opts)
}

struct RepeatOperator {
	count     i64
	frequency time.Duration
	seq       []Item
}

pub fn (op &RepeatOperator) next(ctx context.Context, item Item, dst chan Item, _ operator_options) {
	item.send_context(ctx, dst)
	op.seq = append(op.seq, item)
}

pub fn (op &RepeatOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &RepeatOperator) end(ctx context.Context, dst chan Item) {
	for {
		select {
		default:
		case <-ctx.done():
			return
		}
		if op.count != Infinite {
			if op.count == 0 {
				break
			}
		}
		if op.frequency != nil {
			time.Sleep(op.frequency.duration())
		}
		for _, v := range op.seq {
			v.send_context(ctx, dst)
		}
		op.count = op.count - 1
	}
}

pub fn (op &RepeatOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// Retry retries if a source Observable sends an error, resubscribe to it in the hopes that it will complete without error.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) retry(count int, shouldRetry fn (error) bool, opts ...RxOption) Observable {
	option := parse_options(...opts)
	next := option.buildChannel()
	ctx := option.build_context(o.parent)

	go fn () {
		observe := o.observe(...opts)
	loop:
		for select {
			case <-ctx.done():
				break loop
			case i, ok := <-observe:
				if !ok {
					break loop
				}
				if i.is_error() {
					count--
					if count < 0 || !shouldRetry(i.E) {
						i.send_context(ctx, next)
						break loop
					}
					observe = o.observe(...opts)
				} else {
					i.send_context(ctx, next)
				}
			}
		}
		close(next)
	}()

	return &ObservableImpl{
		iterable: newChannelIterable(next),
	}
}

// Run creates an Observer without consuming the emitted items.
pub fn (o &ObservableImpl) run(opts ...RxOption) Disposed {
	dispose := chan int{cap: 1}
	option := parse_options(...opts)
	ctx := option.build_context(o.parent)

	go fn () {
		defer {
			dispose <- 0
			dispose.close()
		}
		observe := o.observe(...opts)
		for select {
			case <-ctx.done():
				return
			case _, ok := <-observe:
				if !ok {
					return
				}
			}
		}
	}()

	return dispose
}

// Sample returns an Observable that emits the most recent items emitted by the source
// Iterable whenever the input Iterable emits an item.
pub fn (o &ObservableImpl) sample(iterable Iterable, opts ...RxOption) Observable {
	option := parse_options(...opts)
	next := option.buildChannel()
	ctx := option.build_context(o.parent)
	itCh := make(chan Item)
	obsCh := make(chan Item)

	go fn () {
		defer close(obsCh)
		observe := o.observe(...opts)
		for select {
			case <-ctx.done():
				return
			case i, ok := <-observe:
				if !ok {
					return
				}
				i.send_context(ctx, obsCh)
			}
		}
	}()

	go fn () {
		defer close(itCh)
		observe := iterable.observe(...opts)
		for select {
			case <-ctx.done():
				return
			case i, ok := <-observe:
				if !ok {
					return
				}
				i.send_context(ctx, itCh)
			}
		}
	}()

	go fn () {
		defer {
			next.close()
		}
		var lastEmittedItem Item
		isItemWaitingToBeEmitted := false

		for select {
			case _, ok := <-itCh:
				if ok {
					if isItemWaitingToBeEmitted {
						next <- lastEmittedItem
						isItemWaitingToBeEmitted = false
					}
				} else {
					return
				}
			item := <-obsCh:
				if ok {
					lastEmittedItem = item
					isItemWaitingToBeEmitted = true
				} else {
					return
				}
			}
		}
	}()

	return &ObservableImpl{
		iterable: newChannelIterable(next),
	}
}

// Scan apply a Func2 to each item emitted by an Observable, sequentially, and emit each successive value.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) scan(apply Func2, opts ...RxOption) Observable {
	return observable(o.parent, o, fn () Operator {
		return &ScanOperator{
			apply: apply,
		}
	}, true, false, ...opts)
}

struct ScanOperator {
	apply   Func2
	current interface{}
}

pub fn (op &ScanOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	v, err := op.apply(ctx, op.current, item.value)
	if err != nil {
		error(err).send_context(ctx, dst)
		operator_options.stop()
		return
	}
	of(v).send_context(ctx, dst)
	op.current = v
}

pub fn (op &ScanOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &ScanOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &ScanOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// Compares first items of two sequences and returns true if they are equal and false if
// they are not. Besides, it returns two new sequences - input sequences without compared items.
func popAndCompareFirstItems(
	inputSequence1 []interface{},
	inputSequence2 []interface{}) (bool, []interface{}, []interface{}) {
	if len(inputSequence1) > 0 && len(inputSequence2) > 0 {
		s1, sequence1 := inputSequence1[0], inputSequence1[1:]
		s2, sequence2 := inputSequence2[0], inputSequence2[1:]
		return s1 == s2, sequence1, sequence2
	}
	return true, inputSequence1, inputSequence2
}

// Send sends the items to a given channel.
pub fn (o &ObservableImpl) send(output chan Item, opts ...RxOption) {
	go fn () {
		option := parse_options(...opts)
		ctx := option.build_context(o.parent)
		observe := o.observe(...opts)
	loop:
		for select {
			case <-ctx.done():
				break loop
			case i, ok := <-observe:
				if !ok {
					break loop
				}
				if i.is_error() {
					output <- i
					break loop
				}
				i.send_context(ctx, output)
			}
		}
		close(output)
	}()
}

// SequenceEqual emits true if an Observable and the input Observable emit the same items,
// in the same order, with the same termination state. Otherwise, it emits false.
pub fn (o &ObservableImpl) sequence_equal(iterable Iterable, opts ...RxOption) Single {
	option := parse_options(...opts)
	next := option.buildChannel()
	ctx := option.build_context(o.parent)
	itCh := make(chan Item)
	obsCh := make(chan Item)

	go fn () {
		defer close(obsCh)
		observe := o.observe(...opts)
		for select {
			case <-ctx.done():
				return
			case i, ok := <-observe:
				if !ok {
					return
				}
				i.send_context(ctx, obsCh)
			}
		}
	}()

	go fn () {
		defer close(itCh)
		observe := iterable.observe(...opts)
		for select {
			case <-ctx.done():
				return
			case i, ok := <-observe:
				if !ok {
					return
				}
				i.send_context(ctx, itCh)
			}
		}
	}()

	go fn () {
		var mainSequence []interface{}
		var obsSequence []interface{}
		areCorrect := true
		isMainChannelClosed := false
		isObsChannelClosed := false

	mainLoop:
		for select {
			item := <-itCh:
				if ok {
					mainSequence = append(mainSequence, item)
					areCorrect, mainSequence, obsSequence = popAndCompareFirstItems(mainSequence, obsSequence)
				} else {
					isMainChannelClosed = true
				}
			item := <-obsCh:
				if ok {
					obsSequence = append(obsSequence, item)
					areCorrect, mainSequence, obsSequence = popAndCompareFirstItems(mainSequence, obsSequence)
				} else {
					isObsChannelClosed = true
				}
			}

			if !areCorrect || (isMainChannelClosed && isObsChannelClosed) {
				break mainLoop
			}
		}

		of(areCorrect && len(mainSequence) == 0 && len(obsSequence) == 0).send_context(ctx, next)
		close(next)
	}()

	return &SingleImpl{
		iterable: newChannelIterable(next),
	}
}

// Serialize forces an Observable to make serialized calls and to be well-behaved.
pub fn (o &ObservableImpl) serialize(from int, identifier fn (interface{}) int, opts ...RxOption) Observable {
	option := parse_options(...opts)
	next := option.buildChannel()

	ctx := option.build_context(o.parent)
	minHeap := binaryheap.NewWith(fn (a, b interface{}) int {
		return a.(int) - b.(int)
	})
	counter := i64(from)
	items := make(map[int]interface{})

	go fn () {
		src := o.observe(...opts)
		defer {
			next.close()
		}

		for select {
			case <-ctx.done():
				return
			item := <-src:
				if !ok {
					return
				}
				if item.is_error() {
					next <- item
					return
				}

				id := identifier(item.value)
				minHeap.Push(id)
				items[id] = item.value

				for !minHeap.Empty() {
					v, _ := minHeap.Peek()
					id := v.(int)
					if atomic.LoadInt64(&counter) == i64(id) {
						if itemValue, contains := items[id]; contains {
							minHeap.Pop()
							delete(items, id)
							of(itemValue).send_context(ctx, next)
							counter++
							continue
						}
					}
					break
				}
			}
		}
	}()

	return &ObservableImpl{
		iterable: newChannelIterable(next),
	}
}

// Skip suppresses the first n items in the original Observable and
// returns a new Observable with the rest items.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) skip(nth u32, opts ...RxOption) Observable {
	return observable(o.parent, o, fn () Operator {
		return &SkipOperator{
			nth: nth,
		}
	}, true, false, ...opts)
}

struct SkipOperator {
	nth       u32
	skipCount int
}

pub fn (op &SkipOperator) next(ctx context.Context, item Item, dst chan Item, _ operator_options) {
	if op.skipCount < int(op.nth) {
		op.skipCount++
		return
	}
	item.send_context(ctx, dst)
}

pub fn (op &SkipOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &SkipOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &SkipOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// SkipLast suppresses the last n items in the original Observable and
// returns a new Observable with the rest items.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) skip_last(nth u32, opts ...RxOption) Observable {
	return observable(o.parent, o, fn () Operator {
		return &SkipLastOperator{
			nth: nth,
		}
	}, true, false, ...opts)
}

struct SkipLastOperator {
	nth       u32
	skipCount int
}

pub fn (op &SkipLastOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if op.skipCount >= int(op.nth) {
		operator_options.stop()
		return
	}
	op.skipCount++
	item.send_context(ctx, dst)
}

pub fn (op &SkipLastOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &SkipLastOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &SkipLastOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// SkipWhile discard items emitted by an Observable until a specified condition becomes false.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) skip_while(apply Predicate, opts ...RxOption) Observable {
	return observable(o.parent, o, fn () Operator {
		return &SkipWhileOperator{
			apply: apply,
			skip:  true,
		}
	}, true, false, ...opts)
}

struct SkipWhileOperator {
	apply Predicate
	skip  bool
}

pub fn (op &SkipWhileOperator) next(ctx context.Context, item Item, dst chan Item, _ operator_options) {
	if !op.skip {
		item.send_context(ctx, dst)
	} else {
		if !op.apply(item.value) {
			op.skip = false
			item.send_context(ctx, dst)
		}
	}
}

pub fn (op &SkipWhileOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &SkipWhileOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &SkipWhileOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// StartWith emits a specified Iterable before beginning to emit the items from the source Observable.
pub fn (o &ObservableImpl) start_with(iterable Iterable, opts ...RxOption) Observable {
	option := parse_options(...opts)
	next := option.buildChannel()
	ctx := option.build_context(o.parent)

	go fn () {
		defer {
			next.close()
		}
		observe := iterable.observe(...opts)
	loop1:
		for select {
			case <-ctx.done():
				break loop1
			case i, ok := <-observe:
				if !ok {
					break loop1
				}
				if i.is_error() {
					next <- i
					return
				}
				i.send_context(ctx, next)
			}
		}
		observe = o.observe(...opts)
	loop2:
		for select {
			case <-ctx.done():
				break loop2
			case i, ok := <-observe:
				if !ok {
					break loop2
				}
				if i.is_error() {
					i.send_context(ctx, next)
					return
				}
				i.send_context(ctx, next)
			}
		}
	}()

	return &ObservableImpl{
		iterable: newChannelIterable(next),
	}
}

// SumFloat32 calculates the average of float32 emitted by an Observable and emits a float32.
pub fn (o &ObservableImpl) sum_float32(opts ...RxOption) OptionalSingle {
	return o.Reduce(fn (_ context.Context, acc, elem interface{}) (interface{}, error) {
		if acc == nil {
			acc = float32(0)
		}
		sum := acc.(float32)
		switch i := elem.(type) {
		default:
			return nil, IllegalInputError{error: fmt.Sprintf("expected type: (float32|int|int8|int16|int32|i64), got: %t", elem)}
		case int:
			return sum + float32(i), nil
		case int8:
			return sum + float32(i), nil
		case int16:
			return sum + float32(i), nil
		case int32:
			return sum + float32(i), nil
		case i64:
			return sum + float32(i), nil
		case float32:
			return sum + i, nil
		}
	}, ...opts)
}

// SumFloat64 calculates the average of float64 emitted by an Observable and emits a float64.
pub fn (o &ObservableImpl) sum_float64(opts ...RxOption) OptionalSingle {
	return o.Reduce(fn (_ context.Context, acc, elem interface{}) (interface{}, error) {
		if acc == nil {
			acc = float64(0)
		}
		sum := acc.(float64)
		switch i := elem.(type) {
		default:
			return nil, IllegalInputError{error: fmt.Sprintf("expected type: (float32|float64|int|int8|int16|int32|i64), got: %t", elem)}
		case int:
			return sum + float64(i), nil
		case int8:
			return sum + float64(i), nil
		case int16:
			return sum + float64(i), nil
		case int32:
			return sum + float64(i), nil
		case i64:
			return sum + float64(i), nil
		case float32:
			return sum + float64(i), nil
		case float64:
			return sum + i, nil
		}
	}, ...opts)
}

// SumInt64 calculates the average of integers emitted by an Observable and emits an i64.
pub fn (o &ObservableImpl) sum_i64(opts ...RxOption) OptionalSingle {
	return o.Reduce(fn (_ context.Context, acc, elem interface{}) (interface{}, error) {
		if acc == nil {
			acc = i64(0)
		}
		sum := acc.(i64)
		switch i := elem.(type) {
		default:
			return nil, IllegalInputError{error: fmt.Sprintf("expected type: (int|int8|int16|int32|i64), got: %t", elem)}
		case int:
			return sum + i64(i), nil
		case int8:
			return sum + i64(i), nil
		case int16:
			return sum + i64(i), nil
		case int32:
			return sum + i64(i), nil
		case i64:
			return sum + i, nil
		}
	}, ...opts)
}

// Take emits only the first n items emitted by an Observable.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) take(nth u32, opts ...RxOption) Observable {
	return observable(o.parent, o, fn () Operator {
		return &TakeOperator{
			nth: nth,
		}
	}, true, false, ...opts)
}

struct TakeOperator {
	nth       u32
	take_count int
}

pub fn (op &TakeOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if op.take_count >= int(op.nth) {
		operator_options.stop()
		return
	}

	op.take_count++
	item.send_context(ctx, dst)
}

pub fn (op &TakeOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &TakeOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &TakeOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// TakeLast emits only the last n items emitted by an Observable.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) take_last(nth u32, opts ...RxOption) Observable {
	return observable(o.parent, o, fn () Operator {
		n := int(nth)
		return &TakeLast{
			n: n,
			r: ring.New(n),
		}
	}, true, false, ...opts)
}

struct TakeLast {
	n     int
	r     *ring.Ring
	count int
}

pub fn (op &TakeLast) next(_ context.Context, item Item, _ chan Item, _ operator_options) {
	op.count++
	op.r.Value = item.value
	op.r = op.r.Next()
}

pub fn (op &TakeLast) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &TakeLast) end(ctx context.Context, dst chan Item) {
	if op.count < op.n {
		remaining := op.n - op.count
		if remaining <= op.count {
			op.r = op.r.Move(op.n - op.count)
		} else {
			op.r = op.r.Move(-op.count)
		}
		op.n = op.count
	}
	for i := 0; i < op.n; i++ {
		of(op.r.Value).send_context(ctx, dst)
		op.r = op.r.Next()
	}
}

pub fn (op &TakeLast) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// TakeUntil returns an Observable that emits items emitted by the source Observable,
// checks the specified predicate for each item, and then completes when the condition is satisfied.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) take_until(apply Predicate, opts ...RxOption) Observable {
	return observable(o.parent, o, fn () Operator {
		return &TakeUntilOperator{
			apply: apply,
		}
	}, true, false, ...opts)
}

struct TakeUntilOperator {
	apply Predicate
}

pub fn (op &TakeUntilOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	item.send_context(ctx, dst)
	if op.apply(item.value) {
		operator_options.stop()
		return
	}
}

pub fn (op &TakeUntilOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &TakeUntilOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &TakeUntilOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// TakeWhile returns an Observable that emits items emitted by the source ObservableSource so long as each
// item satisfied a specified condition, and then completes as soon as this condition is not satisfied.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) take_while(apply Predicate, opts ...RxOption) Observable {
	return observable(o.parent, o, fn () Operator {
		return &TakeWhileOperator{
			apply: apply,
		}
	}, true, false, ...opts)
}

struct TakeWhileOperator {
	apply Predicate
}

pub fn (op &TakeWhileOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if !op.apply(item.value) {
		operator_options.stop()
		return
	}
	item.send_context(ctx, dst)
}

pub fn (op &TakeWhileOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &TakeWhileOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &TakeWhileOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// TimeInterval converts an Observable that emits items into one that emits indications of the amount of time elapsed between those emissions.
pub fn (o &ObservableImpl) time_interval(opts ...RxOption) Observable {
	f := fn (ctx context.Context, next chan Item, option Option, opts ...RxOption) {
		defer {
			next.close()
		}
		observe := o.observe(...opts)
		latest := time.Now().UTC()

		for select {
			case <-ctx.done():
				return
			item := <-observe:
				if !ok {
					return
				}
				if item.is_error() {
					if !item.send_context(ctx, next) {
						return
					}
					if option.get_error_strategy() == .stop_on_error {
						return
					}
				} else {
					now := time.Now().UTC()
					if !of(now.Sub(latest)).send_context(ctx, next) {
						return
					}
					latest = now
				}
			}
		}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// Timestamp attaches a timestamp to each item emitted by an Observable indicating when it was emitted.
pub fn (o &ObservableImpl) timestamp(opts ...RxOption) Observable {
	return observable(o.parent, o, fn () Operator {
		return &TimestampOperator{}
	}, true, false, ...opts)
}

struct TimestampOperator {
}

pub fn (op &TimestampOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	of(TimestampItem{
		Timestamp: time.Now().UTC(),
		V:         item.value,
	}).send_context(ctx, dst)
}

pub fn (op &TimestampOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &TimestampOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &TimestampOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// ToMap convert the sequence of items emitted by an Observable
// into a map keyed by a specified key function.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) to_map(keySelector Func, opts ...RxOption) Single {
	return single(o.parent, o, fn () Operator {
		return &ToMapOperator{
			keySelector: keySelector,
			m:           make(map[interface{}]interface{}),
		}
	}, true, false, ...opts)
}

struct ToMapOperator {
	keySelector Func
	m           map[interface{}]interface{}
}

pub fn (op &ToMapOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	k, err := op.keySelector(ctx, item.value)
	if err != nil {
		error(err).send_context(ctx, dst)
		operator_options.stop()
		return
	}
	op.m[k] = item.value
}

pub fn (op &ToMapOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &ToMapOperator) end(ctx context.Context, dst chan Item) {
	of(op.m).send_context(ctx, dst)
}

pub fn (op &ToMapOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// ToMapWithValueSelector convert the sequence of items emitted by an Observable
// into a map keyed by a specified key function and valued by another
// value function.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) to_map_with_value_selector(keySelector, valueSelector Func, opts ...RxOption) Single {
	return single(o.parent, o, fn () Operator {
		return &ToMapWithValueSelector{
			keySelector:   keySelector,
			valueSelector: valueSelector,
			m:             make(map[interface{}]interface{}),
		}
	}, true, false, ...opts)
}

struct ToMapWithValueSelector {
	keySelector, valueSelector Func
	m                          map[interface{}]interface{}
}

pub fn (op &ToMapWithValueSelector) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	k, err := op.keySelector(ctx, item.value)
	if err != nil {
		error(err).send_context(ctx, dst)
		operator_options.stop()
		return
	}

	v, err := op.valueSelector(ctx, item.value)
	if err != nil {
		error(err).send_context(ctx, dst)
		operator_options.stop()
		return
	}

	op.m[k] = v
}

pub fn (op &ToMapWithValueSelector) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

pub fn (op &ToMapWithValueSelector) end(ctx context.Context, dst chan Item) {
	of(op.m).send_context(ctx, dst)
}

pub fn (op &ToMapWithValueSelector) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// ToSlice collects all items from an Observable and emit them in a slice and an optional error.
// Cannot be run in parallel.
pub fn (o &ObservableImpl) to_slice(initialCapacity int, opts ...RxOption) ([]interface{}, error) {
	op := &toSliceOperator{
		s: make([]interface{}, 0, initialCapacity),
	}
	<-observable(o.parent, o, fn () Operator {
		return op
	}, true, false, ...opts).Run()
	return op.s, op.observableErr
}

struct ToSliceOperator {
	s             []interface{}
	observableErr error
}

pub fn (op &ToSliceOperator) next(_ context.Context, item Item, _ chan Item, _ operator_options) {
	op.s = append(op.s, item.value)
}

pub fn (op &ToSliceOperator) err(_ context.Context, item Item, _ chan Item, operator_options OperatorOptions) {
	op.observableErr = item.err
	operator_options.stop()
}

pub fn (op &ToSliceOperator) end(_ context.Context, _ chan Item) {
}

pub fn (op &ToSliceOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// Unmarshal transforms the items emitted by an Observable by applying an unmarshalling to each item.
pub fn (o &ObservableImpl) unmarshal(unmarshaller Unmarshaller, factory fn () interface{}, opts ...RxOption) Observable {
	return o.Map(fn (_ context.Context, i interface{}) (interface{}, error) {
		v := factory()
		err := unmarshaller(i.([]byte), v)
		if err != nil {
			return nil, err
		}
		return v, nil
	}, ...opts)
}

// WindowWithCount periodically subdivides items from an Observable into Observable windows of a given size and emit these windows
// rather than emitting the items one at a time.
pub fn (o &ObservableImpl) window_with_count(count int, opts ...RxOption) Observable {
	if count < 0 {
		return thrown(IllegalInputError{error: "count must be positive or nil"})
	}

	option := parse_options(...opts)
	return observable(o.parent, o, fn () Operator {
		return &WindowWithCountOperator{
			count:  count,
			option: option,
		}
	}, true, false, ...opts)
}

struct WindowWithCountOperator {
	count          int
	iCount         int
	currentChannel chan Item
	option         Option
}

pub fn (op &WindowWithCountOperator) pre(ctx context.Context, dst chan Item) {
	if op.currentChannel == nil {
		ch := op.option.buildChannel()
		op.currentChannel = ch
		of(FromChannel(ch)).send_context(ctx, dst)
	}
}

pub fn (op &WindowWithCountOperator) post(ctx context.Context, dst chan Item) {
	if op.iCount == op.count {
		op.iCount = 0
		close(op.currentChannel)
		ch := op.option.buildChannel()
		op.currentChannel = ch
		of(FromChannel(ch)).send_context(ctx, dst)
	}
}

pub fn (op &WindowWithCountOperator) next(ctx context.Context, item Item, dst chan Item, _ operator_options) {
	op.pre(ctx, dst)
	op.currentChannel <- item
	op.iCount++
	op.post(ctx, dst)
}

pub fn (op &WindowWithCountOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	op.pre(ctx, dst)
	op.currentChannel <- item
	op.iCount++
	op.post(ctx, dst)
	operator_options.stop()
}

pub fn (op &WindowWithCountOperator) end(_ context.Context, _ chan Item) {
	if op.currentChannel != nil {
		close(op.currentChannel)
	}
}

pub fn (op &WindowWithCountOperator) gather_next(_ context.Context, _ Item, _ chan Item, _ operator_options) {
}

// WindowWithTime periodically subdivides items from an Observable into Observables based on timed windows
// and emit them rather than emitting the items one at a time.
pub fn (o &ObservableImpl) window_with_time(timespan Duration, opts ...RxOption) Observable {
	if isnil(timespan) {
		return thrown(IllegalInputError{error: "timespan must no be nil"})
	}

	f := fn (ctx context.Context, next chan Item, option Option, opts ...RxOption) {
		observe := o.observe(...opts)
		ch := option.buildChannel()
		done := chan int{cap: 1}
		empty := true
		mutex := sync.new_mutex()
		if !of(FromChannel(ch)).send_context(ctx, next) {
			return
		}

		go fn () {
			defer fn () {
				mutex.@lock()
				close(ch)
				mutex.unlock()
			}()
			defer {
				next <- 0
				next.close()
			}
			for {
				select {
				case <-ctx.done():
					return
				case <-done:
					return
				case <-time.After(timespan.duration()):
					mutex.@lock()
					if empty {
						mutex.unlock()
						continue
					}
					close(ch)
					empty = true
					ch = option.buildChannel()
					if !of(FromChannel(ch)).send_context(ctx, next) {
						close(done)
						return
					}
					mutex.unlock()
				}
			}
		}()

		for select {
			case <-ctx.done():
				return
			case <-done:
				return
			item := <-observe:
				if !ok {
					close(done)
					return
				}
				if item.is_error() {
					mutex.@lock()
					if !item.send_context(ctx, ch) {
						mutex.unlock()
						close(done)
						return
					}
					mutex.unlock()
					if option.get_error_strategy() == .stop_on_error {
						close(done)
						return
					}
				}
				mutex.@lock()
				if !item.send_context(ctx, ch) {
					mutex.unlock()
					return
				}
				empty = false
				mutex.unlock()
			}
		}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// WindowWithTimeOrCount periodically subdivides items from an Observable into Observables based on timed windows or a specific size
// and emit them rather than emitting the items one at a time.
pub fn (o &ObservableImpl) window_with_time_or_count(timespan Duration, count int, opts ...RxOption) Observable {
	if isnil(timespan) {
		return thrown(IllegalInputError{error: "timespan must no be nil"})
	}
	if count < 0 {
		return thrown(IllegalInputError{error: "count must be positive or nil"})
	}

	f := fn (ctx context.Context, next chan Item, option Option, opts ...RxOption) {
		observe := o.observe(...opts)
		ch := option.buildChannel()
		done := chan int{cap: 1}
		mutex := sync.new_mutex()
		iCount := 0
		if !of(FromChannel(ch)).send_context(ctx, next) {
			return
		}

		go fn () {
			defer fn () {
				mutex.@lock()
				close(ch)
				mutex.unlock()
			}()
			defer {
				next <- 0
				next.close()
			}
			for {
				select {
				case <-ctx.done():
					return
				case <-done:
					return
				case <-time.After(timespan.duration()):
					mutex.@lock()
					if iCount == 0 {
						mutex.unlock()
						continue
					}
					close(ch)
					iCount = 0
					ch = option.buildChannel()
					if !of(FromChannel(ch)).send_context(ctx, next) {
						close(done)
						return
					}
					mutex.unlock()
				}
			}
		}()

		for select {
			case <-ctx.done():
				return
			case <-done:
				return
			item := <-observe:
				if !ok {
					close(done)
					return
				}
				if item.is_error() {
					mutex.@lock()
					if !item.send_context(ctx, ch) {
						mutex.unlock()
						close(done)
						return
					}
					mutex.unlock()
					if option.get_error_strategy() == .stop_on_error {
						close(done)
						return
					}
				}
				mutex.@lock()
				if !item.send_context(ctx, ch) {
					mutex.unlock()
					return
				}
				iCount++
				if iCount == count {
					close(ch)
					iCount = 0
					ch = option.buildChannel()
					if !of(FromChannel(ch)).send_context(ctx, next) {
						mutex.unlock()
						close(done)
						return
					}
				}
				mutex.unlock()
			}
		}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// ZipFromIterable merges the emissions of an Iterable via a specified function
// and emit single items for each combination based on the results of this function.
pub fn (o &ObservableImpl) zip_from_iterable(iterable Iterable, zipper Func2, opts ...RxOption) Observable {
	option := parse_options(...opts)
	next := option.buildChannel()
	ctx := option.build_context(o.parent)

	go fn () {
		defer {
			next.close()
		}
		it1 := o.observe(...opts)
		it2 := iterable.observe(...opts)
	loop:
		for select {
			case <-ctx.done():
				break loop
			case i1, ok := <-it1:
				if !ok {
					break loop
				}
				if i1.is_error() {
					i1.send_context(ctx, next)
					return
				}
				for {
					select {
					case <-ctx.done():
						break loop
					case i2, ok := <-it2:
						if !ok {
							break loop
						}
						if i2.is_error() {
							i2.send_context(ctx, next)
							return
						}
						v, err := zipper(ctx, i1.V, i2.V)
						if err != nil {
							error(err).send_context(ctx, next)
							return
						}
						of(v).send_context(ctx, next)
						continue loop
					}
				}
			}
		}
	}()

	return &ObservableImpl{
		iterable: newChannelIterable(next),
	}
}


