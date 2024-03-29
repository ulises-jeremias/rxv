module rxv

import context

fn predicate_all_int(value ItemValue) bool {
	return value is int
}

fn channel_value(mut ctx context.Context, items ...ItemValue) chan Item {
	next := chan Item{cap: items.len}
	go fn (mut ctx context.Context, next chan Item, items []ItemValue) {
		for item in items {
			if item is IError {
				from_error(item as IError).send_context(mut ctx, next)
			} else {
				of(item as ItemValue).send_context(mut ctx, next)
			}
		}
		next.close()
	}(mut &ctx, next, items)
	return next
}

fn observable_for_tests(mut ctx context.Context, items ...ItemValue) Observable {
	return from_channel(channel_value(mut ctx, ...items))
}

fn test_all_int_true() {
	mut bctx := context.background()
	mut ctx, cancel := context.with_cancel(mut bctx)

	defer {
		cancel()
	}

	mut obs := range(0, 3)
	mut all := obs.all(predicate_all_int, with_context(mut ctx), with_context(mut ctx))

	assert_single(mut ctx, mut all, has_item(true), has_no_error())
}

fn test_all_int_false() {
	mut bctx := context.background()
	mut ctx, cancel := context.with_cancel(mut bctx)

	defer {
		cancel()
	}

	ch := chan Item{cap: 3}

	ch <- of(0)
	ch <- of('1')
	ch <- of(2)

	// mut obs := observable_for_tests(mut ctx, 1, 'x', 3)
	mut obs := from_channel(ch)
	mut all := obs.all(predicate_all_int, with_context(mut ctx))

	assert_single(mut ctx, mut all, has_item(false), has_no_error())
}

fn test_all_int_parallel_true() {
	mut bctx := context.background()
	mut ctx, cancel := context.with_cancel(mut bctx)

	defer {
		cancel()
	}

	mut obs := range(0, 3)
	mut all := obs.all(predicate_all_int, with_context(mut ctx), with_cpu_pool())

	// assert_single(mut ctx, mut all, has_item(true), has_no_error())
}

fn test_all_int_parallel_false() {
	mut bctx := context.background()
	mut ctx, cancel := context.with_cancel(mut bctx)

	defer {
		cancel()
	}

	ch := chan Item{cap: 3}

	ch <- of(0)
	ch <- of('1')
	ch <- of(2)

	mut obs := from_channel(ch)
	mut all := obs.all(predicate_all_int, with_context(mut ctx), with_cpu_pool())

	// assert_single(mut ctx, mut all, has_item(false), has_no_error())
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
	mut avg := obs.average_f32(with_context(mut ctx))

	assert_single(mut ctx, mut avg, has_item(f32(1.0)), has_no_error())
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
	mut avg := obs.average_f64(with_context(mut ctx))

	assert_single(mut ctx, mut avg, has_item(1.0), has_no_error())
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
	mut avg := obs.average_int(with_context(mut ctx))

	assert_single(mut ctx, mut avg, has_item(1), has_no_error())
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
	mut avg := obs.average_i16(with_context(mut ctx))

	assert_single(mut ctx, mut avg, has_item(i16(1)), has_no_error())
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
	mut avg := obs.average_i64(with_context(mut ctx))

	assert_single(mut ctx, mut avg, has_item(i64(1)), has_no_error())
}
