module rxv

import context

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
	all       bool
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

// BufferWithCount returns an Observable that emits buffers of items it collects
// from the source Observable.
// The resulting Observable emits buffers every skip items, each containing a slice of count items.
// When the source Observable completes or encounters an error,
// the resulting Observable emits the current buffer and propagates
// the notification from the source Observable
pub fn (o &ObservableImpl) buffer_with_count(count int, opts ...RxOption) Observable {
	if count <= 0 {
		return thrown(new_illegal_input_error('count must be positive'))
	}

	return observable(o.parent, o, fn() Operator {
		return &BufferWithCountOperator{
			count: count
			buffer: []ItemValue{len: count}
		}
	}, true, false, ...opts)
}

struct BufferWithCountOperator {
mut:
	count int
	i_count int
	buffer []ItemValue
}

fn (op &BufferWithCountOperator) next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	
}

fn (op &BufferWithCountOperator) err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(ctx, item, dst, operator_options)
}

fn (op &BufferWithCountOperator) end(ctx context.Context, dst chan Item) {
}

fn (op &BufferWithCountOperator) gather_next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
}

