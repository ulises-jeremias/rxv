# Tutorial 04 — Transforming

Transformation operators change the shape or type of items in a stream.

> **V 0.5.x note:** Operators that change the type (`T → U`) cannot be methods
> due to a compiler limitation. They are free functions named with a `_` suffix.

---

## `map_` — transform each item

```v ignore
mut nums := rxv.just[int](1, 2, 3)
mut doubled := rxv.map_[int, int](mut nums, fn (v int) ?int { return v * 2 })
// emits: 2, 4, 6
```

Changing the type:

```v ignore
mut nums := rxv.just[int](1, 2, 3)
mut labels := rxv.map_[int, string](mut nums, fn (v int) ?string {
	return 'item-${v}'
})
// emits: 'item-1', 'item-2', 'item-3'
```

Return `none` to skip an item:

```v ignore
mut result := rxv.map_[int, int](mut obs, fn (v int) ?int {
	if v < 0 { return none } // skip negatives
	return v * v
})
```

---

## `scan_` — running accumulation

Emits the accumulated value after each item.

```v ignore
mut obs := rxv.just[int](1, 2, 3, 4, 5)
mut running_total := rxv.scan_[int, int](mut obs, 0, fn (acc int, val int) int {
	return acc + val
})
// emits: 1, 3, 6, 10, 15
```

---

## `reduce_` — final accumulated value

Like `scan_` but emits only when the stream completes.

```v ignore
mut obs := rxv.just[int](1, 2, 3, 4, 5)
mut total := rxv.reduce_[int, int](mut obs, 0, fn (acc int, val int) int {
	return acc + val
})
// emits: 15
```

---

## `flat_map_` — map + flatten

Each item becomes an inner Observable, and all are merged into one stream.

```v ignore
mut words := rxv.just[string]('hello world', 'foo bar')
mut letters := rxv.flat_map_[string, string](mut words,
	fn (s string) &rxv.ObservableImpl[string] {
		return rxv.from_slice[string](s.split(' '))
	})
// emits: 'hello', 'world', 'foo', 'bar'
```

---

## `concat_map_` — map + flatten sequentially

Same as `flat_map_` but inner observables are subscribed one at a time.

```v ignore
mut ids := rxv.just[int](1, 2, 3)
mut result := rxv.concat_map_[int, string](mut ids,
	fn (id int) &rxv.ObservableImpl[string] {
		return rxv.just[string]('start-${id}', 'end-${id}')
	})
// emits: 'start-1', 'end-1', 'start-2', 'end-2', 'start-3', 'end-3'
```

---

## Full example

```v
import ulises_jeremias.rxv as rxv

fn main() {
	mut obs := rxv.just[int](1, 2, 3, 4, 5)
	mut total := rxv.reduce_[int, int](mut obs, 0, fn (acc int, val int) int {
		return acc + val
	})
	done := total.for_each(fn (v int) {
		println('sum = ${v}')
	}, fn (e IError) {
		eprintln('error: ${e}')
	}, fn () {})
	_ = <-done
	// prints: sum = 15
}
```

## Next

→ [Tutorial 05 — Error Handling](05-error-handling.md)