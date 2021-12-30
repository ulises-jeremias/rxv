module rxv

// create creates an Observable from scratch by calling the passed function observer methods programatically.
pub fn create(f []Producer, opts ...RxOption) Observable {
	return &ObservableImpl{
		iterable: new_create_iterable(f, ...opts)
	}
}

// defer does not create the Observable until the observer subscribes,
// and creates a fresh Observable for each observer.
// pub fn defer(f []Producer, opts ...RxOption) Observable {
//         return &ObservableImpl{
//                 iterable: new_defer_iterable(f, ...opts)
//         }
// }

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

// thrown creates an Observable that emits no items and terminates with an error.
pub fn thrown(err IError) Observable {
	next := chan Item{cap: 1}
	next <- from_error(err)
	next.close()
	return &ObservableImpl{
		iterable: new_channel_iterable(next)
	}
}
