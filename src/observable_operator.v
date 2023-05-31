module rxv

import context
import time

// all determines whether all items emitted by an Observable meet some criteria
pub fn (mut o ObservableImpl) all(predicate Predicate, opts ...RxOption) Single {
	return single(o.parent, mut o, fn [predicate] () Operator {
		return &AllOperator{
			predicate: predicate
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
	match item.value {
		ItemValue {
			if !op.predicate(item.value) {
				of(false).send_context(mut ctx, dst)
				op.all = false
				operator_options.stop()
			}
		}
		else {}
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
	match item.value {
		ItemValue {
			match item.value {
				bool {
					if item.value == false {
						of(false).send_context(mut ctx, dst)
						op.all = false
						operator_options.stop()
					}
				}
				else {}
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
	match item.value {
		ItemValue {
			match item.value {
				int, f32, f64 {
					op.sum += f32(item.value)
					op.count++
				}
				else {
					err := new_illegal_input_error('expected type: f32, f64 or int, got ${typeof(item.value).name}')
					from_error(err).send_context(mut ctx, dst)
					operator_options.stop()
				}
			}
		}
		else {}
	}
}

fn (mut op AverageF32Operator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut ctx, item, dst, operator_options)
}

fn (mut op AverageF32Operator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		zero := f32(0)
		of(zero).send_context(mut ctx, dst)
	} else {
		avg := f32(op.sum / op.count)
		of(avg).send_context(mut ctx, dst)
	}
}

fn (mut op AverageF32Operator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	match item.value {
		ItemValue {
			value := item.value
			if value is AverageF32Operator {
				op.sum += value.sum
				op.count += value.count
			}
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
	match item.value {
		ItemValue {
			match item.value {
				int, f32, f64 {
					op.sum += f64(item.value)
					op.count++
				}
				else {
					err := new_illegal_input_error('expected type: f32, f64 or int, got ${typeof(item.value).name}')
					from_error(err).send_context(mut ctx, dst)
					operator_options.stop()
				}
			}
		}
		else {}
	}
}

fn (mut op AverageF64Operator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut ctx, item, dst, operator_options)
}

fn (mut op AverageF64Operator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		zero := 0.0
		of(zero).send_context(mut ctx, dst)
	} else {
		avg := op.sum / op.count
		of(avg).send_context(mut ctx, dst)
	}
}

fn (mut op AverageF64Operator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	match item.value {
		ItemValue {
			value := item.value
			if value is AverageF64Operator {
				op.sum += value.sum
				op.count += value.count
			}
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

struct AverageIntOperator {
mut:
	count int
	sum   int
}

fn (mut op AverageIntOperator) next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	match item.value {
		ItemValue {
			match item.value {
				int {
					op.sum += int(item.value)
					op.count++
				}
				else {
					err := new_illegal_input_error('expected type: int, got ${typeof(item.value).name}')
					from_error(err).send_context(mut ctx, dst)
					operator_options.stop()
				}
			}
		}
		else {}
	}
}

fn (mut op AverageIntOperator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut ctx, item, dst, operator_options)
}

fn (mut op AverageIntOperator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		zero := 0
		of(zero).send_context(mut ctx, dst)
	} else {
		avg := int(op.sum / op.count)
		of(avg).send_context(mut ctx, dst)
	}
}

fn (mut op AverageIntOperator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	match item.value {
		ItemValue {
			value := item.value
			if value is AverageIntOperator {
				op.sum += value.sum
				op.count += value.count
			}
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
	match item.value {
		ItemValue {
			match item.value {
				i16 {
					op.sum += i16(item.value)
					op.count++
				}
				else {
					err := new_illegal_input_error('expected type: i16, got ${typeof(item.value).name}')
					from_error(err).send_context(mut ctx, dst)
					operator_options.stop()
				}
			}
		}
		else {}
	}
}

fn (mut op AverageI16Operator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut ctx, item, dst, operator_options)
}

fn (mut op AverageI16Operator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		zero := 0
		of(zero).send_context(mut ctx, dst)
	} else {
		avg := i16(op.sum / op.count)
		of(avg).send_context(mut ctx, dst)
	}
}

fn (mut op AverageI16Operator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	match item.value {
		ItemValue {
			value := item.value
			if value is AverageI16Operator {
				op.sum += value.sum
				op.count += value.count
			}
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
	match item.value {
		ItemValue {
			match item.value {
				i64 {
					op.sum += i64(item.value)
					op.count++
				}
				else {
					err := new_illegal_input_error('expected type: i64, got ${typeof(item.value).name}')
					from_error(err).send_context(mut ctx, dst)
					operator_options.stop()
				}
			}
		}
		else {}
	}
}

fn (mut op AverageI64Operator) err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	default_error_func_operator(mut ctx, item, dst, operator_options)
}

fn (mut op AverageI64Operator) end(mut ctx context.Context, dst chan Item) {
	if op.count == 0 {
		zero := 0
		of(zero).send_context(mut ctx, dst)
	} else {
		avg := i64(op.sum / op.count)
		of(avg).send_context(mut ctx, dst)
	}
}

fn (mut op AverageI64Operator) gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	match item.value {
		ItemValue {
			value := item.value
			if value is AverageI64Operator {
				op.sum += value.sum
				op.count += value.count
			}
		}
		else {}
	}
}
