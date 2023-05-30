import context
import rxv

mut bctx := context.background()
mut ctx, cancel := context.with_cancel(mut bctx)

defer {
	cancel()
}

ch := chan rxv.Item{cap: 3}

ch <- rxv.of(0.0)
ch <- rxv.of(1.0)
ch <- rxv.of(2.0)

mut obs := rxv.from_channel(ch)
mut avgf64 := obs.average_f64()

rxv.assert_single(mut ctx, mut avgf64, rxv.has_items(1.0))
