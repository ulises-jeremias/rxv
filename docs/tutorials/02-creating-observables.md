# Tutorial 02 — Creating Observables

RxV provides several factory functions to create Observables from different sources.

---

## `just` — fixed values

```v ignore
mut obs := rxv.just[int](1, 2, 3, 4, 5)
```

Emits each argument in order, then completes.

---

## `from_slice` — from a slice

```v ignore
data := [10, 20, 30, 40]
mut obs := rxv.from_slice[int](data)
```

Equivalent to `just` but takes a `[]T` instead of variadic arguments.

---

## `range` — integer sequence

```v ignore
mut obs := rxv.range(0, 5) // emits 0, 1, 2, 3, 4
```

---

## `repeat` — repeated value

```v ignore
mut obs := rxv.repeat[string]('ping', 3) // emits: 'ping', 'ping', 'ping'
```

---

## `empty` — no items

```v ignore
mut obs := rxv.empty[int]() // completes immediately
```

---

## `throw` — immediate error

```v ignore
mut obs := rxv.throw[int](error('oh no'))
```

---

## `create` — custom producer

For full control, use `create` with a producer function:

```v ignore
import context
import ulises_jeremias.rxv as rxv

fn main() {
	mut obs := rxv.create[int](fn (mut ctx context.Context, ch chan rxv.Item[int]) {
		ch <- rxv.of[int](0)
		ch <- rxv.of[int](1)
		ch <- rxv.of[int](4)
		// channel is closed automatically after producer returns
	})
	// emits: 0, 1, 4
	done := obs.for_each(
		fn (v int) { println(v) },
		fn (e IError) { eprintln('error: ${e}') },
		fn () { println('done') },
	)
	_ = <-done
}
```

---

## `interval` — periodic ticks

```v ignore
// Emits 0, 1, 2, ... every 100ms. Never completes on its own.
mut obs := rxv.interval(100).take(5)
// Limit to first 5 with .take()
```

---

## `timer` — single delayed emission

```v ignore
// Emits 0 after 500ms, then completes.
mut obs := rxv.timer(500)
```

---

## Consuming an observable

All observables are lazy — nothing happens until you subscribe.

```v
import ulises_jeremias.rxv as rxv

fn main() {
	mut obs := rxv.just[int](1, 2, 3)

	// Option 1: for_each (recommended)
	done := obs.for_each(fn (v int) {
		println(v)
	}, fn (e IError) {
		eprintln('error: ${e}')
	}, fn () {
		println('done')
	})
	_ = <-done
}
```

For lower-level access, use `.observe()` to get the underlying channel directly:

```v ignore
ch := obs.observe()
for {
	mut item := rxv.Item[int]{}
	s := ch.try_pop(mut item)
	if s == .success {
		if item.has_value {
			println(item.get_value())
		}
		if item.is_error() {
			eprintln(item.err)
		}
	} else if s == .closed {
		break
	}
}
```

## Next

→ [Tutorial 03 — Filtering](03-filtering.md)