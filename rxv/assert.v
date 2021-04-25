module rxv

// AssertPredicate is a custom predicate based on the items.
pub type AssertPredicate = fn (items []ItemValue) ?

// RxAssert lists the Observable assertions.
pub interface IRxAssert {
	apply(mut do RxAssert)
	items_to_be_checked() (bool, []ItemValue)
	items_no_ordered_to_be_checked() (bool, []ItemValue)
	no_items_to_be_checked() bool
	some_items_to_be_checked() bool
	raised_error_to_be_checked() (bool, IError)
	raised_errors_to_be_checked() (bool, []IError)
	raised_an_error_to_be_checked() (bool, IError)
	not_raised_error_to_be_checked() bool
	item_to_be_checked() (bool, ItemValue)
	no_item_to_be_checked() (bool, ItemValue)
	custom_predicates_to_be_checked() (bool, []AssertPredicate)
}

pub struct RxAssert {
	f fn (mut do RxAssert)
mut:
	check_has_items            bool
	check_has_no_items         bool
	check_has_some_items       bool
	items                      []ItemValue
	check_has_items_no_order   bool
	items_no_order             []ItemValue
	check_has_raised_error     bool
	err                        IError
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
	ass.f(mut do)
}

fn (ass RxAssert) items_to_be_checked() (bool, []ItemValue) {
	return ass.check_has_items, ass.items
}

fn (ass RxAssert) items_no_ordered_to_be_checked() (bool, []ItemValue) {
	return ass.check_has_items_no_order, ass.items_no_order
}

fn (ass RxAssert) no_items_to_be_checked() bool {
	return ass.check_has_no_items
}

fn (ass RxAssert) some_items_to_be_checked() bool {
	return ass.check_has_some_items
}

fn (ass RxAssert) raised_error_to_be_checked() (bool, IError) {
	return ass.check_has_raised_error, ass.err
}

fn (ass RxAssert) raised_errors_to_be_checked() (bool, []IError) {
	return ass.check_has_raised_errors, ass.errs
}

fn (ass RxAssert) raised_an_error_to_be_checked() (bool, IError) {
	return ass.check_has_raised_an_error, ass.err
}

fn (ass RxAssert) not_raised_error_to_be_checked() bool {
	return ass.check_has_not_raised_error
}

fn (ass RxAssert) item_to_be_checked() (bool, ItemValue) {
	return ass.check_has_item, ass.item
}

fn (ass RxAssert) no_item_to_be_checked() (bool, ItemValue) {
	return ass.check_has_no_item, ass.item
}

fn (ass RxAssert) custom_predicates_to_be_checked() (bool, []AssertPredicate) {
	return ass.check_has_custom_predicate, ass.custom_predicates
}

pub fn new_assertion(f fn (mut do RxAssert)) &RxAssert {
	return &RxAssert{
		f: f
	}
}

// has_items checks that the observable produces the corresponding items.
pub fn has_items(items ...ItemValue) &RxAssert {
	return new_assertion(fn (mut a RxAssert) {
		a.check_has_items = true
		// a.items = items
	})
}

// has_item checks if a single or optional single has a specific item.
pub fn has_item(i ItemValue) &RxAssert {
	return new_assertion(fn (mut a RxAssert) {
		a.check_has_item = true
		// a.item = i
	})
}

// has_items_no_order checks that an observable produces the corresponding items regardless of the order.
pub fn has_items_no_order(items ...ItemValue) &RxAssert {
	return new_assertion(fn (mut a RxAssert) {
		a.check_has_items_no_order = true
		// a.items_no_order = items
	})
}

// is_not_empty checks that the observable produces some items.
pub fn is_not_empty() &RxAssert {
	return new_assertion(fn (mut a RxAssert) {
		a.check_has_some_items = true
	})
}

// is_empty checks that the observable has not produce any item.
pub fn is_empty() &RxAssert {
	return new_assertion(fn (mut a RxAssert) {
		a.check_has_no_items = true
	})
}

// has_error checks that the observable has produce a specific error.
pub fn has_error(err IError) &RxAssert {
	return new_assertion(fn (mut a RxAssert) {
		a.check_has_raised_error = true
		// a.err = err
	})
}

// has_an_error checks that the observable has produce an error.
pub fn has_an_error() &RxAssert {
	return new_assertion(fn (mut a RxAssert) {
		a.check_has_raised_an_error = true
	})
}

// has_errors checks that the observable has produce a set of errors.
pub fn has_errors(errs ...IError) &RxAssert {
	return new_assertion(fn (mut a RxAssert) {
		a.check_has_raised_errors = true
		// a.errs = errs
	})
}

// has_no_error checks that the observable has not raised any error.
pub fn has_no_error() &RxAssert {
	return new_assertion(fn (mut a RxAssert) {
		a.check_has_raised_error = true
	})
}

// custom_predicate checks a custom predicate.
pub fn custom_predicate(predicate AssertPredicate) &RxAssert {
	return new_assertion(fn (mut a RxAssert) {
		if !a.check_has_custom_predicate {
			a.check_has_custom_predicate = true
			a.custom_predicates = []AssertPredicate{}
		}
		// a.custom_predicates << predicate
	})
}

fn parse_assertions(assertions ...RxAssert) &RxAssert {
	mut ass := &RxAssert{}
	for assertion in assertions {
		assertion.apply(mut ass)
	}
	return ass
}
