# Tutorial 03 — Filtering

Filtering operators let you control which items pass through the stream.

---

## `.filter` — predicate-based filtering

```v ignore
mut obs := rxv.just[int](1, 2, 3, 4, 5, 6)
mut evens := obs.filter(fn (v int) bool { return v % 2 == 0 })
// emits: 2, 4, 6
```

---

## `.take` — limit item count

```v ignore
mut obs := rxv.range(0, 100)
mut first5 := obs.take(5)
// emits: 0, 1, 2, 3, 4
```

---

## `.first` — only the first item

```v ignore
mut obs := rxv.just[string]('alpha', 'beta', 'gamma')
mut first := obs.first()
// emits: 'alpha'
```

---

## `.last` — only the last item

```v ignore
mut obs := rxv.just[string]('alpha', 'beta', 'gamma')
mut last := obs.last()
// emits: 'gamma'
```

---

## `.distinct` — deduplicate all

```v ignore
mut obs := rxv.just[int](1, 2, 2, 3, 1, 4, 2)
mut unique := obs.distinct()
// emits: 1, 2, 3, 4  (first occurrence of each value)
```

---

## `.distinct_until_changed` — deduplicate consecutive

```v ignore
mut obs := rxv.just[int](1, 1, 2, 3, 3, 3, 2)
mut result := obs.distinct_until_changed()
// emits: 1, 2, 3, 2  (only skips consecutive duplicates)
```

---

## Chaining filters

Operators return a new Observable, so you can chain them.
Due to a V 0.5.x limitation, each step must be assigned to its own variable:

```v
import ulises_jeremias.rxv as rxv

fn main() {
	mut obs := rxv.range(1, 20)
	mut evens := obs.filter(fn (v int) bool {
		return v % 2 == 0
	})
	mut first4 := evens.take(4)
	mut result := first4.last()
	// emits: 8   (even numbers: 2, 4, 6, 8 → last is 8)
	done := result.for_each(fn (v int) {
		println(v)
	}, fn (e IError) {
		eprintln('error: ${e}')
	}, fn () {})
	_ = <-done
}
```

## Next

→ [Tutorial 04 — Transforming](04-transforming.md)