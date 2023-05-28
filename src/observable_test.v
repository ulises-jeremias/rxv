module rxv

import context

fn test_main() {
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
	mut avgf64 := obs.average_f64()

	assert_single(mut ctx, mut avgf64, has_items(1.0))
}
