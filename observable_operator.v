module rxv

import context
import time

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
		of(false).send_context(mut ctx, dst)
		op.all = false
		operator_options.stop()
	}
}

fn (mut op AllOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut ctx, item, dst, operator_options)
}

fn (mut op AllOperator) end(mut ctx context.Context, dst chan Item) {
	if op.all {
		of(true).send_context(mut ctx, dst)
	}
}

fn (mut op AllOperator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value
	match value {
		bool {
			if value == false {
				false_value := new_item_value(false)
				of(false_value).send_context(mut ctx, dst)
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
		ItemValueImpl[int] {
			op.sum += f32(value.val)
			op.count++
		}
		ItemValueImpl[f32] {
			op.sum += value.val
			op.count++
		}
		ItemValueImpl[f64] {
			op.sum += f32(value.val)
			op.count++
		}
		else {
			err := new_illegal_input_error('expected type: f32, f64 or int, got ${typeof(item.value).name}')
			from_error(err).send_context(mut ctx, dst)
			operator_options.stop()
		}
	}
}

fn (mut op AverageF32Operator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut ctx, item, dst, operator_options)
}

fn (mut op AverageF32Operator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		zero := new_item_value(f32(0))
		of(zero).send_context(mut ctx, dst)
	} else {
		avg := new_item_value(f32(op.sum / op.count))
		of(avg).send_context(mut ctx, dst)
	}
}

fn (mut op AverageF32Operator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value
	match value {
		AverageF32Operator {
			op.sum += value.sum
			op.count += value.count
		}
		else {}
	}
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
		ItemValueImpl[int] {
			op.sum += f64(value.val)
			op.count++
		}
		ItemValueImpl[f32] {
			op.sum += f64(value.val)
			op.count++
		}
		ItemValueImpl[f64] {
			op.sum += value.val
			op.count++
		}
		else {
			err := new_illegal_input_error('expected type: f32, f64 or int, got ${typeof(item.value).name}')
			from_error(err).send_context(mut ctx, dst)
			operator_options.stop()
		}
	}
}

fn (mut op AverageF64Operator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut ctx, item, dst, operator_options)
}

fn (mut op AverageF64Operator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		zero := new_item_value(0.0)
		of(zero).send_context(mut ctx, dst)
	} else {
		avg := new_item_value(op.sum / op.count)
		of(avg).send_context(mut ctx, dst)
	}
}

fn (mut op AverageF64Operator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value
	match value {
		AverageF64Operator {
			op.sum += value.sum
			op.count += value.count
		}
		else {}
	}
}

// average_int calculates the average of numbers emitted by an Observable and emits the average int
pub fn (mut o ObservableImpl) average_int(opts ...RxOption) Single {
	return single(o.parent, mut o, fn () Operator {
		return &AverageIntOperator{}
	}, false, false, ...opts)
}

// average_i32 calculates the average of numbers emitted by an Observable and emits the average int
pub fn (mut o ObservableImpl) average_i32(opts ...RxOption) Single {
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
		ItemValueImpl[int] {
			op.sum += value.val
			op.count++
		}
		else {
			err := new_illegal_input_error('expected type: int, got ${typeof(item.value).name}')
			from_error(err).send_context(mut ctx, dst)
			operator_options.stop()
		}
	}
}

fn (mut op AverageIntOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut ctx, item, dst, operator_options)
}

fn (mut op AverageIntOperator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		zero := new_item_value(0)
		of(zero).send_context(mut ctx, dst)
	} else {
		avg := new_item_value(int(op.sum / op.count))
		of(avg).send_context(mut ctx, dst)
	}
}

fn (mut op AverageIntOperator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value
	match value {
		AverageIntOperator {
			op.sum += value.sum
			op.count += value.count
		}
		else {}
	}
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
		ItemValueImpl[i16] {
			op.sum += value.val
			op.count++
		}
		else {
			err := new_illegal_input_error('expected type: i16, got ${typeof(item.value).name}')
			from_error(err).send_context(mut ctx, dst)
			operator_options.stop()
		}
	}
}

fn (mut op AverageI16Operator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut ctx, item, dst, operator_options)
}

fn (mut op AverageI16Operator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		zero := new_item_value(0)
		of(zero).send_context(mut ctx, dst)
	} else {
		avg := new_item_value(i16(op.sum / op.count))
		of(avg).send_context(mut ctx, dst)
	}
}

fn (mut op AverageI16Operator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value
	match value {
		AverageI16Operator {
			op.sum += value.sum
			op.count += value.count
		}
		else {}
	}
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
		ItemValueImpl[i64] {
			op.sum += value.val
			op.count++
		}
		else {
			err := new_illegal_input_error('expected type: i64, got ${typeof(item.value).name}')
			from_error(err).send_context(mut ctx, dst)
			operator_options.stop()
		}
	}
}

fn (mut op AverageI64Operator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut ctx, item, dst, operator_options)
}

fn (mut op AverageI64Operator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		zero := new_item_value(0)
		of(zero).send_context(mut ctx, dst)
	} else {
		avg := new_item_value(i64(op.sum / op.count))
		of(avg).send_context(mut ctx, dst)
	}
}

fn (mut op AverageI64Operator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	value := item.value
	match value {
		AverageI64Operator {
			op.sum += value.sum
			op.count += value.count
		}
		else {}
	}
}
