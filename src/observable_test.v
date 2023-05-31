module rxv

import context

fn test_all() {
	mut bctx := context.background()
	mut ctx, cancel := context.with_cancel(mut bctx)

	defer {
		cancel()
	}

	ch := chan Item{cap: 5}

	ch <- of(0.0)
	ch <- of(1.0)
	ch <- of(2.0)
	ch <- of(-1.0)
	ch <- of(-2.0)

	mut obs := from_channel(ch)
	mut all := obs.all(fn (value ItemValue) bool {
		match value {
			f64 { return *value >= 0.0 }
			else { return false }
		}
	})

	assert_single(mut ctx, mut all, has_items(false, false))
}

fn test_average_f32() {
	mut bctx := context.background()
	mut ctx, cancel := context.with_cancel(mut bctx)

	defer {
		cancel()
	}

	ch := chan Item{cap: 3}

	ch <- of(f32(0.0))
	ch <- of(f32(1.0))
	ch <- of(f32(2.0))

	mut obs := from_channel(ch)
	mut avg := obs.average_f32()

	assert_single(mut ctx, mut avg, has_items(f32(1.0)))
}

fn test_average_f64() {
	mut bctx := context.background()
	mut ctx, cancel := context.with_cancel(mut bctx)

	defer {
		cancel()
	}

	ch := chan Item{cap: 3}

	ch <- of(0.0)
	ch <- of(1.0)
	ch <- of(2.0)

	mut obs := from_channel(ch)
	mut avg := obs.average_f64()

	assert_single(mut ctx, mut avg, has_items(1.0))
}

fn test_average_int() {
	mut bctx := context.background()
	mut ctx, cancel := context.with_cancel(mut bctx)

	defer {
		cancel()
	}

	ch := chan Item{cap: 3}

	ch <- of(0)
	ch <- of(1)
	ch <- of(2)

	mut obs := from_channel(ch)
	mut avg := obs.average_int()

	assert_single(mut ctx, mut avg, has_items(1))
}

fn test_average_i16() {
	mut bctx := context.background()
	mut ctx, cancel := context.with_cancel(mut bctx)

	defer {
		cancel()
	}

	ch := chan Item{cap: 3}

	ch <- of(i16(0))
	ch <- of(i16(1))
	ch <- of(i16(2))

	mut obs := from_channel(ch)
	mut avg := obs.average_i16()

	assert_single(mut ctx, mut avg, has_items(i16(1)))
}

fn test_average_i64() {
	mut bctx := context.background()
	mut ctx, cancel := context.with_cancel(mut bctx)

	defer {
		cancel()
	}

	ch := chan Item{cap: 3}

	ch <- of(i64(0))
	ch <- of(i64(1))
	ch <- of(i64(2))

	mut obs := from_channel(ch)
	mut avg := obs.average_i64()

	assert_single(mut ctx, mut avg, has_items(i64(1)))
}
