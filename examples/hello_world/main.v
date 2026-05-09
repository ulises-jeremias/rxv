import ulises_jeremias.rxv as rxv

fn main() {
	mut obs := rxv.just[string]('Hello, World!')
	done := obs.for_each(fn (v string) {
		println(v)
	}, fn (e IError) {
		eprintln('error: ${e}')
	}, fn () {
		println('done')
	})
	_ = <-done
}
