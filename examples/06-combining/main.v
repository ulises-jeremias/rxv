import rxv

fn main() {
	// merge — interleave two observables
	mut o1 := rxv.just[int](1, 2, 3)
	mut o2 := rxv.just[int](10, 20, 30)
	mut merged := rxv.merge[int](mut o1, mut o2)
	println('merge (order may vary):')
	done := merged.for_each(fn (v int) {
		print('${v} ')
	}, fn (e IError) {}, fn () {
		println('')
	})
	_ = <-done

	// concat — sequential subscription
	obs1 := rxv.just[int](1, 2, 3)
	obs2 := rxv.just[int](4, 5, 6)
	obs3 := rxv.just[int](7, 8, 9)
	mut all := rxv.concat[int]([obs1, obs2, obs3])
	println('concat (strictly ordered):')
	done2 := all.for_each(fn (v int) {
		print('${v} ')
	}, fn (e IError) {}, fn () {
		println('')
	})
	_ = <-done2
}
