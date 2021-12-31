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
				false_value := new_item_value(false)
				of(false_value).send_context(mut &ctx, dst)
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
		ItemValueImpl<int> {
			op.sum += f32(value.val)
			op.count++
		}
		ItemValueImpl<f32> {
			op.sum += value.val
			op.count++
		}
		ItemValueImpl<f64> {
			op.sum += f32(value.val)
			op.count++
		}
		else {
			err := new_illegal_input_error('expected type: f32, f64 or int, got ${typeof(item.value).name}')
			from_error(err).send_context(mut &ctx, dst)
			operator_options.stop()
		}
	}
}

fn (mut op AverageF32Operator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut &ctx, item, dst, operator_options)
}

fn (mut op AverageF32Operator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		zero := new_item_value(f32(0))
		of(zero).send_context(mut &ctx, dst)
	} else {
		avg := new_item_value(f32(op.sum / op.count))
		of(avg).send_context(mut &ctx, dst)
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
