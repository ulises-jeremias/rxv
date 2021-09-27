module rxv

// thrown creates an Observable that emits no items and terminates with an error.
pub fn thrown(err IError) Observable {
	next := chan Item{cap: 1}
	next <- from_error(err)
	next.close()
	return &ObservableImpl{
		iterable: new_channel_iterable(next)
	}
}

// from_channel creates a cold observable from a channel.
pub fn from_channel(next chan Item, opts ...RxOption) Observable {
	option := parse_options(...opts)
	ctx := option.build_context(empty_context)
	return &ObservableImpl{
		parent: ctx
		iterable: new_channel_iterable(next, ...opts)
	}
}
