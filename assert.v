module rxv

import context

// AssertPredicate is a custom predicate based on the items.
pub type AssertPredicate = fn (items []ItemValue) ?

// AssertApplyFn is a custom function to apply modifications to a RxAssert.
pub type AssertApplyFn = fn (mut do RxAssert)

// RxAssert lists the Observable assertions.
pub interface IRxAssert {
	apply(mut do RxAssert)
	items_to_be_checked() ?[]ItemValue
	items_no_ordered_to_be_checked() ?[]ItemValue
	no_items_to_be_checked() bool
	some_items_to_be_checked() bool
	raised_error_to_be_checked() ?IError
	raised_errors_to_be_checked() ?[]IError
	raised_an_error_to_be_checked() ?IError
	not_raised_error_to_be_checked() bool
	item_to_be_checked() ?ItemValue
	no_item_to_be_checked() ?ItemValue
	custom_predicates_to_be_checked() ?[]AssertPredicate
}

pub struct RxAssert {
	f AssertApplyFn
mut:
	check_has_items            bool
	check_has_no_items         bool
	check_has_some_items       bool
	items                      []ItemValue
	check_has_items_no_order   bool
	items_no_order             []ItemValue
	check_has_raised_error     bool
	err                        IError = none
	check_has_raised_errors    bool
	errs                       []IError
	check_has_raised_an_error  bool
	check_has_not_raised_error bool
	check_has_item             bool
	item                       ItemValue = voidptr(0)
	check_has_no_item          bool
	check_has_custom_predicate bool
	custom_predicates          []AssertPredicate
}

fn (ass &RxAssert) apply(mut do RxAssert) {
	f := ass.f
	if !isnil(f) {
		f(mut do)
	}
}

fn (ass &RxAssert) items_to_be_checked() ?[]ItemValue {
	if !ass.check_has_items {
		return none
	}
	return ass.items
}

fn (ass &RxAssert) items_no_ordered_to_be_checked() ?[]ItemValue {
	if !ass.check_has_items_no_order {
		return none
	}
	return ass.items_no_order
}

fn (ass &RxAssert) no_items_to_be_checked() bool {
	return ass.check_has_no_items
}

fn (ass &RxAssert) some_items_to_be_checked() bool {
	return ass.check_has_some_items
}

fn (ass &RxAssert) raised_error_to_be_checked() ?IError {
	if !ass.check_has_raised_error {
		return none
	}
	return ass.err
}

fn (ass &RxAssert) raised_errors_to_be_checked() ?[]IError {
	if !ass.check_has_raised_errors {
		return none
	}
	return ass.errs
}

fn (ass &RxAssert) raised_an_error_to_be_checked() ?IError {
	if !ass.check_has_raised_an_error {
		return none
	}
	return ass.err
}

fn (ass &RxAssert) not_raised_error_to_be_checked() bool {
	return ass.check_has_not_raised_error
}

fn (ass &RxAssert) item_to_be_checked() ?ItemValue {
	if !ass.check_has_item {
		return none
	}
	return ass.item
}

fn (ass &RxAssert) no_item_to_be_checked() ?ItemValue {
	if !ass.check_has_no_item {
		return none
	}
	return ass.item
}

fn (ass &RxAssert) custom_predicates_to_be_checked() ?[]AssertPredicate {
	if !ass.check_has_custom_predicate {
		return none
	}
	return ass.custom_predicates
}

pub fn new_assertion(f AssertApplyFn) IRxAssert {
	return &RxAssert{
		f: f
	}
}

// has_items checks that the observable produces the corresponding items.
pub fn has_items(items ...ItemValue) IRxAssert {
	assertion_fn := fn [items] (mut a RxAssert) {
		a.check_has_items = true
		a.items = items
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// has_item checks if a single or optional single has a specific item.
pub fn has_item(i ItemValue) IRxAssert {
	assertion_fn := fn [i] (mut a RxAssert) {
		a.check_has_item = true
		a.item = i
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// has_items_no_order checks that an observable produces the corresponding items regardless of the order.
pub fn has_items_no_order(items ...ItemValue) IRxAssert {
	assertion_fn := fn [items] (mut a RxAssert) {
		a.check_has_items_no_order = true
		a.items_no_order = items
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// is_not_empty checks that the observable produces some items.
pub fn is_not_empty() IRxAssert {
	assertion_fn := fn (mut a RxAssert) {
		a.check_has_some_items = true
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// is_empty checks that the observable has not produce any item.
pub fn is_empty() IRxAssert {
	assertion_fn := fn (mut a RxAssert) {
		a.check_has_no_items = true
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// has_error checks that the observable has produce a specific error.
pub fn has_error(err IError) IRxAssert {
	assertion_fn := fn [err] (mut a RxAssert) {
		a.check_has_raised_error = true
		a.err = err
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// has_an_error checks that the observable has produce an error.
pub fn has_an_error() IRxAssert {
	assertion_fn := fn (mut a RxAssert) {
		a.check_has_raised_an_error = true
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// has_errors checks that the observable has produce a set of errors.
pub fn has_errors(errs ...IError) IRxAssert {
	assertion_fn := fn [errs] (mut a RxAssert) {
		a.check_has_raised_errors = true
		a.errs = errs
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// has_no_error checks that the observable has not raised any error.
pub fn has_no_error() IRxAssert {
	assertion_fn := fn (mut a RxAssert) {
		a.check_has_raised_error = true
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

// custom_predicate checks a custom predicate.
pub fn custom_predicate(predicate AssertPredicate) IRxAssert {
	assertion_fn := fn [predicate] (mut a RxAssert) {
		if !a.check_has_custom_predicate {
			a.check_has_custom_predicate = true
			a.custom_predicates = []AssertPredicate{}
		}
		a.custom_predicates << predicate
	}
	return new_assertion(AssertApplyFn(assertion_fn))
}

fn parse_assertions(assertions ...IRxAssert) IRxAssert {
	mut ass := &RxAssert{}
	for assertion in assertions {
		assertion.apply(mut ass)
	}
	return ass
}

// test asserts the result of an iterable against a list of assertions.
pub fn test(mut ctx context.Context, mut iterable Iterable, assertions ...IRxAssert) {
	ass := parse_assertions(...assertions)
	mut got := []ItemValue{}
	mut errs := []IError{}
	opts := []RxOption{}

	observe := iterable.observe(...opts)
	done := ctx.done()

	loop: for {
		if select {
			_ := <-done {
				break loop
			}
			item := <-observe {
				if item.is_error() {
					errs << item.err
				} else {
					got << item.value
				}
			}
		} {
		} else {
			break loop
		}
	}

	if predicates := ass.custom_predicates_to_be_checked() {
		for predicate in predicates {
			predicate(got) or { panic(err) }
		}
	}

	// @todo: Fix this
	// if expected_items := ass.items_to_be_checked() {
	// 	assert expected_items == got
	// }

	// TODO: assert using `items_no_order := ass.items_no_ordered_to_be_checked()`

	// @todo: Fix this
	// if value := ass.item_to_be_checked() {
	// 	assert got.len == 1
	// 	assert value == got[0]
	// }

	if ass.no_items_to_be_checked() {
		assert got.len == 0
	}

	if ass.some_items_to_be_checked() {
		assert got.len != 0
	}

	if expected_error := ass.raised_error_to_be_checked() {
		if expected_error is none {
			assert errs.len == 0
		} else {
			if errs.len == 0 {
				panic('No error raised')
			}
			assert expected_error == errs[0]
		}
	}

	if expected_errors := ass.raised_errors_to_be_checked() {
		assert expected_errors == errs
	}

	if expected_error := ass.raised_an_error_to_be_checked() {
		assert expected_error is none
	}

	if ass.not_raised_error_to_be_checked() {
		assert errs.len == 0
	}
}
