module rxv

import context
import time
import sync

fn from_channel_as_item_value(next chan Item, opts ...RxOption) ItemValue {
	o := &ObservableImpl(from_channel(next, ...opts))
	return ItemValue(o)
}

// all determines whether all items emitted by an Observable meet some criteria
pub fn (mut o ObservableImpl) all(predicate Predicate, opts ...RxOption) Single {
	return single(o.parent, mut o, fn () Operator {
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

fn (mut op AllOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if !op.predicate(item.value) {
		of(false).send_context(mut &ctx, dst)
		op.all = false
		operator_options.stop()
	}
}

fn (mut op AllOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

fn (mut op AllOperator) end(mut ctx context.Context, dst chan Item) {
	if op.all {
		of(true).send_context(mut &ctx, dst)
	}
}

fn (mut op AllOperator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value
	match value {
		bool {
			if value == false {
				of(false).send_context(mut &ctx, dst)
				op.all = false
				operator_options.stop()
			}
		}
		else {}
	}
}

// average_f32 calculates the average of numbers emitted by an Observable and emits the average f32
pub fn (mut o ObservableImpl) average_f32(opts ...RxOption) Single {
	return single(o.parent, mut o, fn () Operator {
		return &AverageF32Operator{}
	}, false, false, ...opts)
}

struct AverageF32Operator {
mut:
	count f32
	sum   f32
}

fn (mut op AverageF32Operator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
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
			from_error(new_illegal_input_error('expected type: f32, f64 or int, got $item')).send_context(ctx,
				dst)
			operator_options.stop()
		}
	}
}

fn (mut op AverageF32Operator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

fn (mut op AverageF32Operator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		of(f32(0)).send_context(mut &ctx, dst)
	} else {
		of(f32(op.sum / op.count)).send_context(mut &ctx, dst)
	}
}

fn (mut op AverageF32Operator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := &AverageF32Operator(item.value)
	op.sum += value.sum
	op.count += value.count
}

// average_f64 calculates the average of numbers emitted by an Observable and emits the average f64
pub fn (mut o ObservableImpl) average_f64(opts ...RxOption) Single {
	return single(o.parent, mut o, fn () Operator {
		return &AverageF64Operator{}
	}, false, false, ...opts)
}

struct AverageF64Operator {
mut:
	count f64
	sum   f64
}

fn (mut op AverageF64Operator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
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
			from_error(new_illegal_input_error('expected type: f32, f64 or int, got $item')).send_context(ctx,
				dst)
			operator_options.stop()
		}
	}
}

fn (mut op AverageF64Operator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

fn (mut op AverageF64Operator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		of(0.0).send_context(mut &ctx, dst)
	} else {
		of(op.sum / op.count).send_context(mut &ctx, dst)
	}
}

fn (mut op AverageF64Operator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := &AverageF64Operator(item.value)
	op.sum += value.sum
	op.count += value.count
}

// average_i32 calculates the average of numbers emitted by an Observable and emits the average i32
pub fn (mut o ObservableImpl) average_i32(opts ...RxOption) Single {
	return single(o.parent, mut o, fn () Operator {
		return &AverageIntOperator{}
	}, false, false, ...opts)
}

// average_int calculates the average of numbers emitted by an Observable and emits the average int
pub fn (mut o ObservableImpl) average_int(opts ...RxOption) Single {
	return single(o.parent, mut o, fn () Operator {
		return &AverageIntOperator{}
	}, false, false, ...opts)
}

struct AverageIntOperator {
mut:
	count int
	sum   int
}

fn (mut op AverageIntOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value
	match value {
		int {
			op.sum += value
			op.count++
		}
		else {
			from_error(new_illegal_input_error('expected type: int, got $item')).send_context(ctx,
				dst)
			operator_options.stop()
		}
	}
}

fn (mut op AverageIntOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

fn (mut op AverageIntOperator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		of(0).send_context(mut &ctx, dst)
	} else {
		of(op.sum / op.count).send_context(mut &ctx, dst)
	}
}

fn (mut op AverageIntOperator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := &AverageIntOperator(item.value)
	op.sum += value.sum
	op.count += value.count
}

// average_i16 calculates the average of numbers emitted by an Observable and emits the average i16
pub fn (mut o ObservableImpl) average_i16(opts ...RxOption) Single {
	return single(o.parent, mut o, fn () Operator {
		return &AverageI16Operator{}
	}, false, false, ...opts)
}

struct AverageI16Operator {
mut:
	count i16
	sum   i16
}

fn (mut op AverageI16Operator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value
	match value {
		i16 {
			op.sum += value
			op.count++
		}
		else {
			from_error(new_illegal_input_error('expected type: i16, got $item')).send_context(ctx,
				dst)
			operator_options.stop()
		}
	}
}

fn (mut op AverageI16Operator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

fn (mut op AverageI16Operator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		of(0).send_context(mut &ctx, dst)
	} else {
		of(op.sum / op.count).send_context(mut &ctx, dst)
	}
}

fn (mut op AverageI16Operator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := &AverageI16Operator(item.value)
	op.sum += value.sum
	op.count += value.count
}

// average_i64 calculates the average of numbers emitted by an Observable and emits the average i64
pub fn (mut o ObservableImpl) average_i64(opts ...RxOption) Single {
	return single(o.parent, mut o, fn () Operator {
		return &AverageI64Operator{}
	}, false, false, ...opts)
}

struct AverageI64Operator {
mut:
	count i64
	sum   i64
}

fn (mut op AverageI64Operator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value
	match value {
		i64 {
			op.sum += value
			op.count++
		}
		else {
			from_error(new_illegal_input_error('expected type: i64, got $item')).send_context(ctx,
				dst)
			operator_options.stop()
		}
	}
}

fn (mut op AverageI64Operator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

fn (mut op AverageI64Operator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		of(0).send_context(mut &ctx, dst)
	} else {
		of(op.sum / op.count).send_context(mut &ctx, dst)
	}
}

fn (mut op AverageI64Operator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := &AverageI64Operator(item.value)
	op.sum += value.sum
	op.count += value.count
}

// buffer_with_count returns an Observable that emits buffers of items it collects
// from the source Observable.
// The resulting Observable emits buffers every skip items, each containing a slice of count items.
// When the source Observable completes or encounters an error,
// the resulting Observable emits the current buffer and propagates
// the notification from the source Observable
pub fn (mut o ObservableImpl) buffer_with_count(count int, opts ...RxOption) Observable {
	if count <= 0 {
		return thrown(new_illegal_input_error('count must be positive'))
	}

	return observable(o.parent, mut o, fn [count] () Operator {
		return &BufferWithCountOperator{
			count: count
			buffer: []ItemValue{len: count, init: voidptr(0)}
		}
	}, true, false, ...opts)
}

struct BufferWithCountOperator {
mut:
	count   int
	i_count int
	buffer  []ItemValue
}

fn (mut op BufferWithCountOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	op.buffer[op.i_count] = item.value
	op.i_count++
	if op.i_count == op.count {
		of(op.buffer).send_context(mut &ctx, dst)
		op.i_count = 0
		op.buffer = []ItemValue{len: op.count, init: voidptr(0)}
	}
}

fn (mut op BufferWithCountOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

fn (mut op BufferWithCountOperator) end(mut ctx context.Context, dst chan Item) {
	if op.i_count != 0 {
		of(op.buffer[..op.i_count]).send_context(mut &ctx, dst)
	}
}

fn (mut op BufferWithCountOperator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {}

// buffer_with_time returns an Observable that emits buffers of items it collects from the source
// Observable. The resulting Observable starts a new buffer periodically, as determined by the
// timeshift argument. It emits each buffer after a fixed timespan, specified by the timespan argument.
// When the source Observable completes or encounters an error, the resulting Observable emits
// the current buffer and propagates the notification from the source Observable.
pub fn (mut o ObservableImpl) buffer_with_time(timespan Duration, opts ...RxOption) Observable {
	f := fn [timespan, mut o] (mut ctx context.Context, next chan Item, option RxOption, opts ...RxOption) {
		observe := o.observe(...opts)
		mut buffer := []ItemValue{}
		stop := chan int{cap: 1}
		mut mutex := sync.new_mutex()

		go fn [mut buffer, mut mutex] (mut ctx context.Context, next chan Item, stop chan int, timespan Duration) {
			defer {
				next.close()
			}

			check_buffer := fn [mut ctx, next, mut buffer, mut mutex] () {
				mutex.@lock()
				if buffer.len != 0 {
					if !of(buffer).send_context(mut &ctx, next) {
						mutex.unlock()
						return
					}
					buffer = []ItemValue{}
				}
				mutex.unlock()
			}

			duration := timespan.duration().nanoseconds()
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
			} {
			}
		}(mut &ctx, next, stop, timespan)

		done := ctx.done()

		for select {
			_ := <-done {
				stop <- 0
				stop.close()
				return
			}
			item := <-observe {
				if item.is_error() {
					item.send_context(mut &ctx, next)
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
		} {
		}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// buffer_with_time_or_count returns an Observable that emits buffers of items it collects from the source
// Observable either from a given count or at a given time interval.
pub fn (mut o ObservableImpl) buffer_with_time_or_count(timespan Duration, count int, opts ...RxOption) Observable {
	if count <= 0 {
		return thrown(new_illegal_input_error('count must be positive'))
	}

	f := fn [mut o, timespan, count] (mut ctx context.Context, next chan Item, option RxOption, opts ...RxOption) {
		observe := o.observe(...opts)
		mut buffer := []ItemValue{}
		mut mutex := sync.new_mutex()
		stop := chan int{cap: 1}
		send := chan int{cap: 1}

		go fn [mut buffer, mut mutex] (mut ctx context.Context, next chan Item, stop chan int, send chan int, timespan Duration) {
			defer {
				next.close()
			}

			check_buffer := fn [mut ctx, next, mut buffer, mut mutex] () {
				mutex.@lock()
				if buffer.len != 0 {
					if !of(buffer).send_context(mut &ctx, next) {
						mutex.unlock()
						return
					}
					buffer = []ItemValue{}
				}
				mutex.unlock()
			}

			duration := timespan.duration().nanoseconds()
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
			} {
			}
		}(mut &ctx, next, stop, send, timespan)

		done := ctx.done()

		for select {
			_ := <-done {
				return
			}
			item := <-observe {
				if item.is_error() {
					item.send_context(mut &ctx, next)
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
		} {
		}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// connect instructs a connectable Observable to begin emitting items to its subscribers.
pub fn (mut o ObservableImpl) connect(mut ctx context.Context) (context.Context, Disposable) {
	mut cancel_ctx, cancel := context.with_cancel(mut &ctx)
	o.observe(with_context(mut &cancel_ctx), connect())
	return cancel_ctx, Disposable(cancel)
}

// contains determines whether an Observable emits a particular item or not.
pub fn (mut o ObservableImpl) contains(equal Predicate, opts ...RxOption) Single {
	return single(o.parent, mut o, fn [equal] () Operator {
		return &ContainsOperator{
			equal: equal
			contains: false
		}
	}, false, false, ...opts)
}

struct ContainsOperator {
	equal Predicate
mut:
	contains bool
}

pub fn (mut op ContainsOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if op.equal(item.value) {
		of(true).send_context(mut &ctx, dst)
		op.contains = true
		operator_options.stop()
	}
}

pub fn (mut op ContainsOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op ContainsOperator) end(mut ctx context.Context, dst chan Item) {
	if !op.contains {
		of(false).send_context(mut &ctx, dst)
	}
}

pub fn (mut op ContainsOperator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if item.value is bool {
		if item.value == true {
			of(true).send_context(mut &ctx, dst)
			operator_options.stop()
			op.contains = true
		}
	}
}

// count counts the number of items emitted by the source Observable and emit only this value.
pub fn (mut o ObservableImpl) count(opts ...RxOption) Single {
	return single(o.parent, mut o, fn () Operator {
		return &CountOperator{}
	}, true, false, ...opts)
}

struct CountOperator {
mut:
	count i64
}

pub fn (mut op CountOperator) next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
	op.count++
}

pub fn (mut op CountOperator) err(mut _ context.Context, _ Item, _ chan Item, operator_options OperatorOptions) {
	operator_options.stop()
}

pub fn (mut op CountOperator) end(mut ctx context.Context, dst chan Item) {
	of(op.count).send_context(mut &ctx, dst)
}

pub fn (mut op CountOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// debounce only emits an item from an Observable if a particular timespan has passed without it emitting another item.
pub fn (mut o ObservableImpl) debounce(timespan Duration, opts ...RxOption) Observable {
	f := fn [timespan, mut o] (mut ctx context.Context, next chan Item, option RxOption, opts ...RxOption) {
		defer {
			next.close()
		}
		observe := o.observe(...opts)
		mut latest := ItemValue(voidptr(0))

		duration := timespan.duration().nanoseconds()
		done := ctx.done()

		for select {
			_ := <-done {
				return
			}
			item := <-observe {
				if item.is_error() {
					if !item.send_context(mut &ctx, next) {
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
				if !of(latest).send_context(mut &ctx, next) {
					return
				}
				latest = ItemValue(voidptr(0))
			}
		} {
		}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// default_if_empty returns an Observable that emits the items emitted by the source
// Observable or a specified default item if the source Observable is empty.
pub fn (mut o ObservableImpl) default_if_empty(default_value ItemValue, opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn [default_value] () Operator {
		return &DefaultIfEmptyOperator{
			default_value: default_value
			empty: true
		}
	}, true, false, ...opts)
}

struct DefaultIfEmptyOperator {
	default_value ItemValue
mut:
	empty bool
}

pub fn (mut op DefaultIfEmptyOperator) next(mut ctx context.Context, item Item, dst chan Item, _ OperatorOptions) {
	op.empty = false
	item.send_context(mut &ctx, dst)
}

pub fn (mut op DefaultIfEmptyOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op DefaultIfEmptyOperator) end(mut ctx context.Context, dst chan Item) {
	if op.empty {
		of(op.default_value).send_context(mut &ctx, dst)
	}
}

pub fn (mut op DefaultIfEmptyOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// distinct suppresses duplicate items in the original Observable and returns
// a new Observable.
pub fn (mut o ObservableImpl) distinct(apply Func, opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn [apply] () Operator {
		return &DistinctOperator{
			apply: apply
			keyset: map[voidptr]ItemValue{}
		}
	}, false, false, ...opts)
}

struct DistinctOperator {
	apply Func
mut:
	keyset map[voidptr]ItemValue
}

pub fn (mut op DistinctOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	key := op.apply(mut &ctx, item.value) or {
		from_error(err).send_context(mut &ctx, dst)
		operator_options.stop()
		return
	}

	if key !in op.keyset {
		item.send_context(mut &ctx, dst)
	}
	op.keyset[key] = true
}

pub fn (mut op DistinctOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op DistinctOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op DistinctOperator) gather_next(mut ctx context.Context, item Item, dst chan Item, _ OperatorOptions) {
	if item.value !is DistinctOperator {
		return
	}

	if item.value !in op.keyset {
		of(item.value).send_context(mut &ctx, dst)
		op.keyset[item.value] = true
	}
}

// distinct_until_changed suppresses consecutive duplicate items in the original Observable.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) distinct_until_changed(apply Func, opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn [apply] () Operator {
		return &DistinctUntilChangedOperator{
			apply: apply
		}
	}, true, false, ...opts)
}

struct DistinctUntilChangedOperator {
	apply Func
mut:
	current ItemValue
}

pub fn (mut op DistinctUntilChangedOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	key := op.apply(mut &ctx, item.value) or {
		from_error(err).send_context(mut &ctx, dst)
		operator_options.stop()
		return
	}
	if op.current != key {
		item.send_context(mut &ctx, dst)
		op.current = key
	}
}

pub fn (mut op DistinctUntilChangedOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op DistinctUntilChangedOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op DistinctUntilChangedOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// do_on_completed registers a callback action that will be called once the Observable terminates.
pub fn (mut o ObservableImpl) do_on_completed(handle_complete CompletedFunc, opts ...RxOption) chan int {
	dispose := chan int{cap: 1}

	handler := fn [dispose, handle_complete] (mut ctx context.Context, src chan Item) {
		defer {
			dispose <- 0
			dispose.close()
		}
		defer {
			handle_complete()
		}

		done := ctx.done()

		for select {
			_ := <-done {
				return
			}
			i := <-src {
				if i.is_error() {
					return
				}
			}
		} {
		}
	}

	option := parse_options(...opts)
	mut ctx := option.build_context(o.parent)
	go handler(mut &ctx, o.observe(...opts))
	return dispose
}

// do_on_error registers a callback action that will be called if the Observable terminates abnormally.
pub fn (mut o ObservableImpl) do_on_error(handle_err ErrFunc, opts ...RxOption) chan int {
	dispose := chan int{cap: 1}

	handler := fn [dispose, handle_err] (mut ctx context.Context, src chan Item) {
		defer {
			dispose <- 0
			dispose.close()
		}

		done := ctx.done()

		for select {
			_ := <-done {
				return
			}
			i := <-src {
				if i.is_error() {
					handle_err(i.err)
					return
				}
			}
		} {
		}
	}

	option := parse_options(...opts)
	mut ctx := option.build_context(o.parent)
	go handler(mut &ctx, o.observe(...opts))
	return dispose
}

// do_on_next registers a callback action that will be called on each item emitted by the Observable.
pub fn (mut o ObservableImpl) do_on_next(handle_next NextFunc, opts ...RxOption) chan int {
	dispose := chan int{cap: 1}

	handler := fn [dispose, handle_next] (mut ctx context.Context, src chan Item) {
		defer {
			dispose <- 0
			dispose.close()
		}

		done := ctx.done()

		for select {
			_ := <-done {
				return
			}
			i := <-src {
				if i.is_error() {
					return
				}
				handle_next(i.value)
			}
		} {
		}
	}

	option := parse_options(...opts)
	mut ctx := option.build_context(o.parent)
	go handler(mut &ctx, o.observe(...opts))
	return dispose
}

// element_at emits only item n emitted by an Observable.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) element_at(index u32, opts ...RxOption) Single {
	return single(o.parent, mut o, fn [index] () Operator {
		return &ElementAtOperator{
			index: index
		}
	}, true, false, ...opts)
}

struct ElementAtOperator {
mut:
	index      u32
	take_count int
	sent       bool
}

pub fn (mut op ElementAtOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if op.take_count == int(op.index) {
		item.send_context(mut &ctx, dst)
		op.sent = true
		operator_options.stop()
		return
	}
	op.take_count++
}

pub fn (mut op ElementAtOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op ElementAtOperator) end(mut ctx context.Context, dst chan Item) {
	if !op.sent {
		from_error(new_illegal_input_error('')).send_context(mut &ctx, dst)
	}
}

pub fn (mut op ElementAtOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// error returns the eventual Observable error.
// This method is blocking.
pub fn (mut o ObservableImpl) error(opts ...RxOption) IError {
	option := parse_options(...opts)
	mut ctx := option.build_context(o.parent)
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
	} {
	}

	return none
}

// errors returns an eventual list of Observable errors.
// This method is blocking
pub fn (mut o ObservableImpl) errors(opts ...RxOption) []IError {
	option := parse_options(...opts)
	mut ctx := option.build_context(o.parent)
	observe := o.iterable.observe(...opts)
	mut errs := []IError{}

	done := ctx.done()

	for select {
		_ := <-done {
			return [mut ctx.err()]
		}
		item := <-observe {
			if item.is_error() {
				errs << item.err
			}
		}
	} {
	}

	return errs
}

// filter emits only those items from an Observable that pass a predicate test.
pub fn (mut o ObservableImpl) filter(apply Predicate, opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn [apply] () Operator {
		return &FilterOperator{ apply: apply }
	}, false, true, ...opts)
}

struct FilterOperator {
	apply Predicate
}

pub fn (mut op FilterOperator) next(mut ctx context.Context, item Item, dst chan Item, _ OperatorOptions) {
	if op.apply(item.value) {
		item.send_context(mut &ctx, dst)
	}
}

pub fn (mut op FilterOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op FilterOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op FilterOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// find emits the first item passing a predicate then complete.
pub fn (mut o ObservableImpl) find(find Predicate, opts ...RxOption) OptionalSingle {
	return optional_single(o.parent, mut o, fn [find] () Operator {
		return &FindOperator{
			find: find
		}
	}, true, true, ...opts)
}

struct FindOperator {
	find Predicate
}

pub fn (mut op FindOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if op.find(item.value) {
		item.send_context(mut &ctx, dst)
		operator_options.stop()
	}
}

pub fn (mut op FindOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op FindOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op FindOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// first returns new Observable which emit only first item.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) first(opts ...RxOption) OptionalSingle {
	return optional_single(o.parent, mut o, fn () Operator {
		return &FirstOperator{}
	}, true, false, ...opts)
}

struct FirstOperator {}

pub fn (mut op FirstOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	item.send_context(mut &ctx, dst)
	operator_options.stop()
}

pub fn (mut op FirstOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op FirstOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op FirstOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// first_or_default returns new Observable which emit only first item.
// If the observable fails to emit any items, it emits a default value.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) first_or_default(default_value ItemValue, opts ...RxOption) Single {
	return single(o.parent, mut o, fn [default_value] () Operator {
		return &FirstOrDefaultOperator{
			default_value: default_value
		}
	}, true, false, ...opts)
}

struct FirstOrDefaultOperator {
	default_value ItemValue
mut:
	sent bool
}

pub fn (mut op FirstOrDefaultOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	item.send_context(mut &ctx, dst)
	op.sent = true
	operator_options.stop()
}

pub fn (mut op FirstOrDefaultOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op FirstOrDefaultOperator) end(mut ctx context.Context, dst chan Item) {
	if !op.sent {
		of(op.default_value).send_context(mut &ctx, dst)
	}
}

pub fn (mut op FirstOrDefaultOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// flat_map transforms the items emitted by an Observable into Observables, then flatten the emissions from those into a single Observable.
pub fn (mut o ObservableImpl) flat_map(apply ItemToObservable, opts ...RxOption) Observable {
	f := fn [mut o, apply] (mut ctx context.Context, next chan Item, option RxOption, opts ...RxOption) {
		defer {
			next.close()
		}

		observe := o.observe(...opts)
		mut observe2 := chan Item{}
		done := ctx.done()

		for select {
			_ := <-done {
				return
			}
			item := <-observe {
                                mut observable := apply(item)
				observe2 = observable.observe(...opts)
			}
			else {
				for select {
					_ := <-done {
						return
					}
					item := <-observe2 {
						if item.is_error() {
							item.send_context(mut &ctx, next)
							if option.get_error_strategy() == .stop_on_error {
								return
							}
						} else {
							if !item.send_context(mut &ctx, next) {
								return
							}
						}
					}
				} {
				}
			}
		} {
		}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// for_each subscribes to the Observable and receives notifications for each element.
pub fn (mut o ObservableImpl) for_each(handle_next NextFunc, handle_err ErrFunc, handle_complete CompletedFunc, opts ...RxOption) chan int {
	dispose := chan int{cap: 1}

	handler := fn [dispose, handle_next, handle_err, handle_complete] (mut ctx context.Context, src chan Item) {
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
			i := <-src {
				if i.is_error() {
					return
				}
				handle_next(i.value)
			}
		} {
		}
		{
			handle_complete()
		}
	}

	mut ctx := o.parent
	if isnil(ctx) {
		ctx = context.background()
	}
	go handler(mut &ctx, o.observe(...opts))
	return dispose
}

// ignore_elements ignores all items emitted by the source ObservableSource except for the errors.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) ignore_elements(opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn () Operator {
		return &IgnoreElementsOperator{}
	}, true, false, ...opts)
}

struct IgnoreElementsOperator {}

pub fn (mut op IgnoreElementsOperator) next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

pub fn (mut op IgnoreElementsOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op IgnoreElementsOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op IgnoreElementsOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// abs returns absolute value for i64
fn abs(n i64) i64 {
	y := n >> 63
	return (n ^ y) - y
}

pub type TimeExtractorFn = fn (ItemValue) time.Time

// Join combines items emitted by two Observables whenever an item from one Observable is emitted during
// a time window defined according to an item emitted by the other Observable.
// The time is extracted using a time_extractor function.
pub fn (mut o ObservableImpl) join(joiner Func2, mut right Observable, time_extractor TimeExtractorFn, window Duration, opts ...RxOption) Observable {
	f := fn [mut o, joiner, mut right, time_extractor, window] (mut ctx context.Context, next chan Item, option RxOption, opts ...RxOption) {
		defer {
			next.close()
		}
		window_duration := i64(window.duration())
		mut r_buf := []Item{}

		l_observe := o.observe()
		r_observe := right.observe()

		done := ctx.done()

		lloop: for select {
			_ := <-done {
				return
			}
			l_item := <-l_observe {
				if isnil(l_item.value) {
					return
				}
				if l_item.is_error() {
					l_item.send_context(mut &ctx, next)
					if option.get_error_strategy() == .stop_on_error {
						return
					}
					continue
				}
				l_time := time_extractor(l_item.value).unix_time()
				cut_point := 0
				for i, r_item in r_buf {
					r_time := time_extractor(r_item.value).unix_time()
					if abs(l_time - r_time) <= window_duration {
						if it := joiner(mut &ctx, l_item.value, r_item.value) {
							of(it).send_context(mut &ctx, next)
						} else {
							from_error(err).send_context(mut &ctx, next)
							if option.get_error_strategy() == .stop_on_error {
								return
							}
							continue
						}
					}
					if l_time > r_time + window_duration {
						cut_point = i + 1
					}
				}

				r_buf = r_buf[cut_point..]

				for select {
					_ := <-done {
						return
					}
					r_item := <-r_observe {
						if isnil(r_item.value) {
							// continue lloop
							continue
						}
						if r_item.is_error() {
							r_item.send_context(mut &ctx, next)
							if option.get_error_strategy() == .stop_on_error {
								return
							}
							continue
						}

						r_buf << r_item
						r_time := time_extractor(r_item.value).unix_time()
						if abs(l_time - r_time) <= window_duration {
							if i := joiner(mut &ctx, l_item.value, r_item.value) {
								of(i).send_context(mut &ctx, next)
								continue
							} else {
								from_error(err).send_context(mut &ctx, next)
								if option.get_error_strategy() == .stop_on_error {
									return
								}
								continue
							}
						}
						// continue lloop
						continue
					}
				} {
				}
			}
		} {
		}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// GroupBy divides an Observable into a set of Observables that each emit a different group of items from the original Observable, organized by key.
pub fn (mut o ObservableImpl) group_by(length int, distribution DistributionFn, opts ...RxOption) Observable {
	option := parse_options(...opts)
	mut ctx := option.build_context(o.parent)

	mut s := []Item{len: length}
	mut chs := []chan Item{len: length}
	for i in 0 .. length {
		ch := option.build_channel()
		chs[i] = ch
		s[i] = of(&ObservableImpl{
			iterable: new_channel_iterable(ch)
		})
	}

	go fn [mut ctx, mut o, opts, chs, length, distribution] () {
		observe := o.observe(...opts)
		defer {
			fn [chs, length] () {
				for i in 0 .. length {
					chs[i].close()
				}
			}()
		}

		done := ctx.done()
		for select {
			_ := <-done {
				return
			}
			item := <-observe {
				idx := distribution(item)
				if idx >= length {
					err := from_error(new_index_out_of_bound_error('index $idx, length $length'))
					for i in 0 .. length {
						err.send_context(mut &ctx, chs[i])
					}
					return
				}
				item.send_context(mut &ctx, chs[idx])
			}
		} {
		}
	}()

	return &ObservableImpl{
		iterable: new_slice_iterable(s, ...opts)
	}
}

// GroupedObservable is the observable type emitted by the GroupByDynamic operator.
struct GroupedObservable {
	ObservableImpl
	key string // key is the distribution key
}

// GroupByDynamic divides an Observable into a dynamic set of Observables that each emit GroupedObservable from the original Observable, organized by key.
pub fn (mut o ObservableImpl) group_by_dynamic(distribution DistributionStrFn, opts ...RxOption) Observable {
	option := parse_options(...opts)
	next := option.build_channel()
	mut ctx := option.build_context(o.parent)
	mut chs := map[string]chan Item{}

	go fn [mut o, mut ctx, distribution, opts, mut chs, option, next] () {
		observe := o.observe(...opts)

		done := ctx.done()
		for select {
			_ := <-done {
				break
			}
			i := <-observe {
				idx := distribution(i)
				if idx !in chs {
					ch := option.build_channel()
					chs[idx] = ch
					// @todo: Fix `undefined ident GroupedObservable`
					// grouped := &GroupedObservable
					// {
					// 	iterable:
					// 	new_channel_iterable(ch)
					// 	key:
					// 	idx
					// }
					// of(grouped).send_context(mut &ctx, next)
				}
				ch := chs[idx]
				i.send_context(mut &ctx, ch)
			}
		} {
		}
		for _, ch in chs {
			ch.close()
		}
		next.close()
	}()

	return &ObservableImpl{
		iterable: new_channel_iterable(next)
	}
}

// Last returns a new Observable which emit only last item.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) last(opts ...RxOption) OptionalSingle {
	return optional_single(o.parent, mut o, fn () Operator {
		return &LastOperator{
			empty: true
		}
	}, true, false, ...opts)
}

struct LastOperator {
mut:
	last  Item
	empty bool
}

pub fn (mut op LastOperator) next(mut _ context.Context, item Item, _ chan Item, _ OperatorOptions) {
	op.last = item
	op.empty = false
}

pub fn (mut op LastOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op LastOperator) end(mut ctx context.Context, dst chan Item) {
	if !op.empty {
		op.last.send_context(mut &ctx, dst)
	}
}

pub fn (mut op LastOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// LastOrDefault returns a new Observable which emit only last item.
// If the observable fails to emit any items, it emits a default value.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) last_or_default(default_value ItemValue, opts ...RxOption) Single {
	return single(o.parent, mut o, fn [default_value] () Operator {
		return &LastOrDefaultOperator{
			default_value: default_value
			empty: true
		}
	}, true, false, ...opts)
}

struct LastOrDefaultOperator {
	default_value ItemValue
mut:
	last  Item
	empty bool
}

pub fn (mut op LastOrDefaultOperator) next(mut _ context.Context, item Item, _ chan Item, _ OperatorOptions) {
	op.last = item
	op.empty = false
}

pub fn (mut op LastOrDefaultOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op LastOrDefaultOperator) end(mut ctx context.Context, dst chan Item) {
	if !op.empty {
		op.last.send_context(mut &ctx, dst)
	} else {
		of(op.default_value).send_context(mut &ctx, dst)
	}
}

pub fn (mut op LastOrDefaultOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// map transforms the items emitted by an Observable by applying a function to each item.
pub fn (mut o ObservableImpl) map(apply Func, opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn [apply] () Operator {
		return &MapOperator{ apply: apply }
	}, false, true, ...opts)
}

struct MapOperator {
	apply Func
}

pub fn (mut op MapOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	res := op.apply(mut &ctx, item.value) or {
		from_error(err).send_context(mut &ctx, dst)
		operator_options.stop()
		return
	}
	of(res).send_context(mut &ctx, dst)
}

pub fn (mut op MapOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op MapOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op MapOperator) gather_next(mut ctx context.Context, item Item, dst chan Item, _ OperatorOptions) {
	if item.value is MapOperator {
		return
	}
	item.send_context(mut &ctx, dst)
}

// Marshal transforms the items emitted by an Observable by applying a marshalling to each item.
pub fn (mut o ObservableImpl) marshal(marshaller Marshaller, opts ...RxOption) Observable {
	return o.map(fn [marshaller] (mut _ context.Context, i ItemValue) ?ItemValue {
		return i // (marshaller(i) ?).map(ItemValue(it))
	}, ...opts)
}

// Max determines and emits the maximum-valued item emitted by an Observable according to a comparator.
pub fn (mut o ObservableImpl) max(comparator Comparator, opts ...RxOption) OptionalSingle {
	return optional_single(o.parent, mut o, fn [comparator] () Operator {
		return &MaxOperator{
			comparator: comparator
			empty: true
		}
	}, false, false, ...opts)
}

struct MaxOperator {
	comparator Comparator
mut:
	empty bool
	max   ItemValue
}

pub fn (mut op MaxOperator) next(mut _ context.Context, item Item, _ chan Item, _ OperatorOptions) {
	op.empty = false

	if isnil(op.max) {
		op.max = item.value
	} else {
		if op.comparator(op.max, item.value) < 0 {
			op.max = item.value
		}
	}
}

pub fn (mut op MaxOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op MaxOperator) end(mut ctx context.Context, dst chan Item) {
	if !op.empty {
		of(op.max).send_context(mut &ctx, dst)
	}
}

pub fn (mut op MaxOperator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	val := item.value
	match val {
		MaxOperator {
			op.next(mut &ctx, of(val.max), dst, operator_options)
		}
		else {}
	}
}

// Min determines and emits the minimum-valued item emitted by an Observable according to a comparator.
pub fn (mut o ObservableImpl) min(comparator Comparator, opts ...RxOption) OptionalSingle {
	return optional_single(o.parent, mut o, fn [comparator] () Operator {
		return &MinOperator{
			comparator: comparator
			empty: true
		}
	}, false, false, ...opts)
}

struct MinOperator {
	comparator Comparator
mut:
	empty bool
	max   ItemValue
}

pub fn (mut op MinOperator) next(mut _ context.Context, item Item, _ chan Item, _ OperatorOptions) {
	op.empty = false

	if isnil(op.max) {
		op.max = item.value
	} else {
		if op.comparator(op.max, item.value) > 0 {
			op.max = item.value
		}
	}
}

pub fn (mut op MinOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op MinOperator) end(mut ctx context.Context, dst chan Item) {
	if !op.empty {
		of(op.max).send_context(mut &ctx, dst)
	}
}

pub fn (mut op MinOperator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	val := item.value
	match val {
		MinOperator {
			op.next(mut &ctx, of(val.max), dst, operator_options)
		}
		else {}
	}
}

// Observe observes an Observable by returning its channel.
pub fn (mut o ObservableImpl) observe(opts ...RxOption) chan Item {
	return o.iterable.observe(...opts)
}

// OnErrorResumeNext instructs an Observable to pass control to another Observable rather than invoking
// onError if it encounters an error.
pub fn (mut o ObservableImpl) on_error_resume_next(resume_sequence ErrorToObservable, opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn [resume_sequence] () Operator {
		return &OnErrorResumeNextOperator{ resume_sequence: resume_sequence }
	}, true, false, ...opts)
}

struct OnErrorResumeNextOperator {
	resume_sequence ErrorToObservable
}

pub fn (mut op OnErrorResumeNextOperator) next(mut ctx context.Context, item Item, dst chan Item, _ OperatorOptions) {
	item.send_context(mut &ctx, dst)
}

pub fn (mut op OnErrorResumeNextOperator) err(mut _ context.Context, item Item, _ chan Item, operator_options OperatorOptions) {
	mut observable := op.resume_sequence(item.err)
        // operator_options.reset_iterable(mut &observable)
}

pub fn (mut op OnErrorResumeNextOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op OnErrorResumeNextOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// OnErrorReturn instructs an Observable to emit an item (returned by a specified function)
// rather than invoking onError if it encounters an error.
pub fn (mut o ObservableImpl) on_error_return(resume_fn ErrorFunc, opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn [resume_fn] () Operator {
		return &OnErrorReturnOperator{ resume_fn: resume_fn }
	}, true, false, ...opts)
}

struct OnErrorReturnOperator {
	resume_fn ErrorFunc
}

pub fn (mut op OnErrorReturnOperator) next(mut ctx context.Context, item Item, dst chan Item, _ OperatorOptions) {
	item.send_context(mut &ctx, dst)
}

pub fn (mut op OnErrorReturnOperator) err(mut ctx context.Context, item Item, dst chan Item, _ OperatorOptions) {
	of(op.resume_fn(item.err)).send_context(mut &ctx, dst)
}

pub fn (mut op OnErrorReturnOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op OnErrorReturnOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// OnErrorReturnItem instructs on Observable to emit an item if it encounters an error.
pub fn (mut o ObservableImpl) on_error_return_item(resume ItemValue, opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn [resume] () Operator {
		return &OnErrorReturnItemOperator{ resume: resume }
	}, true, false, ...opts)
}

struct OnErrorReturnItemOperator {
	resume ItemValue
}

pub fn (mut op OnErrorReturnItemOperator) next(mut ctx context.Context, item Item, dst chan Item, _ OperatorOptions) {
	item.send_context(mut &ctx, dst)
}

pub fn (mut op OnErrorReturnItemOperator) err(mut ctx context.Context, _ Item, dst chan Item, _ OperatorOptions) {
	of(op.resume).send_context(mut &ctx, dst)
}

pub fn (mut op OnErrorReturnItemOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op OnErrorReturnItemOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// Reduce applies a function to each item emitted by an Observable, sequentially, and emit the final value.
pub fn (mut o ObservableImpl) reduce(apply Func2, opts ...RxOption) OptionalSingle {
	return optional_single(o.parent, mut o, fn [apply] () Operator {
		return &ReduceOperator{
			apply: apply
			empty: true
		}
	}, false, false, ...opts)
}

struct ReduceOperator {
	apply Func2
mut:
	acc   ItemValue
	empty bool
}

pub fn (mut op ReduceOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	op.empty = false
	v := op.apply(mut &ctx, op.acc, item.value) or {
		from_error(err).send_context(mut &ctx, dst)
		operator_options.stop()
		op.empty = true
		return
	}
	op.acc = v
}

pub fn (mut op ReduceOperator) err(mut _ context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	dst <- item
	operator_options.stop()
	op.empty = true
}

pub fn (mut op ReduceOperator) end(mut ctx context.Context, dst chan Item) {
	if !op.empty {
		of(op.acc).send_context(mut &ctx, dst)
	}
}

pub fn (mut op ReduceOperator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	val := item.value
	match val {
		ReduceOperator {
			op.next(mut &ctx, of(val.acc), dst, operator_options)
		}
		else {}
	}
}

// Repeat returns an Observable that repeats the sequence of items emitted by the source Observable
// at most count times, at a particular frequency.
// Cannot run in parallel.
pub fn (mut o ObservableImpl) repeat(count i64, frequency Duration, opts ...RxOption) Observable {
	if count != infinite {
		if count < 0 {
			return thrown(new_illegal_input_error('count must be positive'))
		}
	}

	return observable(o.parent, mut o, fn [count, frequency] () Operator {
		return &RepeatOperator{
			count: count
			frequency: frequency
			seq: []Item{}
		}
	}, true, false, ...opts)
}

struct RepeatOperator {
mut:
	count     i64
	frequency Duration
	seq       []Item
}

pub fn (mut op RepeatOperator) next(mut ctx context.Context, item Item, dst chan Item, _ OperatorOptions) {
	item.send_context(mut &ctx, dst)
	op.seq << item
}

pub fn (mut op RepeatOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op RepeatOperator) end(mut ctx context.Context, dst chan Item) {
	for {
		done := ctx.done()
		select {
			_ := <-done {
				return
			}
			else {}
		}
		if op.count != infinite {
			if op.count == 0 {
				break
			}
		}
		if !isnil(op.frequency) {
			time.sleep(op.frequency.duration())
		}
		for v in op.seq {
			v.send_context(mut &ctx, dst)
		}
		op.count = op.count - 1
	}
}

pub fn (mut op RepeatOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// Retry retries if a source Observable sends an error, resubscribe to it in the hopes that it will complete without error.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) retry(count int, should_retry RetryFn, opts ...RxOption) Observable {
	option := parse_options(...opts)
	next := option.build_channel()
	mut ctx := option.build_context(o.parent)
	mut aux_count := count

	go fn [mut o, opts, next, mut ctx, mut aux_count, should_retry] () {
		mut observe := o.observe(...opts)

		done := ctx.done()
		loop: for select {
			_ := <-done {
				// break loop
				break
			}
			i := <-observe {
				if i.is_error() {
					aux_count--
					if aux_count < 0 || !should_retry(i.err) {
						i.send_context(mut &ctx, next)
						// break loop
						break
					}
					observe = o.observe(...opts)
				} else {
					i.send_context(mut &ctx, next)
				}
			}
		} {
		}
		next.close()
	}()

	return &ObservableImpl{
		iterable: new_channel_iterable(next)
	}
}

// Run creates an Observer without consuming the emitted items.
pub fn (mut o ObservableImpl) run(opts ...RxOption) chan int {
	dispose := chan int{cap: 1}
	option := parse_options(...opts)
	mut ctx := option.build_context(o.parent)

	go fn [dispose, mut ctx, mut o, opts] () {
		defer {
			dispose <- 0
			dispose.close()
		}
		observe := o.observe(...opts)
		done := ctx.done()
		for select {
			_ := <-done {
				return
			}
			_ := <-observe {}
		} {
		}
	}()

	return dispose
}

// Sample returns an Observable that emits the most recent items emitted by the source
// Iterable whenever the input Iterable emits an item.
pub fn (mut o ObservableImpl) sample(mut iterable Iterable, opts ...RxOption) Observable {
	option := parse_options(...opts)
	next := option.build_channel()
	mut ctx := option.build_context(o.parent)
	it_ch := chan Item{}
	obs_ch := chan Item{}

	go fn [mut ctx, mut o, opts, obs_ch] () {
		defer {
			obs_ch.close()
		}
		observe := o.observe(...opts)
		done := ctx.done()
		for select {
			_ := <-done {
				return
			}
			i := <-observe {
				i.send_context(mut &ctx, obs_ch)
			}
		} {
		}
	}()

	go fn [it_ch, mut iterable, opts, mut ctx] () {
		defer {
			it_ch.close()
		}
		observe := iterable.observe(...opts)
		done := ctx.done()
		for select {
			_ := <-done {
				return
			}
			i := <-observe {
				i.send_context(mut &ctx, it_ch)
			}
		} {
		}
	}()

	go fn [next, it_ch, next, obs_ch] () {
		defer {
			next.close()
		}
		mut last_emitted_item := Item{}
		mut is_item_waiting_to_be_emitted := false

		for select {
			_ := <-it_ch {
				if is_item_waiting_to_be_emitted {
					next <- last_emitted_item
					is_item_waiting_to_be_emitted = false
				}
			}
			item := <-obs_ch {
				last_emitted_item = item
				is_item_waiting_to_be_emitted = true
			}
		} {
		}
	}()

	return &ObservableImpl{
		iterable: new_channel_iterable(next)
	}
}

// Scan apply a Func2 to each item emitted by an Observable, sequentially, and emit each successive value.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) scan(apply Func2, opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn [apply] () Operator {
		return &ScanOperator{
			apply: apply
		}
	}, true, false, ...opts)
}

struct ScanOperator {
	apply Func2
mut:
	current ItemValue
}

pub fn (mut op ScanOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	v := op.apply(mut &ctx, op.current, item.value) or {
		from_error(err).send_context(mut &ctx, dst)
		operator_options.stop()
		return
	}
	of(v).send_context(mut &ctx, dst)
	op.current = v
}

pub fn (mut op ScanOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op ScanOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op ScanOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// Compares first items of two sequences and returns true if they are equal and false if
// they are not. Besides, it returns two new sequences - input sequences without compared items.
fn pop_and_compare_first_items(input_sequence1 []ItemValue, input_sequence2 []ItemValue) (bool, []ItemValue, []ItemValue) {
	if input_sequence1.len > 0 && input_sequence2.len > 0 {
		s1, sequence1 := input_sequence1[0], input_sequence1[1..]
		s2, sequence2 := input_sequence2[0], input_sequence2[1..]
		return s1 == s2, sequence1, sequence2
	}
	return true, input_sequence1, input_sequence2
}

// Send sends the items to a given channel.
pub fn (mut o ObservableImpl) send(output chan Item, opts ...RxOption) {
	go fn [mut o, output, opts] () {
		option := parse_options(...opts)
		mut ctx := option.build_context(o.parent)
		observe := o.observe(...opts)

		done := ctx.done()
		loop: for select {
			_ := <-done {
				// break loop
				break
			}
			i := <-observe {
				if i.is_error() {
					output <- i
					// break loop
					break
				}
				i.send_context(mut &ctx, output)
			}
		} {
		}
		output.close()
	}()
}

// SequenceEqual emits true if an Observable and the input Observable emit the same items,
// in the same order, with the same termination state. Otherwise, it emits false.
pub fn (mut o ObservableImpl) sequence_equal(mut iterable Iterable, opts ...RxOption) Single {
	option := parse_options(...opts)
	next := option.build_channel()
	mut ctx := option.build_context(o.parent)
	it_ch := chan Item{}
	obs_ch := chan Item{}

	go fn [mut o, mut ctx, obs_ch, opts] () {
		defer {
			obs_ch.close()
		}
		observe := o.observe(...opts)
		done := ctx.done()
		for select {
			_ := <-done {
				return
			}
			i := <-observe {
				i.send_context(mut &ctx, obs_ch)
			}
		} {
		}
	}()

	go fn [mut o, mut ctx, it_ch, opts, mut iterable] () {
		defer {
			it_ch.close()
		}
		observe := iterable.observe(...opts)
		done := ctx.done()
		for select {
			_ := <-done {
				return
			}
			i := <-observe {
				i.send_context(mut &ctx, it_ch)
			}
		} {
		}
	}()

	go fn [mut ctx, next, it_ch, obs_ch] () {
		mut main_sequence := []ItemValue{}
		mut obs_sequence := []ItemValue{}
		mut are_correct := true

		main_loop: for {
			select {
				item := <-it_ch {
					main_sequence << item
					are_correct, main_sequence, obs_sequence = pop_and_compare_first_items(main_sequence,
						obs_sequence)
				}
				item := <-obs_ch {
					obs_sequence << item
					are_correct, main_sequence, obs_sequence = pop_and_compare_first_items(main_sequence,
						obs_sequence)
				}
			}

			if !are_correct || (it_ch.closed && obs_ch.closed) {
				break main_loop
			}
		}

		of(are_correct && main_sequence.len == 0 && obs_sequence.len == 0).send_context(ctx,
			next)
		next.close()
	}()

	return &SingleImpl{
		iterable: new_channel_iterable(next)
	}
}

// Serialize forces an Observable to make serialized calls and to be well-behaved.
pub fn (mut o ObservableImpl) serialize(from context.Context, identifier IdentifierFn, opts ...RxOption) Observable {
	option := parse_options(...opts)
	next := option.build_channel()

	return &ObservableImpl{
		iterable: new_channel_iterable(next)
	}
}

// Skip suppresses the first n items in the original Observable and
// returns a new Observable with the rest items.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) skip(nth u32, opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn [nth] () Operator {
		return &SkipOperator{
			nth: nth
		}
	}, true, false, ...opts)
}

struct SkipOperator {
mut:
	nth        u32
	skip_count int
}

pub fn (mut op SkipOperator) next(mut ctx context.Context, item Item, dst chan Item, _ OperatorOptions) {
	if op.skip_count < int(op.nth) {
		op.skip_count++
		return
	}
	item.send_context(mut &ctx, dst)
}

pub fn (mut op SkipOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op SkipOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op SkipOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// SkipLast suppresses the last n items in the original Observable and
// returns a new Observable with the rest items.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) skip_last(nth u32, opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn [nth] () Operator {
		return &SkipLastOperator{
			nth: nth
		}
	}, true, false, ...opts)
}

struct SkipLastOperator {
mut:
	nth        u32
	skip_count int
}

pub fn (mut op SkipLastOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if op.skip_count >= int(op.nth) {
		operator_options.stop()
		return
	}
	op.skip_count++
	item.send_context(mut &ctx, dst)
}

pub fn (mut op SkipLastOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op SkipLastOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op SkipLastOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// SkipWhile discard items emitted by an Observable until a specified condition becomes false.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) skip_while(apply Predicate, opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn [apply] () Operator {
		return &SkipWhileOperator{
			apply: apply
			skip: true
		}
	}, true, false, ...opts)
}

struct SkipWhileOperator {
	apply Predicate
mut:
	skip bool
}

pub fn (mut op SkipWhileOperator) next(mut ctx context.Context, item Item, dst chan Item, _ OperatorOptions) {
	if !op.skip {
		item.send_context(mut &ctx, dst)
	} else {
		if !op.apply(item.value) {
			op.skip = false
			item.send_context(mut &ctx, dst)
		}
	}
}

pub fn (mut op SkipWhileOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op SkipWhileOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op SkipWhileOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// StartWith emits a specified Iterable before beginning to emit the items from the source Observable.
pub fn (mut o ObservableImpl) start_with(mut iterable Iterable, opts ...RxOption) Observable {
	option := parse_options(...opts)
	next := option.build_channel()
	mut ctx := option.build_context(o.parent)

	go fn [mut o, mut ctx, next, option, mut iterable, opts] () {
		defer {
			next.close()
		}
		mut observe := iterable.observe(...opts)

		done := ctx.done()
		loop1: for select {
			_ := <-done {
				// break loop1
				break
			}
			i := <-observe {
				if i.is_error() {
					next <- i
					return
				}
				i.send_context(mut &ctx, next)
			}
		} {
		}
		observe = o.observe(...opts)

		loop2: for select {
			_ := <-done {
				// break loop2
				break
			}
			i := <-observe {
				if i.is_error() {
					i.send_context(mut &ctx, next)
					return
				}
				i.send_context(mut &ctx, next)
			}
		} {
		}
	}()

	return &ObservableImpl{
		iterable: new_channel_iterable(next)
	}
}

// sum_f32 calculates the average of f32 emitted by an Observable and emits a f32.
pub fn (mut o ObservableImpl) sum_f32(opts ...RxOption) OptionalSingle {
	return o.reduce(fn (mut _ context.Context, acc ItemValue, i ItemValue) ?ItemValue {
		sum := match acc {
			f32 { *acc }
			else { f32(0) }
		}
		match i {
			int {
				return ItemValue(sum + f32(*i))
			}
			i8 {
				return ItemValue(sum + f32(*i))
			}
			i16 {
				return ItemValue(sum + f32(*i))
			}
			i64 {
				return ItemValue(sum + f32(*i))
			}
			f32 {
				return ItemValue(sum + *i)
			}
			else {
				return new_illegal_input_error('expected type: (f32|int|i8|i16|int|i64), got: $i')
			}
		}
	}, ...opts)
}

// sum_f64 calculates the average of f64 emitted by an Observable and emits a f64.
pub fn (mut o ObservableImpl) sum_f64(opts ...RxOption) OptionalSingle {
	return o.reduce(fn (mut _ context.Context, acc ItemValue, i ItemValue) ?ItemValue {
		sum := match acc {
			f64 { *acc }
			else { f64(0) }
		}
		match i {
			int {
				return ItemValue(sum + f64(*i))
			}
			i8 {
				return ItemValue(sum + f64(*i))
			}
			i16 {
				return ItemValue(sum + f64(*i))
			}
			i64 {
				return ItemValue(sum + f64(*i))
			}
			f32 {
				return ItemValue(sum + f64(*i))
			}
			f64 {
				return ItemValue(sum + *i)
			}
			else {
				return new_illegal_input_error('expected type: (f32|f64|int|i8|i16|int|i64), got: $i')
			}
		}
	}, ...opts)
}

// sum_i64 calculates the average of integers emitted by an Observable and emits an i64.
pub fn (mut o ObservableImpl) sum_i64(opts ...RxOption) OptionalSingle {
	return o.reduce(fn (mut _ context.Context, acc ItemValue, i ItemValue) ?ItemValue {
		sum := match acc {
			i64 { *acc }
			else { i64(0) }
		}
		match i {
			int {
				return ItemValue(sum + i64(*i))
			}
			i8 {
				return ItemValue(sum + i64(*i))
			}
			i16 {
				return ItemValue(sum + i64(*i))
			}
			i64 {
				return ItemValue(sum + *i)
			}
			else {
				return new_illegal_input_error('expected type: (int|i8|i16|int|i64), got: $i')
			}
		}
	}, ...opts)
}

// take emits only the first n items emitted by an Observable.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) take(nth u32, opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn [nth] () Operator {
		return &TakeOperator{
			nth: nth
		}
	}, true, false, ...opts)
}

struct TakeOperator {
mut:
	nth        u32
	take_count int
}

pub fn (mut op TakeOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if op.take_count >= int(op.nth) {
		operator_options.stop()
		return
	}

	op.take_count++
	item.send_context(mut &ctx, dst)
}

pub fn (mut op TakeOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op TakeOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op TakeOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// take_until returns an Observable that emits items emitted by the source Observable,
// checks the specified predicate for each item, and then completes when the condition is satisfied.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) take_until(apply Predicate, opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn [apply] () Operator {
		return &TakeUntilOperator{
			apply: apply
		}
	}, true, false, ...opts)
}

struct TakeUntilOperator {
	apply Predicate
}

pub fn (mut op TakeUntilOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	item.send_context(mut &ctx, dst)
	if op.apply(item.value) {
		operator_options.stop()
		return
	}
}

pub fn (mut op TakeUntilOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op TakeUntilOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op TakeUntilOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// take_while returns an Observable that emits items emitted by the source ObservableSource so long as each
// item satisfied a specified condition, and then completes as soon as this condition is not satisfied.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) take_while(apply Predicate, opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn [apply] () Operator {
		return &TakeWhileOperator{
			apply: apply
		}
	}, true, false, ...opts)
}

struct TakeWhileOperator {
	apply Predicate
}

pub fn (mut op TakeWhileOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	if !op.apply(item.value) {
		operator_options.stop()
		return
	}
	item.send_context(mut &ctx, dst)
}

pub fn (mut op TakeWhileOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op TakeWhileOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op TakeWhileOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// time_interval converts an Observable that emits items into one that emits indications of the amount of time elapsed between those emissions.
pub fn (mut o ObservableImpl) time_interval(opts ...RxOption) Observable {
	f := fn [mut o] (mut ctx context.Context, next chan Item, option RxOption, opts ...RxOption) {
		defer {
			next.close()
		}
		observe := o.observe(...opts)
		mut latest := time.now().unix_time()

		done := ctx.done()
		for select {
			_ := <-done {
				return
			}
			item := <-observe {
				if item.is_error() {
					if !item.send_context(mut &ctx, next) {
						return
					}
					if option.get_error_strategy() == .stop_on_error {
						return
					}
				} else {
					now := time.now().unix_time()
					if !of(now - latest).send_context(mut &ctx, next) {
						return
					}
					latest = now
				}
			}
		} {
		}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// Timestamp attaches a timestamp to each item emitted by an Observable indicating when it was emitted.
pub fn (mut o ObservableImpl) timestamp(opts ...RxOption) Observable {
	return observable(o.parent, mut o, fn () Operator {
		return &TimestampOperator{}
	}, true, false, ...opts)
}

struct TimestampOperator {
}

pub fn (mut op TimestampOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	of(&TimestampItem{
		timestamp: time.now()
		value: item.value
	}).send_context(mut &ctx, dst)
}

pub fn (mut op TimestampOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op TimestampOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op TimestampOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// ToMap convert the sequence of items emitted by an Observable
// into a map keyed by a specified key function.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) to_map(key_selector Func, opts ...RxOption) Single {
	return single(o.parent, mut o, fn [key_selector] () Operator {
		return &ToMapOperator{
			key_selector: key_selector
			m: map[voidptr]ItemValue{}
		}
	}, true, false, ...opts)
}

struct ToMapOperator {
	key_selector Func
mut:
	m map[voidptr]ItemValue
}

pub fn (mut op ToMapOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	k := op.key_selector(mut &ctx, item.value) or {
		from_error(err).send_context(mut &ctx, dst)
		operator_options.stop()
		return
	}
	op.m[k] = item.value
}

pub fn (mut op ToMapOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op ToMapOperator) end(mut ctx context.Context, dst chan Item) {
	of(op.m).send_context(mut &ctx, dst)
}

pub fn (mut op ToMapOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// ToMapWithValueSelector convert the sequence of items emitted by an Observable
// into a map keyed by a specified key function and valued by another
// value function.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) to_map_with_value_selector(key_selector Func, value_selector Func, opts ...RxOption) Single {
	return single(o.parent, mut o, fn [key_selector, value_selector] () Operator {
		return &ToMapWithValueSelector{
			key_selector: key_selector
			value_selector: value_selector
			m: map[voidptr]ItemValue{}
		}
	}, true, false, ...opts)
}

struct ToMapWithValueSelector {
	key_selector   Func
	value_selector Func
mut:
	m map[voidptr]ItemValue
}

pub fn (mut op ToMapWithValueSelector) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	k := op.key_selector(mut &ctx, item.value) or {
		from_error(err).send_context(mut &ctx, dst)
		operator_options.stop()
		return
	}

	v := op.value_selector(mut &ctx, item.value) or {
		from_error(err).send_context(mut &ctx, dst)
		operator_options.stop()
		return
	}

	op.m[k] = v
}

pub fn (mut op ToMapWithValueSelector) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

pub fn (mut op ToMapWithValueSelector) end(mut ctx context.Context, dst chan Item) {
	of(op.m).send_context(mut &ctx, dst)
}

pub fn (mut op ToMapWithValueSelector) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// ToSlice collects all items from an Observable and emit them in a slice and an optional error.
// Cannot be run in parallel.
pub fn (mut o ObservableImpl) to_slice(initial_capacity int, opts ...RxOption) ?[]ItemValue {
	op := &ToSliceOperator{
		s: []ItemValue{cap: initial_capacity}
	}
        mut obser := observable(o.parent, mut o, fn [op] () Operator {
		return op
	}, true, false, ...opts)
	_ := <-obser.run()

	if !isnil(op.observable_err) {
		return op.observable_err
	}

	return op.s
}

struct ToSliceOperator {
mut:
	s              []ItemValue
	observable_err IError
}

pub fn (mut op ToSliceOperator) next(mut _ context.Context, item Item, _ chan Item, _ OperatorOptions) {
	op.s << item.value
}

pub fn (mut op ToSliceOperator) err(mut _ context.Context, item Item, _ chan Item, operator_options OperatorOptions) {
	op.observable_err = item.err
	operator_options.stop()
}

pub fn (mut op ToSliceOperator) end(mut _ context.Context, _ chan Item) {
}

pub fn (mut op ToSliceOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// Unmarshal transforms the items emitted by an Observable by applying an unmarshalling to each item.
pub fn (mut o ObservableImpl) unmarshal(unmarshaller Unmarshaller, factory FactoryFn, opts ...RxOption) Observable {
	return o.map(fn [unmarshaller, factory] (mut _ context.Context, i ItemValue) ?ItemValue {
		v := factory()
		match i {
			// []byte {
			// 	unmarshaller(i, v)
			// }
			else {}
		}
		return v
	}, ...opts)
}

// WindowWithCount periodically subdivides items from an Observable into Observable windows of a given size and emit these windows
// rather than emitting the items one at a time.
pub fn (mut o ObservableImpl) window_with_count(count int, opts ...RxOption) Observable {
	if count < 0 {
		return thrown(new_illegal_input_error('count must be positive or nil'))
	}

	option := parse_options(...opts)
	return observable(o.parent, mut o, fn [count, option] () Operator {
		return &WindowWithCountOperator{
			count: count
			option: option
		}
	}, true, false, ...opts)
}

struct WindowWithCountOperator {
mut:
	count           int
	i_count         int
	current_channel chan Item
	option          RxOption
}

pub fn (mut op WindowWithCountOperator) pre(mut ctx context.Context, dst chan Item) {
	if isnil(op.current_channel) {
		ch := op.option.build_channel()
		op.current_channel = ch
		of(from_channel_as_item_value(ch)).send_context(mut &ctx, dst)
	}
}

pub fn (mut op WindowWithCountOperator) post(mut ctx context.Context, dst chan Item) {
	if op.i_count == op.count {
		op.i_count = 0
		op.current_channel.close()
		ch := op.option.build_channel()
		op.current_channel = ch
		of(from_channel_as_item_value(ch)).send_context(mut &ctx, dst)
	}
}

pub fn (mut op WindowWithCountOperator) next(mut ctx context.Context, item Item, dst chan Item, _ OperatorOptions) {
	op.pre(mut &ctx, dst)
	op.current_channel <- item
	op.i_count++
	op.post(mut &ctx, dst)
}

pub fn (mut op WindowWithCountOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	op.pre(mut &ctx, dst)
	op.current_channel <- item
	op.i_count++
	op.post(mut &ctx, dst)
	operator_options.stop()
}

pub fn (mut op WindowWithCountOperator) end(mut _ context.Context, _ chan Item) {
	if !op.current_channel.closed {
		op.current_channel.close()
	}
}

pub fn (mut op WindowWithCountOperator) gather_next(mut _ context.Context, _ Item, _ chan Item, _ OperatorOptions) {
}

// WindowWithTime periodically subdivides items from an Observable into Observables based on timed windows
// and emit them rather than emitting the items one at a time.
pub fn (mut o ObservableImpl) window_with_time(timespan Duration, opts ...RxOption) Observable {
	if isnil(timespan) {
		return thrown(new_illegal_input_error('timespan must no be nil'))
	}

	f := fn [mut o, timespan] (mut ctx context.Context, next chan Item, option RxOption, opts ...RxOption) {
		observe := o.observe(...opts)
		mut ch := option.build_channel()
		done := chan int{cap: 1}
		mut empty := true
		mut mutex := sync.new_mutex()
		if !of(from_channel_as_item_value(ch)).send_context(mut &ctx, next) {
			return
		}

		go fn [mut ch, mut ctx, next, done, timespan, option, mut empty, mut mutex] () {
			defer {
				fn [mut mutex, ch] () {
					mutex.@lock()
					ch.close()
					mutex.unlock()
				}()
			}
			defer {
				next.close()
			}
			for select {
				_ := <-done {
					return
				}
				_ := <-done {
					return
				}
				timespan.duration().nanoseconds() {
					mutex.@lock()
					if empty {
						mutex.unlock()
						continue
					}
					ch.close()
					empty = true
					ch = option.build_channel()
					if !of(from_channel_as_item_value(ch)).send_context(mut &ctx, next) {
						done.close()
						return
					}
					mutex.unlock()
				}
			} {
			}
		}()

		for select {
			_ := <-done {
				return
			}
			_ := <-done {
				return
			}
			item := <-observe {
				if item.is_error() {
					mutex.@lock()
					if !item.send_context(mut &ctx, ch) {
						mutex.unlock()
						done.close()
						return
					}
					mutex.unlock()
					if option.get_error_strategy() == .stop_on_error {
						done.close()
						return
					}
				}
				mutex.@lock()
				if !item.send_context(mut &ctx, ch) {
					mutex.unlock()
					return
				}
				empty = false
				mutex.unlock()
			}
		} {
		}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// WindowWithTimeOrCount periodically subdivides items from an Observable into Observables based on timed windows or a specific size
// and emit them rather than emitting the items one at a time.
pub fn (mut o ObservableImpl) window_with_time_or_count(timespan Duration, count int, opts ...RxOption) Observable {
	if isnil(timespan) {
		return thrown(new_illegal_input_error('timespan must no be nil'))
	}
	if count < 0 {
		return thrown(new_illegal_input_error('count must be positive or nil'))
	}

	f := fn [mut o, timespan, count] (mut ctx context.Context, next chan Item, option RxOption, opts ...RxOption) {
		observe := o.observe(...opts)
		mut ch := option.build_channel()
		done := chan int{cap: 1}
		mut mutex := sync.new_mutex()
		mut i_count := 0
		if !of(from_channel_as_item_value(ch)).send_context(mut &ctx, next) {
			return
		}

		go fn [mut mutex, mut ch, next, mut ctx, timespan, mut i_count, option] () {
			defer {
				fn [mut mutex, ch] () {
					mutex.@lock()
					ch.close()
					mutex.unlock()
				}()
			}
			defer {
				next.close()
			}
			done := ctx.done()
			for select {
				_ := <-done {
					return
				}
				_ := <-done {
					return
				}
				timespan.duration().nanoseconds() {
					mutex.@lock()
					if i_count == 0 {
						mutex.unlock()
						continue
					}
					ch.close()
					i_count = 0
					ch = option.build_channel()
					if !of(from_channel_as_item_value(ch)).send_context(mut &ctx, next) {
						done.close()
						return
					}
					mutex.unlock()
				}
			} {
			}
		}()

		for select {
			_ := <-done {
				return
			}
			_ := <-done {
				return
			}
			item := <-observe {
				if item.is_error() {
					mutex.@lock()
					if !item.send_context(mut &ctx, ch) {
						mutex.unlock()
						done.close()
						return
					}
					mutex.unlock()
					if option.get_error_strategy() == .stop_on_error {
						done.close()
						return
					}
				}
				mutex.@lock()
				if !item.send_context(mut &ctx, ch) {
					mutex.unlock()
					return
				}
				i_count++
				if i_count == count {
					ch.close()
					i_count = 0
					ch = option.build_channel()
					if !of(from_channel_as_item_value(ch)).send_context(mut &ctx, next) {
						mutex.unlock()
						done.close()
						return
					}
				}
				mutex.unlock()
			}
		} {
		}
	}

	return custom_observable_operator(o.parent, f, ...opts)
}

// ZipFromIterable merges the emissions of an Iterable via a specified function
// and emit single items for each combination based on the results of this function.
pub fn (mut o ObservableImpl) zip_from_iterable(mut iterable Iterable, zipper Func2, opts ...RxOption) Observable {
	option := parse_options(...opts)
	next := option.build_channel()
	mut ctx := option.build_context(o.parent)

	go fn [next, mut o, mut ctx, mut iterable, option, opts, zipper] () {
		defer {
			next.close()
		}
		it1 := o.observe(...opts)
		it2 := iterable.observe(...opts)

		done := ctx.done()
		loop: for select {
			_ := <-done {
				// break loop
				break
			}
			i1 := <-it1 {
				if i1.is_error() {
					i1.send_context(mut &ctx, next)
					return
				}
				for select {
					_ := <-done {
						// break loop
						break
					}
					i2 := <-it2 {
						if i2.is_error() {
							i2.send_context(mut &ctx, next)
							return
						}
						v := zipper(mut &ctx, i1.value, i2.value) or {
							from_error(err).send_context(mut &ctx, next)
							return
						}
						of(v).send_context(mut &ctx, next)
						// continue loop
						continue
					}
				} {
				}
			}
		} {
		}
	}()

	return &ObservableImpl{
		iterable: new_channel_iterable(next)
	}
}
