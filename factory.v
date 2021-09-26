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
