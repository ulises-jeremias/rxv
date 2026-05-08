import rxv

fn main() {
	// map_ — double each number
	mut nums := rxv.range(1, 5)
	mut doubled := rxv.map_[int, int](mut nums, fn (v int) ?int {
		return v * 2
	})
	println('doubled:')
	done := doubled.for_each(fn (v int) {
		print('${v} ')
	}, fn (e IError) {}, fn () {
		println('')
	})
	_ = <-done

	// map_ — int to string
	mut nums2 := rxv.range(1, 4)
	mut labeled := rxv.map_[int, string](mut nums2, fn (v int) ?string {
		return 'item-${v}'
	})
	println('labeled:')
	done2 := labeled.for_each(fn (v string) {
		print('${v} ')
	}, fn (e IError) {}, fn () {
		println('')
	})
	_ = <-done2

	// flat_map_ — each number becomes two numbers
	mut obs := rxv.just[int](1, 2, 3)
	mut flat := rxv.flat_map_[int, int](mut obs, fn (v int) &rxv.ObservableImpl[int] {
		return rxv.just[int](v, v * 10)
	})
	println('flat_map (each n → n, n*10):')
	done3 := flat.for_each(fn (v int) {
		print('${v} ')
	}, fn (e IError) {}, fn () {
		println('')
	})
	_ = <-done3

	// concat_map_ — sequential inner observables
	mut obs2 := rxv.just[int](1, 2, 3)
	mut cmap := rxv.concat_map_[int, string](mut obs2, fn (v int) &rxv.ObservableImpl[string] {
		return rxv.just[string]('begin-${v}', 'end-${v}')
	})
	println('concat_map:')
	done4 := cmap.for_each(fn (v string) {
		print('${v} ')
	}, fn (e IError) {}, fn () {
		println('')
	})
	_ = <-done4
}
