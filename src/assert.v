module rxv

import context
import time

// AssertPredicate is a custom predicate based on the items.
pub type AssertPredicate = fn (items []ItemValue) ?

// AssertApplyFn is a custom function to apply modifications to a RxAssert.
pub type AssertApplyFn = fn (mut do RxAssert)

// RxAssert is a structure to apply assertions to an observable.
pub struct RxAssert {
	f AssertApplyFn = unsafe { nil }
mut:
	check_has_items            bool
	check_has_no_items         bool
	check_has_some_items       bool
	items                      []ItemValue
	check_has_items_no_order   bool
	items_no_order             []ItemValue
	check_has_raised_error     bool
	check_has_raised_errors    bool
	errs                       []IError
	check_has_raised_an_error  bool
	check_has_not_raised_error bool
	check_has_item             bool
	item                       ItemValue
	check_has_no_item          bool
	check_has_custom_predicate bool
	custom_predicates          []AssertPredicate
}

fn (ass RxAssert) apply(mut do RxAssert) {
	func := ass.f
	if !isnil(func) {
		func(mut do)
	}
}

fn (ass RxAssert) items_to_be_checked() ?[]ItemValue {
	if !ass.check_has_items {
		return none
	}
	return ass.items
}

fn (ass RxAssert) items_no_ordered_to_be_checked() ?[]ItemValue {
	if !ass.check_has_items_no_order {
		return none
	}
	return ass.items_no_order
}

fn (ass RxAssert) no_items_to_be_checked() bool {
	return ass.check_has_no_items
}

fn (ass RxAssert) some_items_to_be_checked() bool {
	return ass.check_has_some_items
}

fn (ass RxAssert) raised_error_to_be_checked() ?IError {
	if !ass.check_has_raised_error {
		return none
	}
	return ass.errs[0]
}

fn (ass RxAssert) raised_errors_to_be_checked() ?[]IError {
	if !ass.check_has_raised_errors {
		return none
	}
	return ass.errs
}

fn (ass RxAssert) raised_an_error_to_be_checked() ?IError {
	if !ass.check_has_raised_an_error {
		return none
	}
	return ass.errs[0]
}

fn (ass RxAssert) not_raised_error_to_be_checked() bool {
	return ass.check_has_not_raised_error
}

fn (ass RxAssert) item_to_be_checked() ?ItemValue {
	if !ass.check_has_item {
		return none
	}
	return ass.item
}

fn (ass RxAssert) no_item_to_be_checked() ?ItemValue {
	if !ass.check_has_no_item {
		return none
	}
	return ass.item
}

fn (ass RxAssert) custom_predicates_to_be_checked() ?[]AssertPredicate {
	if !ass.check_has_custom_predicate {
		return none
	}
	return ass.custom_predicates
}

pub fn new_assertion(f AssertApplyFn) RxAssert {
	return RxAssert{
		f: f
	}
}

// has_items checks that the observable produces the corresponding items.
pub fn has_items(items ...ItemValue) RxAssert {
	assertion_fn := fn [items] (mut a RxAssert) {
		a.check_has_items = true
		a.items = items
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// has_item checks if a single or optional single has a specific item.
pub fn has_item(i ItemValue) RxAssert {
	assertion_fn := fn [i] (mut a RxAssert) {
		a.check_has_item = true
		a.item = i
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// has_items_no_order checks that an observable produces the corresponding items regardless of the order.
pub fn has_items_no_order(items []ItemValue) RxAssert {
	assertion_fn := fn [items] (mut a RxAssert) {
		a.check_has_items_no_order = true
		a.items_no_order = items
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// is_not_empty checks that the observable produces some items.
pub fn is_not_empty() RxAssert {
	assertion_fn := fn (mut a RxAssert) {
		a.check_has_some_items = true
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// is_empty checks that the observable has not produce any item.
pub fn is_empty() RxAssert {
	assertion_fn := fn (mut a RxAssert) {
		a.check_has_no_items = true
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// has_error checks that the observable has produce a specific error.
pub fn has_error(err IError) RxAssert {
	assertion_fn := fn [err] (mut a RxAssert) {
		a.check_has_raised_error = true
		a.errs = [err]
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// has_an_error checks that the observable has produce an error.
pub fn has_an_error() RxAssert {
	assertion_fn := fn (mut a RxAssert) {
		a.check_has_raised_an_error = true
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// has_errors checks that the observable has produce a set of errors.
pub fn has_errors(errs ...IError) RxAssert {
	assertion_fn := fn [errs] (mut a RxAssert) {
		a.check_has_raised_errors = true
		a.errs = errs
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// has_no_error checks that the observable has not raised any error.
pub fn has_no_error() RxAssert {
	assertion_fn := fn (mut a RxAssert) {
		a.check_has_raised_error = true
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// custom_predicate checks a custom predicate.
pub fn custom_predicate(predicate AssertPredicate) RxAssert {
	assertion_fn := fn [predicate] (mut a RxAssert) {
		if !a.check_has_custom_predicate {
			a.check_has_custom_predicate = true
			a.custom_predicates = []AssertPredicate{}
		}
		a.custom_predicates << predicate
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

fn parse_assertions(assertions ...RxAssert) RxAssert {
	mut ass := RxAssert{}
	for assertion in assertions {
		assertion.apply(mut ass)
	}
	return ass
}
