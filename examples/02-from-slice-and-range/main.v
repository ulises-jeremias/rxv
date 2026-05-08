import rxv

fn main() {
	// from_slice emits each element of a slice
	numbers := [3, 1, 4, 1, 5, 9, 2, 6]
	mut obs := rxv.from_slice[int](numbers)
	println('from_slice:')
	done := obs.for_each(fn (v int) {
		print('${v} ')
	}, fn (e IError) {}, fn () {
		println('')
	})
	_ = <-done

	// range emits a contiguous range of integers
	mut r := rxv.range(10, 5)
	println('range(10, 5):')
	done2 := r.for_each(fn (v int) {
		print('${v} ')
	}, fn (e IError) {}, fn () {
		println('')
	})
	_ = <-done2

	// repeat emits the same value multiple times
	mut rep := rxv.repeat[string]('hello', 4)
	println('repeat hello x4:')
	done3 := rep.for_each(fn (v string) {
		print('${v} ')
	}, fn (e IError) {}, fn () {
		println('')
	})
	_ = <-done3
}
