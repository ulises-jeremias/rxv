# RxV Operator Reference

Complete list of operators grouped by category, with examples.

---

## Creating Observables

### `just[T]`

Emits each argument, then completes.

```v ignore
mut obs := rxv.just[int](1, 2, 3)
```

### `from_slice[T]`

Emits each element of a slice, then completes.

```v ignore
mut obs := rxv.from_slice[string](['a', 'b', 'c'])
```

### `range`

Emits integers from `start` to `start + count - 1`.

```v ignore
mut obs := rxv.range(0, 5) // 0, 1, 2, 3, 4
```

### `repeat[T]`

Emits the same value `count` times.

```v ignore
mut obs := rxv.repeat[string]('ping', 3)
```

### `empty[T]`

Completes immediately without emitting.

```v ignore
mut obs := rxv.empty[int]()
```

### `throw[T]`

Emits an error immediately.

```v ignore
mut obs := rxv.throw[int](error('something went wrong'))
```

### `create[T]`

Creates an observable from a producer function.

```v ignore
mut obs := rxv.create[int](fn (mut ctx context.Context, ch chan rxv.Item[int]) {
	ch <- rxv.of[int](42)
})
```

### `interval`

Emits sequential integers every `period_ms` milliseconds.
Never completes on its own — use `.take()` to limit.

```v ignore
mut obs := rxv.interval(100).take(5) // 0, 1, 2, 3, 4
```

### `timer`

Emits `0` once after `delay_ms` milliseconds.

```v ignore
mut obs := rxv.timer(500) // emits 0 after 500ms
```

---

## Filtering Operators

### `.filter`

```v ignore
mut even := rxv.just[int](1, 2, 3, 4).filter(fn (v int) bool {
	return v % 2 == 0
})
// emits: 2, 4
```

### `.take`

```v ignore
mut first3 := rxv.range(0, 100).take(3)
// emits: 0, 1, 2
```

### `.first`

```v ignore
mut f := rxv.just[int](10, 20, 30).first()
// emits: 10
```

### `.last`

```v ignore
mut l := rxv.just[int](10, 20, 30).last()
// emits: 30
```

### `.skip(n)`

Suppresses the first `n` items emitted by the source.

```v ignore
mut obs := rxv.just[int](1, 2, 3, 4, 5).skip(2)
// emits: 3, 4, 5
```

### `.take_last(n)`

Emits only the last `n` items from the source.

```v ignore
mut obs := rxv.just[int](1, 2, 3, 4, 5).take_last(2)
// emits: 4, 5
```

### `.distinct`

Suppresses all items already seen.

```v ignore
mut d := rxv.just[int](1, 2, 2, 3, 1).distinct()
// emits: 1, 2, 3
```

### `.distinct_until_changed`

Suppresses consecutive duplicate items only.

```v ignore
mut d := rxv.just[int](1, 1, 2, 3, 3, 1).distinct_until_changed()
// emits: 1, 2, 3, 1
```

### `.contains(predicate)`

Returns true if any item satisfies the predicate.

```v ignore
mut obs := rxv.just[int](1, 2, 3, 4, 5).contains(fn (v int) bool { return v == 3 })
// emits: true
```

### `.is_empty()`

Returns true if the source completes without emitting any item.

```v ignore
mut obs := rxv.empty[int]().is_empty()
// emits: true
```

### `.element_at(index)`

Returns the item at the specified index or completes without value if out of bounds.

```v ignore
mut obs := rxv.just[int](10, 20, 30).element_at(1)
// emits: 20
```

### `.all(predicate)`

Returns true if all items satisfy the predicate.

```v ignore
mut obs := rxv.just[int](2, 4, 6).all(fn (v int) bool { return v % 2 == 0 })
// emits: true
```

### `.any(predicate)`

Returns true if at least one item satisfies the predicate.

```v ignore
mut obs := rxv.just[int](1, 3, 5, 6).any(fn (v int) bool { return v % 2 == 0 })
// emits: true
```

### `.find(predicate)`

Returns the first item that satisfies the predicate, or completes without value if none match.

```v ignore
mut obs := rxv.just[int](1, 3, 5, 6, 8).find(fn (v int) bool { return v % 2 == 0 })
// emits: 6
```

### `.debounce(delay_ms)`

Emits an item only after the specified delay has passed without any other item being emitted.

```v ignore
mut obs := rxv.just[string]('a', 'b', 'c').debounce(100)
// 'c' arrives after 100ms silence
```

### `.sample(period_ms)`

Emits the most recent item at the specified periodic interval.

```v ignore
mut obs := rxv.just[int](1, 2, 3).sample(50)
// emits: the last item seen at each 50ms interval
```

### `.throttle_first(delay_ms)`

Emits the first item, then ignores subsequent items until the delay expires.

```v ignore
mut obs := rxv.just[int](1, 2, 3, 4, 5).throttle_first(100)
// emits: 1, then ignores until 100ms passes, then allows next first item through
```

---

## Transformation Operators

> Methods with an extra type param are **free functions** due to V 0.5.x constraints.
> See [docs/API.md](API.md#known-compiler-limitations) for details.

### `map_[T, U]`

```v ignore
mut nums := rxv.just[int](1, 2, 3)
mut strs := rxv.map_[int, string](mut nums, fn (v int) ?string {
	return v.str()
})
// emits: '1', '2', '3'
```

### `flat_map_[T, U]`

Maps each item to an observable, then merges their emissions.

```v ignore
mut obs := rxv.just[int](1, 2, 3)
mut result := rxv.flat_map_[int, int](mut obs, fn (v int) &rxv.ObservableImpl[int] {
	return rxv.just[int](v, v * 10)
})
// emits: 1, 10, 2, 20, 3, 30 (in order, since inner obs are tiny)
```

### `concat_map_[T, U]`

Same as `flat_map_` but inner observables are subscribed sequentially.

```v ignore
mut obs := rxv.just[int](1, 2)
mut result := rxv.concat_map_[int, string](mut obs, fn (v int) &rxv.ObservableImpl[string] {
	return rxv.just[string]('item-${v}', 'extra-${v}')
})
// emits: 'item-1', 'extra-1', 'item-2', 'extra-2'
```

---

## Aggregation Operators

### `scan_[T, U]`

Emits each intermediate accumulated value.

```v ignore
mut obs := rxv.just[int](1, 2, 3, 4)
mut running_sum := rxv.scan_[int, int](mut obs, 0, fn (acc int, val int) int {
	return acc + val
})
// emits: 1, 3, 6, 10
```

### `reduce_[T, U]`

Emits only the final accumulated value.

```v ignore
mut obs := rxv.just[int](1, 2, 3, 4)
mut total := rxv.reduce_[int, int](mut obs, 0, fn (acc int, val int) int {
	return acc + val
})
// emits: 10
```

### `count_[T]`

```v ignore
mut obs := rxv.just[string]('a', 'b', 'c')
mut n := rxv.count_[string](mut obs)
// emits: 3
```

---

## Combination Operators

### `merge[T]`

Interleaves emissions from two observables.

```v ignore
mut o1 := rxv.just[int](1, 2)
mut o2 := rxv.just[int](3, 4)
mut merged := rxv.merge[int](mut o1, mut o2)
// emits: 1, 2, 3, 4 (order may vary)
```

### `concat[T]`

Emits all items from each observable in order.

```v ignore
mut obs1 := rxv.just[int](1, 2)
mut obs2 := rxv.just[int](3, 4)
mut all := rxv.concat[int]([obs1, obs2])
// emits: 1, 2, 3, 4 (strictly in order)
```

---

## Utility Operators

### `.timeout`

Emits an error if no item arrives within `timeout_ms` milliseconds.

```v ignore
mut obs := rxv.just[int](1, 2, 3).timeout(5000)
```

### `.for_each`

Subscribe with callbacks. Returns a done channel that closes on completion.

```v ignore
done := obs.for_each(
	fn (v int) { println(v) },
	fn (e IError) { eprintln('error: ${e}') },
	fn () { println('done') },
)
_ = <-done
```

---

## Mathematical Operators (f64 only)

### `.average_f64`

```v ignore
mut obs := rxv.just[f64](1.0, 2.0, 3.0)
mut avg := obs.average_f64()
// emits: 2.0
```

### `.sum_f64`

```v ignore
mut obs := rxv.just[f64](1.0, 2.0, 3.0)
mut total := obs.sum_f64()
// emits: 6.0
```
