module rxv

import context
import time

pub type DistributionFn = fn (item Item) int

pub type FactoryFn = fn () ItemValue

pub type IdentifierFn = fn (value ItemValue) int

pub type RetryFn = fn (err IError) bool

pub type TimeExtractorFn = fn (value ItemValue) time.Time

// Observable is the standard interface for Observables.
pub interface Observable {
	Iterable
	all(predicate Predicate, opts ...RxOption) Single
	average_f32(opts ...RxOption) Single
	average_f64(opts ...RxOption) Single
	average_int(opts ...RxOption) Single
	average_i8(opts ...RxOption) Single
	average_i16(opts ...RxOption) Single
	average_i32(opts ...RxOption) Single
	average_i64(opts ...RxOption) Single
	// back_off_retry(back_off_cfg backoff.BackOff, opts ...RxOption) Observable
	buffer_with_count(count int, opts ...RxOption) Observable
	buffer_with_time(timespan Duration, opts ...RxOption) Observable
	buffer_with_time_or_count(timespan Duration, count int, opts ...RxOption) Observable
	connect(ctx context.Context) (context.Context, Disposable)
	contains(equal Predicate, opts ...RxOption) Single
	count(opts ...RxOption) Single
	debounce(timespan Duration, opts ...RxOption) Observable
	default_if_empty(default_value ItemValue, opts ...RxOption) Observable
	distinct(apply Func, opts ...RxOption) Observable
	distinct_until_changed(apply Func, opts ...RxOption) Observable
	do_on_completed(completed_func CompletedFunc, opts ...RxOption) chan int
	do_on_error(err_func ErrFunc, opts ...RxOption) chan int
	do_on_next(next_func NextFunc, opts ...RxOption) chan int
	element_at(index u32, opts ...RxOption) Single
	error(opts ...RxOption) IError
	errors(opts ...RxOption) []IError
	filter(apply Predicate, opts ...RxOption) Observable
	find(find Predicate, opts ...RxOption) OptionalSingle
	first(opts ...RxOption) OptionalSingle
	first_or_default(default_value ItemValue, opts ...RxOption) Single
	flat_map(apply ItemToObservable, opts ...RxOption) Observable
	for_each(next_func NextFunc, err_func ErrFunc, completed_func CompletedFunc, opts ...RxOption) chan int
	group_by(length int, distribution DistributionFn, opts ...RxOption) Observable
	group_by_dynamic(distribution DistributionFn, opts ...RxOption) Observable
	ignore_elements(opts ...RxOption) Observable
	join(joiner Func2, right Observable, time_extractor TimeExtractorFn, window Duration, opts ...RxOption) Observable
	last(opts ...RxOption) OptionalSingle
	last_or_default(default_value ItemValue, opts ...RxOption) Single
	map(apply Func, opts ...RxOption) Observable
	marshal(marshaller Marshaller, opts ...RxOption) Observable
	max(comparator Comparator, opts ...RxOption) OptionalSingle
	min(comparator Comparator, opts ...RxOption) OptionalSingle
	on_error_resume_next(resume_sequence ErrorToObservable, opts ...RxOption) Observable
	on_error_return(resume_func ErrorFunc, opts ...RxOption) Observable
	on_error_return_item(resume ItemValue, opts ...RxOption) Observable
	reduce(apply Func2, opts ...RxOption) OptionalSingle
	repeat(count i64, frequency Duration, opts ...RxOption) Observable
	retry(count int, should_retry RetryFn, opts ...RxOption) Observable
	run(opts ...RxOption) chan int
	sample(iterable Iterable, opts ...RxOption) Observable
	scan(apply Func2, opts ...RxOption) Observable
	sequence_equal(iterable Iterable, opts ...RxOption) Single
	send(output chan Item, opts ...RxOption)
	serialize(from int, identifier IdentifierFn, opts ...RxOption) Observable
	skip(nth u32, opts ...RxOption) Observable
	skip_last(nth u32, opts ...RxOption) Observable
	skip_while(apply Predicate, opts ...RxOption) Observable
	start_with(iterable Iterable, opts ...RxOption) Observable
	sum_f32(opts ...RxOption) OptionalSingle
	sum_f64(opts ...RxOption) OptionalSingle
	sum_i64(opts ...RxOption) OptionalSingle
	take(nth u32, opts ...RxOption) Observable
	take_last(nth u32, opts ...RxOption) Observable
	take_until(apply Predicate, opts ...RxOption) Observable
	take_while(apply Predicate, opts ...RxOption) Observable
	time_interval(opts ...RxOption) Observable
	timestamp(opts ...RxOption) Observable
	to_map(key_selector Func, opts ...RxOption) Single
	to_map_with_value_selector(key_selector Func, valueSelector Func, opts ...RxOption) Single
	to_slice(initial_capacity int, opts ...RxOption) ?[]ItemValue
	unmarshal(unmarshaller Unmarshaller, factory FactoryFn, opts ...RxOption) Observable
	window_with_count(count int, opts ...RxOption) Observable
	window_with_time(timespan Duration, opts ...RxOption) Observable
	window_with_time_or_count(timespan Duration, count int, opts ...RxOption) Observable
	zip_from_iterable(iterable Iterable, zipper Func2, opts ...RxOption) Observable
}

// ObservableImpl implements Observable.
// pub struct ObservableImpl {
// 	iterable Iterable
// 	parent   context.Context
// }

fn default_error_func_operator(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	item.send_context(ctx, dst)
	operator_options.stop()
}

interface Operator {
	next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions)
	err(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions)
	end(ctx context.Context, dst chan Item)
	gather_next(ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions)
}
