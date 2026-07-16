<div align="center">
<h1>Reactive V (RxV)</h1>

[vlang.io](https://vlang.io) |
[Docs](docs/README.md) |
[Operators](docs/OPERATORS.md) |
[Tutorials](docs/tutorials/) |
[Contributing](CONTRIBUTING.md)

</div>
<div align="center">

[![Continuous Integration][workflowbadge]][workflowurl]
[![Deploy Documentation][deploydocsbadge]][deploydocsurl]
[![License: MIT][licensebadge]][licenseurl]

</div>

**RxV** is a ReactiveX implementation for the [V programming language](https://vlang.io/)
— fully generic, built on channels, zero dependencies.

---

## Table of Contents

- [What is ReactiveX?](#what-is-reactivex)
- [Install](#install)
- [Quick Start](#quick-start)
- [Supported Operators](#supported-operators)
- [V Compiler Notes](#v-compiler-notes)
- [Examples](#examples)
- [Tutorials](#tutorials)
- [API Reference](#api-reference)
- [Testing](#testing)
- [Contributing](#contributing)

---

## What is ReactiveX?

[ReactiveX](http://reactivex.io/) is an API for programming with Observable
streams. It provides a unified model for handling asynchronous data — whether
from user events, HTTP responses, database results, or any other source.

RxV brings this model to V using:

- **Generic Observables** — `ObservableImpl[T]` works with any type
- **Channel-based pipelines** — each operator spawns a thread and connects
  via `chan Item[T]`
- **Composable operators** — filter, map, merge, reduce, and more

---

## Install

```sh
v install ulises-jeremias.rxv
```

---

## Quick Start

```v
import ulises_jeremias.rxv

fn main() {
	// 1. Create a stream of integers
	mut obs := rxv.range(1, 6) // emits 1, 2, 3, 4, 5

	// 2. Keep only even numbers
	mut evens := obs.filter(fn (v int) bool {
		return v % 2 == 0
	})

	// 3. Double each value using map_ (free function — see V Compiler Notes)
	mut doubled := rxv.map_[int, int](mut evens, fn (v int) ?int {
		return v * 2
	})

	// 4. Subscribe and collect results
	done := doubled.for_each(fn (v int) {
		println(v)
	}, fn (e IError) {
		eprintln('error: ${e}')
	}, fn () {
		println('done')
	})
	_ = <-done
	// Output:
	// 4
	// 8
	// done
}
```

---

## A More Complete Example

```v
import ulises_jeremias.rxv

fn main() {
	// Aggregate: sum all integers from 1 to 10
	mut obs := rxv.range(1, 10)
	mut total := rxv.reduce_[int, int](mut obs, 0, fn (acc int, val int) int {
		return acc + val
	})

	done := total.for_each(fn (v int) {
		println('Sum 1..10 = ${v}')
	}, fn (e IError) {
		eprintln('error: ${e}')
	}, fn () {})
	_ = <-done
	// Output: Sum 1..10 = 55
}
```

---

## Supported Operators

### Creating

| Operator | Description |
|----------|-------------|
| `just[T](items ...T)` | Emit fixed values |
| `from_slice[T](items []T)` | Emit items from a slice |
| `from_channel[T](ch)` | Wrap an existing channel |
| `create[T](producer)` | Create from a producer function |
| `empty[T]()` | Complete immediately |
| `throw[T](err)` | Emit one error and complete |
| `range(start, count)` | Emit a range of integers |
| `repeat[T](value, count)` | Emit the same value N times |
| `interval(period_ms)` | Emit sequential integers periodically |
| `timer(delay_ms)` | Emit `0` after a delay |
| `defer_[T](factory)` | Lazily evaluate on each subscription |

### Filtering

| Operator | Description |
|----------|-------------|
| `.filter(predicate)` | Keep only matching items |
| `.take(n)` | Emit at most N items |
| `.skip(n)` | Skip the first N items |
| `.take_last(n)` | Emit only the last N items |
| `.first()` | Emit only the first item |
| `.last()` | Emit only the last item |
| `.distinct()` | Suppress all duplicates |
| `.distinct_until_changed()` | Suppress consecutive duplicates |
| `.timeout(ms)` | Error if no item within deadline |
| `.contains(pred)` | Emit true if any item satisfies predicate |
| `.is_empty()` | Emit true if source completes without items |
| `.element_at(index)` | Emit item at index or error if out of bounds |

### Timing *(free functions — see [V Compiler Notes](#v-compiler-notes))*

| Operator | Description |
|----------|-------------|
| `debounce_[T](mut o, delay_ms)` | Emit after silent window |
| `sample[T](mut o, period_ms)` | Emit most recent at intervals |
| `throttle_first_[T](mut o, delay_ms)` | Emit first, block until window resets |

### Transforming *(free functions — see [V Compiler Notes](#v-compiler-notes))*

| Operator | Description |
|----------|-------------|
| `map_[T, U](mut o, fn)` | Transform each item to type U |
| `flat_map_[T, U](mut o, fn)` | Map each item to an inner observable, merge all |
| `concat_map_[T, U](mut o, fn)` | Like flat_map_ but sequential |

### Aggregating *(free functions)*

| Operator | Description |
|----------|-------------|
| `scan_[T, U](mut o, seed, fn)` | Emit each intermediate accumulated value |
| `reduce_[T, U](mut o, seed, fn)` | Emit only the final accumulated value |
| `count_[T](mut o)` | Emit the total item count |

### Combining

| Operator | Description |
|----------|-------------|
| `merge[T](mut o1, mut o2)` | Interleave emissions from two observables |
| `concat[T](observables)` | Emit all items from each observable in sequence |

### Mathematical *(f64 only)*

| Operator | Description |
|----------|-------------|
| `.average_f64()` | Compute the arithmetic mean |
| `.sum_f64()` | Compute the sum |

### Subscribing

| Operator | Description |
|----------|-------------|
| `.observe()` | Returns the underlying `chan Item[T]` |
| `.for_each(next, err, done)` | Subscribe with callbacks |

---

## V Compiler Notes

RxV targets **V 0.5.x**. The current compiler has limitations with certain
generic patterns:

> **Methods cannot have additional type parameters.**
> `(mut o ObservableImpl[T]) map[U](fn(T) U)` is not supported.

**Workaround:** Operators that transform to a different type are exposed as
**free functions** named with a `_` suffix:

```v ignore
// Instead of obs.map[string](fn(v int) string { ... })
mut labels := rxv.map_[int, string](mut obs, fn (v int) ?string { return v.str() })

// Instead of obs.scan[int](0, accumulator)
mut running := rxv.scan_[int, int](mut obs, 0, fn (acc int, v int) int { return acc + v })
```

See the full list of compiler workarounds in
[docs/API.md](docs/API.md#known-compiler-limitations-v-05x).

---

## Examples

| Example | Description |
|---------|-------------|
| [hello_world](examples/hello_world/) | Minimal hello world |
| [02-from-slice-and-range](examples/02-from-slice-and-range/) | Creating observables |
| [03-filtering](examples/03-filtering/) | filter, take, distinct, chaining |
| [04-transforming-map](examples/04-transforming-map/) | map_, flat_map_, concat_map_ |
| [05-aggregation](examples/05-aggregation/) | scan_, reduce_, count_, average_f64, sum_f64 |
| [06-combining](examples/06-combining/) | merge, concat |
| [07-error-handling](examples/07-error-handling/) | throw, error propagation |

Run any example:

```sh
v run examples/05-aggregation/main.v
```

---

## Tutorials

Step-by-step guides in [docs/tutorials/](docs/tutorials/):

1. [Hello World](docs/tutorials/01-hello-world.md)
2. [Creating Observables](docs/tutorials/02-creating-observables.md)
3. [Filtering](docs/tutorials/03-filtering.md)
4. [Transforming](docs/tutorials/04-transforming.md)
5. [Error Handling](docs/tutorials/05-error-handling.md)

---

## API Reference

→ [docs/README.md](docs/README.md) — documentation home  
→ [docs/API.md](docs/API.md) — full type and function reference  
→ [docs/OPERATORS.md](docs/OPERATORS.md) — operator reference with examples

---

## Testing

```sh
./bin/test
```

Or run a single test file directly:

```sh
cd ~/.vmodules/ulises_jeremias && v run rxv/filter_observe_test.v
```

> **Note:** Avoid `v test rxv` — it runs all tests in parallel which can
> exhaust system resources. Use `./bin/test` which runs them sequentially.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the contribution workflow.

---

[workflowbadge]: https://github.com/ulises-jeremias/rxv/actions/workflows/ci.yml/badge.svg
[deploydocsbadge]: https://github.com/ulises-jeremias/rxv/actions/workflows/deploy-docs.yml/badge.svg
[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[workflowurl]: https://github.com/ulises-jeremias/rxv/actions/workflows/ci.yml
[deploydocsurl]: https://github.com/ulises-jeremias/rxv/actions/workflows/deploy-docs.yml
[licenseurl]: https://github.com/ulises-jeremias/rxv/blob/main/LICENSE

## 👥 Contributors

<a href="https://github.com/ulises-jeremias/rxv/contributors">
  <img src="https://contrib.rocks/image?repo=ulises-jeremias/rxv"/>
</a>

Made with [contributors-img](https://contrib.rocks).