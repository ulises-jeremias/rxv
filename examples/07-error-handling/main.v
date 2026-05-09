import ulises_jeremias.rxv as rxv

fn main() {
	// throw — observable that immediately errors
	mut err_obs := rxv.throw[int](error('fatal error'))
	println('throw:')
	done := err_obs.for_each(fn (v int) {
		println('value: ${v}')
	}, fn (e IError) {
		eprintln('caught error: ${e}')
	}, fn () {
		println('done')
	})
	_ = <-done

	// map_ returning error for invalid values
	mut obs := rxv.just[int](10, 0, 5, 0, 2)
	mut result := rxv.map_[int, int](mut obs, fn (v int) ?int {
		if v == 0 {
			return none
		}
		return 100 / v
	})
	println('map_ with error on zero:')
	done2 := result.for_each(fn (v int) {
		println('100 / x = ${v}')
	}, fn (e IError) {
		eprintln('error: ${e}')
	}, fn () {
		println('done')
	})
	_ = <-done2
}
