# Tutorial 05 — Error Handling

Errors in RxV are first-class values. They travel through the stream as
`Item[T]` with `is_error() == true`.

---

## Emitting errors

Use `throw` to create an observable that emits a single error:

```v ignore
mut obs := rxv.throw[int](error('something went wrong'))
```

Or emit errors from a `create` producer:

```v ignore
mut obs := rxv.create[int](fn (ch chan rxv.Item[int]) {
	ch <- rxv.of[int](1)
	ch <- rxv.of[int](2)
	ch <- rxv.from_error[int](error('mid-stream error'))
	ch <- rxv.of[int](3) // this will never be seen by default
})
```

---

## Handling errors in `for_each`

The second callback in `for_each` receives errors:

```v
import rxv

fn main() {
	mut obs := rxv.throw[int](error('oops'))
	done := obs.for_each(fn (v int) {
		println('value: ${v}')
	}, fn (e IError) {
		eprintln('error: ${e}')
	}, fn () {
		println('done')
	})
	_ = <-done
}
```

By default, an error item stops the stream.

---

## Errors through operators

Most operators propagate errors downstream without processing them:

```v ignore
// filter passes errors through unchanged
mut obs := rxv.just[int](1, 2, 3)
	.filter(fn (v int) bool { return v > 1 })
	.take(10)
```

In `map_`, you can return an error from the mapping function:

```v ignore
mut result := rxv.map_[int, int](mut obs, fn (v int) ?int {
	if v == 0 { return error('division by zero') }
	return 100 / v
})
```

---

## Timeout as an error

`.timeout` emits an error item if no value arrives within the deadline:

```v ignore
import time

// Create an observable that is very slow
mut slow_obs := rxv.create[int](fn (ch chan rxv.Item[int]) {
	time.sleep(2 * time.second)
	ch <- rxv.of[int](42)
})

// Timeout after 500ms
mut timed := slow_obs.timeout(500)

done := timed.for_each(
	fn (v int) { println('got: ${v}') },
	fn (e IError) { eprintln('timeout! ${e}') },
	fn () { println('done') },
)
_ = <-done
// prints: timeout! timeout after 500ms
```

---

## Key principles

| Principle | Detail |
|-----------|--------|
| Errors are items | `Item[T]` with `is_error() == true` |
| Errors stop the stream | Most operators break on error by default |
| Errors propagate downstream | Operators pass errors through unchanged |
| Handle errors in `for_each` | Second callback receives all errors |
| `map_` can produce errors | Return `error(...)` from the mapping `?U` function |