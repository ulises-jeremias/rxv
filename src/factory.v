module rxv

import math

// create creates an Observable from scratch by calling the passed function observer methods programatically.
pub fn create(f []Producer, opts ...RxOption) Observable {
	return &ObservableImpl{
		iterable: new_create_iterable(f, ...opts)
	}
}

// defer_obs does not create the Observable until the observer subscribes,
// and creates a fresh Observable for each observer.
pub fn defer_obs(f []Producer, opts ...RxOption) Observable {
	return &ObservableImpl{
		iterable: new_defer_iterable(f, ...opts)
	}
}

// empty creates an Observable with no item and terminate immediately.
pub fn empty() Observable {
	next := chan Item{}
	next.close()
	return &ObservableImpl{
		iterable: new_channel_iterable(next)
	}
}

// from_channel creates a cold observable from a channel.
pub fn from_channel(next chan Item, opts ...RxOption) Observable {
	option := parse_options(...opts)
	mut ctx := option.build_context(empty_context)
	return &ObservableImpl{
		parent: ctx
		iterable: new_channel_iterable(next, ...opts)
	}
}

// from_event_source creates a hot observable from an event source.
pub fn from_event_source(next chan Item, opts ...RxOption) Observable {
	option := parse_options(...opts)
	back_pressure_strategy := option.get_back_pressure_strategy()
	mut ctx := option.build_context(empty_context)
	return &ObservableImpl{
		iterable: new_event_source_iterable(mut ctx, next, back_pressure_strategy)
	}
}

// just creates an Observable with the provided items.
pub fn just(items ...ItemValue) fn (opts ...RxOption) Observable {
	return fn [items] (opts ...RxOption) Observable {
		iterable_creator := new_just_iterable(...items)
		return &ObservableImpl{
			iterable: iterable_creator(...opts)
		}
	}
}

// just_item creates an Observable with the provided item.
pub fn just_item(item ItemValue) fn (opts ...RxOption) Observable {
	return fn [item] (opts ...RxOption) Observable {
		iterable_creator := new_just_iterable(item)
		return &ObservableImpl{
			iterable: iterable_creator(...opts)
		}
	}
}

// range creates an Observable that emits a range of sequential integers.
pub fn range(start int, count int, opts ...RxOption) Observable {
	if count < 0 {
		return thrown(new_illegal_input_error('count must be >= 0'))
	}

	if start + count - 1 > math.max_i32 {
		return thrown(new_illegal_input_error('start + count must be <= math.max_i32'))
	}

	return &ObservableImpl{
		iterable: new_range_iterable(start, count, ...opts)
	}
}

// thrown creates an Observable that emits no items and terminates with an error.
pub fn thrown(err IError) Observable {
	next := chan Item{cap: 1}
	next <- from_error(err)
	next.close()
	return &ObservableImpl{
		iterable: new_channel_iterable(next)
	}
}
