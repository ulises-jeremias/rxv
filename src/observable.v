module rxv

import context
import time

pub type DistributionFn = fn (item Item) int

pub type DistributionStrFn = fn (item Item) string

pub type FactoryFn = fn () ItemValue

pub type IdentifierFn = fn (value ItemValue) int

pub type IterableFactoryFn = fn (mut ctx context.Context, next chan Item, option RxOption, opts ...RxOption)

pub type RetryFn = fn (err IError) bool

pub type TimeExtractorFn = fn (value ItemValue) time.Time

// Observable is the standard interface for Observables.
pub interface Observable {
	Iterable
mut:
	all(predicate Predicate, opts ...RxOption) Single
	// 	average_f32(opts ...RxOption) Single
	// 	average_f64(opts ...RxOption) Single
	// 	average_int(opts ...RxOption) Single
	// 	average_i8(opts ...RxOption) Single
	// 	average_i16(opts ...RxOption) Single
	// 	average_i32(opts ...RxOption) Single
	// 	average_i64(opts ...RxOption) Single
	// 	// back_off_retry(back_off_cfg backoff.BackOff, opts ...RxOption) Observable
	// 	buffer_with_count(count int, opts ...RxOption) Observable
	// 	buffer_with_time(timespan Duration, opts ...RxOption) Observable
	// 	buffer_with_time_or_count(timespan Duration, count int, opts ...RxOption) Observable
	// 	connect(mut ctx context.Context) (context.Context, context.CancelFn)
	// 	contains(equal Predicate, opts ...RxOption) Single
	// 	count(opts ...RxOption) Single
	// 	debounce(timespan Duration, opts ...RxOption) Observable
	// 	default_if_empty(default_value ItemValue, opts ...RxOption) Observable
	// 	distinct(apply Func, opts ...RxOption) Observable
	// 	distinct_until_changed(apply Func, opts ...RxOption) Observable
	// 	do_on_completed(completed_func CompletedFunc, opts ...RxOption) chan int
	// 	do_on_error(err_func ErrFunc, opts ...RxOption) chan int
	// 	do_on_next(next_func NextFunc, opts ...RxOption) chan int
	// 	element_at(index u32, opts ...RxOption) Single
	// 	error(opts ...RxOption) IError
	// 	errors(opts ...RxOption) []IError
	// 	filter(apply Predicate, opts ...RxOption) Observable
	// 	find(find Predicate, opts ...RxOption) OptionalSingle
	// 	first(opts ...RxOption) OptionalSingle
	// 	first_or_default(default_value ItemValue, opts ...RxOption) Single
	// 	flat_map(apply ItemToObservable, opts ...RxOption) Observable
	// 	for_each(next_func NextFunc, err_func ErrFunc, completed_func CompletedFunc, opts ...RxOption) chan int
	// 	group_by(length int, distribution DistributionFn, opts ...RxOption) Observable
	// 	group_by_dynamic(distribution DistributionStrFn, opts ...RxOption) Observable
	// 	ignore_elements(opts ...RxOption) Observable
	// 	join(joiner Func2, mut right Observable, time_extractor TimeExtractorFn, window Duration, opts ...RxOption) Observable
	// 	last(opts ...RxOption) OptionalSingle
	// 	last_or_default(default_value ItemValue, opts ...RxOption) Single
	// 	map(apply Func, opts ...RxOption) Observable
	// 	marshal(marshaller Marshaller, opts ...RxOption) Observable
	// 	max(comparator Comparator, opts ...RxOption) OptionalSingle
	// 	min(comparator Comparator, opts ...RxOption) OptionalSingle
	// 	on_error_resume_next(resume_sequence ErrorToObservable, opts ...RxOption) Observable
	// 	on_error_return(resume_func ErrorFunc, opts ...RxOption) Observable
	// 	on_error_return_item(resume ItemValue, opts ...RxOption) Observable
	// 	reduce(apply Func2, opts ...RxOption) OptionalSingle
	// 	repeat(count i64, frequency Duration, opts ...RxOption) Observable
	// 	retry(count int, should_retry RetryFn, opts ...RxOption) Observable
	// 	run(opts ...RxOption) chan int
	// 	sample(mut iterable Iterable, opts ...RxOption) Observable
	// 	scan(apply Func2, opts ...RxOption) Observable
	// 	sequence_equal(mut iterable Iterable, opts ...RxOption) Single
	// 	send(output chan Item, opts ...RxOption)
	// 	serialize(from context.Context, identifier IdentifierFn, opts ...RxOption) Observable
	// 	skip(nth u32, opts ...RxOption) Observable
	// 	skip_last(nth u32, opts ...RxOption) Observable
	// 	skip_while(apply Predicate, opts ...RxOption) Observable
	// 	start_with(mut iterable Iterable, opts ...RxOption) Observable
	// 	sum_f32(opts ...RxOption) OptionalSingle
	// 	sum_f64(opts ...RxOption) OptionalSingle
	// 	sum_i64(opts ...RxOption) OptionalSingle
	// 	take(nth u32, opts ...RxOption) Observable
	// 	take_last(nth u32, opts ...RxOption) Observable
	// 	take_until(apply Predicate, opts ...RxOption) Observable
	// 	take_while(apply Predicate, opts ...RxOption) Observable
	// 	time_interval(opts ...RxOption) Observable
	// 	timestamp(opts ...RxOption) Observable
	// 	to_map(key_selector Func, opts ...RxOption) Single
	// 	to_map_with_value_selector(key_selector Func, valueSelector Func, opts ...RxOption) Single
	// 	to_slice(initial_capacity int, opts ...RxOption) ?[]ItemValue
	// 	unmarshal(unmarshaller Unmarshaller, factory FactoryFn, opts ...RxOption) Observable
	// 	window_with_count(count int, opts ...RxOption) Observable
	// 	window_with_time(timespan Duration, opts ...RxOption) Observable
	// 	window_with_time_or_count(timespan Duration, count int, opts ...RxOption) Observable
	// 	zip_from_iterable(mut iterable Iterable, zipper Func2, opts ...RxOption) Observable
}

// ObservableImpl implements Observable.
pub struct ObservableImpl {
mut:
	iterable Iterable
	parent   context.Context = context.background()
}

// str returns a string representation of the Observable.
pub fn (o ObservableImpl) str() string {
	return 'Observable'
}

// Observe observes an Observable by returning its channel.
pub fn (mut o ObservableImpl) observe(opts ...RxOption) chan Item {
	return o.iterable.observe(...opts)
}

pub fn default_error_func_operator(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions) {
	item.send_context(mut ctx, dst)
	operator_options.stop()
}

interface Operator {
mut:
	err(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions)
	next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions)
	end(mut ctx context.Context, dst chan Item)
	gather_next(mut ctx context.Context, item Item, dst chan Item, operator_options OperatorOptions)
}

fn single(parent context.Context, mut iterable Iterable, operator_factory OperatorFactoryFn, force_seq bool, bypass_gather bool, opts ...RxOption) Single {
	mut option := parse_options(...opts)
	parallel := if _ := option.get_pool() { true } else { false }

	next := option.build_channel()
	mut ctx := option.build_context(parent)

	if option.is_eager_observation() {
		if force_seq || !parallel {
			// TODO: Uncomment this
			// run_sequential(mut ctx, next, mut &iterable, operator_factory, option, ...opts)
		} else {
			// TODO: Uncomment this
			// run_parallel(mut ctx, next, iterable.observe(...opts), operator_factory, bypass_gather, option, ...opts)
		}
		return &SingleImpl{
			iterable: new_channel_iterable(next)
		}
	}

	factory_fn := fn [mut ctx, next, mut iterable, operator_factory, bypass_gather, mut option, opts, force_seq, parallel] (propagated_options ...RxOption) chan Item {
		mut merged_options := opts.clone()
		merged_options << propagated_options
		option = parse_options(...merged_options)

		if force_seq || !parallel {
			// TODO: Uncomment this
			// run_sequential(mut ctx, next, mut &iterable, operator_factory, option, ...merged_options)
		} else {
			// TODO: Uncomment this
			// run_parallel(mut ctx, next, iterable.observe(...merged_options), operator_factory, bypass_gather, option, ...merged_options)
		}
		return next
	}

	return &SingleImpl{
		iterable: new_factory_iterable(FactoryFn(factory_fn))
	}
}

fn optional_single(parent context.Context, mut iterable Iterable, operator_factory OperatorFactoryFn, force_seq bool, bypass_gather bool, opts ...RxOption) OptionalSingle {
	mut option := parse_options(...opts)
	mut ctx := option.build_context(parent)
	parallel := if _ := option.get_pool() { true } else { false }

	if option.is_eager_observation() {
		next := option.build_channel()
		if force_seq || !parallel {
			// TODO: Uncomment this
			// run_sequential(mut ctx, next, mut &iterable, operator_factory, option, ...opts)
		} else {
			// TODO: Uncomment this
			// run_parallel(mut ctx, next, iterable.observe(...opts), operator_factory, bypass_gather, option, ...opts)
		}
		return &OptionalSingleImpl{
			iterable: new_channel_iterable(next)
		}
	}

	factory_fn := fn [parent, mut iterable, operator_factory, bypass_gather, mut option, opts, force_seq, parallel] (propagated_options ...RxOption) chan Item {
		mut merged_options := opts.clone()
		merged_options << propagated_options
		option = parse_options(...merged_options)

		next := option.build_channel()
		mut ctx := option.build_context(parent)

		if force_seq || !parallel {
			// TODO: Uncomment this
			// run_sequential(mut ctx, next, mut &iterable, operator_factory, option, ...merged_options)
		} else {
			// TODO: Uncomment this
			// run_parallel(mut ctx, next, iterable.observe(...merged_options), operator_factory, bypass_gather, option, ...merged_options)
		}
		return next
	}

	return &OptionalSingleImpl{
		iterable: new_factory_iterable(FactoryFn(factory_fn))
	}
}
