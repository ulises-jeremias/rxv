module rxv

// IllegalInputError is triggered when the observable receives an illegal input
pub struct IllegalInputError {
pub:
	msg  string
	code int
}

pub fn new_illegal_input_error(msg string) IError {
	return &IllegalInputError{
		msg: msg
	}
}

// IndexOutOfBoundError is triggered when the observable cannot access to the specified index
pub struct IndexOutOfBoundError {
pub:
	msg  string
	code int
}

pub fn new_index_out_of_bound_error(msg string) IError {
	return &IndexOutOfBoundError{
		msg: msg
	}
}
