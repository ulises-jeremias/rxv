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
mut avg := obs.average_f64()

observe := avg.observe()

item := <-observe

if item.value is rxv.ItemValue {
	println(item.value)
}
