import rxv

fn main() {
	// filter — keep only even numbers
	mut obs := rxv.range(1, 10)
	mut evens := obs.filter(fn (v int) bool {
		return v % 2 == 0
	})
	println('even numbers from 1..10:')
	done := evens.for_each(fn (v int) {
		print('${v} ')
	}, fn (e IError) {}, fn () {
		println('')
	})
	_ = <-done

	// take — first 3 items
	mut obs2 := rxv.range(0, 100)
	mut first3 := obs2.take(3)
	println('first 3 from range:')
	done2 := first3.for_each(fn (v int) {
		print('${v} ')
	}, fn (e IError) {}, fn () {
		println('')
	})
	_ = <-done2

	// distinct — unique values only
	mut obs3 := rxv.just[int](1, 2, 2, 3, 1, 4, 2, 3)
	mut unique := obs3.distinct()
	println('distinct:')
	done3 := unique.for_each(fn (v int) {
		print('${v} ')
	}, fn (e IError) {}, fn () {
		println('')
	})
	_ = <-done3

	// distinct_until_changed — drop consecutive duplicates
	mut obs4 := rxv.just[int](1, 1, 2, 3, 3, 2)
	mut no_consec := obs4.distinct_until_changed()
	println('distinct_until_changed:')
	done4 := no_consec.for_each(fn (v int) {
		print('${v} ')
	}, fn (e IError) {}, fn () {
		println('')
	})
	_ = <-done4

	// chain: filter + take + last
	mut r20 := rxv.range(1, 20)
	mut filtered := r20.filter(fn (v int) bool {
		return v % 3 == 0
	})
	mut taken := filtered.take(4)
	mut chain := taken.last()
	println('multiples of 3, first 4, last one:')
	done5 := chain.for_each(fn (v int) {
		println('${v}')
	}, fn (e IError) {}, fn () {})
	_ = <-done5
}
