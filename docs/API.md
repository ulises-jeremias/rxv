# RxV API Reference

> **Note:** RxV targets V 0.5.x. Due to compiler limitations, methods with
> additional type parameters are exposed as free functions with a `_` suffix
> (e.g. `map_`, `scan_`, `reduce_`).

---

## Table of Contents

- [Item\[T\]](#itemt)
- [ObservableImpl\[T\]](#observableimplt)
- [Factory Functions](#factory-functions)
- [Filtering Operators](#filtering-operators)
- [Transformation Operators](#transformation-operators)
- [Aggregation Operators (free functions)](#aggregation-operators)
- [Combination Operators](#combination-operators)
- [Utility Operators](#utility-operators)
- [Mathematical Operators (f64)](#mathematical-operators)
- [Options](#options)
- [Known Compiler Limitations](#known-compiler-limitations-v-05x)

---

## Item\[T\]

The fundamental unit emitted by an Observable.

```v ignore
pub struct Item[T] {
pub:
	value     T
	has_value bool
	err       IError
}
```

| Function | Description |
|----------|-------------|
| `of[T](value T) Item[T]` | Creates a value item |
| `from_error[T](err IError) Item[T]` | Creates an error item |
| `(i Item[T]) is_error() bool` | Returns true if item carries an error |
| `(i Item[T]) get_value() T` | Returns the value (only valid when `has_value == true`) |

---

## ObservableImpl\[T\]

The core type representing a stream of `Item[T]` values.

```v ignore
pub struct ObservableImpl[T] { ... }
```

| Method | Returns | Description |
|--------|---------|-------------|
| `observe(...opts) chan Item[T]` | channel | Subscribe and receive items |
| `filter(predicate, ...opts)` | `&ObservableImpl[T]` | Keep only matching items |
| `take(n u32, ...opts)` | `&ObservableImpl[T]` | Emit at most `n` items |
| `distinct(...opts)` | `&ObservableImpl[T]` | Suppress duplicates |
| `distinct_until_changed(...opts)` | `&ObservableImpl[T]` | Suppress consecutive duplicates |
| `first(...opts)` | `&ObservableImpl[T]` | Emit only the first item |
| `last(...opts)` | `&ObservableImpl[T]` | Emit only the last item |
| `timeout(ms int, ...opts)` | `&ObservableImpl[T]` | Error if no item within `ms` |
| `for_each(next, err, done, ...opts)` | `chan int` | Subscribe with callbacks |
| `average_f64(...opts)` | `&ObservableImpl[f64]` | Average (f64 observable only) |
| `sum_f64(...opts)` | `&ObservableImpl[f64]` | Sum (f64 observable only) |

---

## Factory Functions

Functions that create new Observables.

| Function | Description |
|----------|-------------|
| `just[T](items ...T)` | Emit fixed values |
| `from_slice[T](items []T)` | Emit items from a slice |
| `from_channel[T](ch chan Item[T])` | Wrap an existing channel |
| `create[T](producer ProducerFn[T])` | Create from a producer function |
| `empty[T]()` | Complete immediately, emit nothing |
| `throw[T](err IError)` | Emit one error, then complete |
| `range(start, count int)` | Emit `count` integers from `start` |
| `repeat[T](value T, count int)` | Emit `value` exactly `count` times |
| `interval(period_ms int)` | Emit 0, 1, 2, … every `period_ms` ms (never completes) |
| `timer(delay_ms int)` | Emit `0` after `delay_ms` ms, then complete |
| `defer_[T](factory fn() &ObservableImpl[T])` | Lazily evaluate factory per subscription |

---

## Filtering Operators

| Function / Method | Description |
|-------------------|-------------|
| `.filter(predicate PredicateFn[T])` | Emit only items passing the predicate |
| `.take(n u32)` | Emit at most `n` items |
| `.first()` | Emit only the first item |
| `.last()` | Emit only the last item |
| `.distinct()` | Suppress all previously seen items |
| `.distinct_until_changed()` | Suppress consecutive duplicate items |

---

## Transformation Operators

> Due to V 0.5.x compiler limitations, operators that transform to a different
> type `U` are exposed as **free functions** rather than methods.

| Function | Description |
|----------|-------------|
| `map_[T, U](mut o, apply MapFn[T,U])` | Transform each item to a different type |
| `flat_map_[T, U](mut o, mapper fn(T) &ObservableImpl[U])` | Map then flatten inner observables |
| `concat_map_[T, U](mut o, mapper fn(T) &ObservableImpl[U])` | Like flat_map_ but sequential |

---

## Aggregation Operators

> All free functions due to V 0.5.x type constraints.

| Function | Description |
|----------|-------------|
| `scan_[T, U](mut o, seed U, accumulator fn(U, T) U)` | Emit each intermediate accumulated value |
| `reduce_[T, U](mut o, seed U, accumulator fn(U, T) U)` | Emit only the final accumulated value |
| `count_[T](mut o)` | Emit the total number of items |

---

## Combination Operators

| Function | Description |
|----------|-------------|
| `merge[T](mut o1, mut o2)` | Interleave emissions from two observables |
| `concat[T](observables []&ObservableImpl[T])` | Emit all items from each observable sequentially |

---

## Utility Operators

| Method | Description |
|--------|-------------|
| `.timeout(ms int)` | Emit error if no item received within `ms` milliseconds |
| `timer(delay_ms int)` | Emit `0` once after delay, then complete |
| `interval(period_ms int)` | Emit sequential integers forever at given period |

---

## Mathematical Operators

Only available on `ObservableImpl[f64]`.

| Method | Description |
|--------|-------------|
| `.average_f64()` | Compute the arithmetic mean of all f64 items |
| `.sum_f64()` | Compute the sum of all f64 items |

---

## Options

Pass options to any operator using `with_*` constructors:

```v ignore
obs.filter(pred, rxv.with_buffer_size(32), rxv.with_context(ctx))
```

| Option constructor | Description |
|--------------------|-------------|
| `with_buffer_size(n int)` | Set channel buffer capacity |
| `with_pool(n int)` | Set worker pool size |
| `with_context(ctx context.Context)` | Attach a cancellation context |
| `with_eager_observation()` | Subscribe immediately (eager mode) |
| `with_error_strategy(strategy)` | `stop_on_error` or `continue_on_error` |

---

## Known Compiler Limitations (V 0.5.x)

| Limitation | Workaround |
|------------|-----------|
| Methods cannot have additional type parameters | Use free functions with `_` suffix (`map_`, `scan_`, etc.) |
| `?T` optional in generic struct → codegen bug | `has_value bool` + `get_value()` pattern |
| `select` with generic channels → wrong buffer types | `try_pop`/`try_push` polling loops |
| Generic `spawn` closures can't capture `mut` variables | Channel-capture pattern |
