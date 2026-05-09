import ulises_jeremias.rxv as rxv

fn main() {
	mut obs := rxv.just[f64](0.0, 1.0, 2.0)
	mut avg := obs.average_f64()
	done := avg.for_each(fn (v f64) {
		println('average: ${v}')
	}, fn (e IError) {
		eprintln('error: ${e}')
	}, fn () {})
	_ = <-done
}
