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
