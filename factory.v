module rxv

import context
import time

// just emits each provided value then completes.
pub fn just[T](items ...T) &ObservableImpl[T] {
	mut iter := new_slice_iterable[T](items)
	ch := iter.observe()
	return &ObservableImpl[T]{
		ch:     ch
		parent: context.background()
	}
}

// from_channel wraps an existing channel as an ObservableImpl.
pub fn from_channel[T](ch chan Item[T]) &ObservableImpl[T] {
	return &ObservableImpl[T]{
		ch:     ch
		parent: context.background()
	}
}

// create builds an ObservableImpl from a producer function.
pub fn create[T](producer ProducerFn[T]) &ObservableImpl[T] {
	mut iter := new_create_iterable[T](producer)
	ch := iter.observe()
	return &ObservableImpl[T]{
		ch:     ch
		parent: context.background()
	}
}

// empty completes immediately without emitting any item.
pub fn empty[T]() &ObservableImpl[T] {
	ch := chan Item[T]{cap: 1}
	ch.close()
	return &ObservableImpl[T]{
		ch:     ch
		parent: context.background()
	}
}

// throw emits a single error then completes.
pub fn throw[T](err IError) &ObservableImpl[T] {
	ch := chan Item[T]{cap: 1}
	ch <- from_error[T](err)
	ch.close()
	return &ObservableImpl[T]{
		ch:     ch
		parent: context.background()
	}
}

// range emits integers in [start, start+count).
pub fn range(start int, count int) &ObservableImpl[int] {
	return just[int](...[]int{len: count, init: start + index})
}

// defer_ evaluates the factory lazily on each subscribe.
fn defer_producer_run[T](factory fn () &ObservableImpl[T], done chan int, ch chan Item[T]) {
	mut obs := factory()
	src := obs.observe()
	for {
		mut dv := int(0)
		ds := done.try_pop(mut dv)
		if ds == .success || ds == .closed {
			break
		}
		mut item := Item[T]{ has_value: false, err: none }
		s := src.try_pop(mut item)
		if s == .success {
			item.send_context(done, ch)
		} else if s == .closed {
			break
		} else {
			time.sleep(10 * time.microsecond)
		}
	}
}

pub fn defer_[T](factory fn () &ObservableImpl[T]) &ObservableImpl[T] {
	producer := fn [factory] (mut ctx context.Context, ch chan Item[T]) {
		done := ctx.done()
		defer_producer_run[T](factory, done, ch)
	}
	return create[T](ProducerFn[T](producer))
}
