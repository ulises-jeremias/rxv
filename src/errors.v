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

// msg returns the error message
pub fn (e IllegalInputError) msg() string {
	return e.msg
}

// code returns the error code
pub fn (e IllegalInputError) code() int {
	return e.code
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

// msg returns the error message
pub fn (e IndexOutOfBoundError) msg() string {
	return e.msg
}

// code returns the error code
pub fn (e IndexOutOfBoundError) code() int {
	return e.code
}
