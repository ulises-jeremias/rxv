import ulises_jeremias.rxv

fn main() {
	// scan_ — running total
	mut obs := rxv.just[int](1, 2, 3, 4, 5)
	mut running := rxv.scan_[int, int](mut obs, 0, fn (acc int, val int) int {
		return acc + val
	})
	println('running sum:')
	done := running.for_each(fn (v int) {
		print('${v} ')
	}, fn (e IError) {}, fn () {
		println('')
	})
	_ = <-done

	// reduce_ — final sum only
	mut obs2 := rxv.just[int](1, 2, 3, 4, 5)
	mut total := rxv.reduce_[int, int](mut obs2, 0, fn (acc int, val int) int {
		return acc + val
	})
	println('total:')
	done2 := total.for_each(fn (v int) {
		println('${v}')
	}, fn (e IError) {}, fn () {})
	_ = <-done2

	// count_ — number of items
	mut obs3 := rxv.just[string]('a', 'b', 'c', 'd')
	mut n := rxv.count_[string](mut obs3)
	println('count:')
	done3 := n.for_each(fn (v int) {
		println('${v}')
	}, fn (e IError) {}, fn () {})
	_ = <-done3

	// average_f64 and sum_f64
	mut fobs := rxv.just[f64](1.0, 2.0, 3.0, 4.0, 5.0)
	mut avg := fobs.average_f64()
	println('average:')
	done4 := avg.for_each(fn (v f64) {
		println('${v}')
	}, fn (e IError) {}, fn () {})
	_ = <-done4

	mut fobs2 := rxv.just[f64](1.0, 2.0, 3.0, 4.0, 5.0)
	mut s := fobs2.sum_f64()
	println('sum:')
	done5 := s.for_each(fn (v f64) {
		println('${v}')
	}, fn (e IError) {}, fn () {})
	_ = <-done5
}
