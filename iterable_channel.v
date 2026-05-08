module rxv

import context

// ---- ChannelIterable --------------------------------------------------------
// Used internally to get a channel from a pre-existing channel.

pub struct ChannelIterable[T] {
mut:
	next chan Item[T]
}

pub fn new_channel_iterable[T](ch chan Item[T]) &ChannelIterable[T] {
	return &ChannelIterable[T]{next: ch}
}

pub fn (mut i ChannelIterable[T]) observe(opts ...RxOption) chan Item[T] {
	return i.next
}

// ---- SliceIterable ----------------------------------------------------------

pub struct SliceIterable[T] {
mut:
	items []T
}

pub fn new_slice_iterable[T](items []T) &SliceIterable[T] {
	return &SliceIterable[T]{items: items}
}

// slice_emit is a named generic helper used by spawn (anonymous generic closures are unsupported).
fn slice_emit[T](items []T, ch chan Item[T]) {
	for v in items {
		ch <- of[T](v)
	}
	ch.close()
}

pub fn (mut i SliceIterable[T]) observe(opts ...RxOption) chan Item[T] {
	mut option := parse_options(...opts)
	ch := option.build_channel_t[T]()
	spawn slice_emit[T](i.items.clone(), ch)
	return ch
}

// ---- CreateIterable ---------------------------------------------------------

pub struct CreateIterable[T] {
mut:
	producer ProducerFn[T] = unsafe { nil }
}

pub fn new_create_iterable[T](producer ProducerFn[T]) &CreateIterable[T] {
	return &CreateIterable[T]{producer: producer}
}

// create_run is a named generic helper for spawn.
fn create_run[T](producer ProducerFn[T], ch chan Item[T]) {
	mut bg := context.background()
	producer(mut bg, ch)
	if !ch.closed {
		ch.close()
	}
}

pub fn (mut i CreateIterable[T]) observe(opts ...RxOption) chan Item[T] {
	mut option := parse_options(...opts)
	ch := option.build_channel_t[T]()
	spawn create_run[T](i.producer, ch)
	return ch
}
