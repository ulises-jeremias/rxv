# RxV Documentation

Welcome to the RxV documentation — a ReactiveX implementation for the
[V programming language](https://vlang.io/).

---

## Contents

| Document | Description |
|----------|-------------|
| [API Reference](API.md) | Full type and function reference |
| [Operators](OPERATORS.md) | All operators with usage examples |
| [Concurrency Model](#concurrency-model) | Goroutines, cancellation, memory leaks |
| [Tutorial 01 — Hello World](tutorials/01-hello-world.md) | Your first Observable |
| [Tutorial 02 — Creating Observables](tutorials/02-creating-observables.md) | `just`, `from_slice`, `range`, `create`, `interval` |
| [Tutorial 03 — Filtering](tutorials/03-filtering.md) | `filter`, `take`, `first`, `last`, `distinct` |
| [Tutorial 04 — Transforming](tutorials/04-transforming.md) | `map_`, `flat_map_`, `scan_`, `reduce_` |
| [Tutorial 05 — Error Handling](tutorials/05-error-handling.md) | `throw`, `empty`, error propagation |

---

## Quick Navigation

### I want to…

**Create a stream**
→ [Factory functions](API.md#factory-functions) —
`just`, `from_slice`, `range`, `create`, `interval`, `timer`

**Filter items**
→ [Filtering operators](API.md#filtering-operators) —
`filter`, `take`, `first`, `last`, `distinct`

**Transform items**
→ [Transformation operators](API.md#transformation-operators) —
`map_`, `flat_map_`, `concat_map_`

**Aggregate**
→ [Aggregation operators](API.md#aggregation-operators) —
`reduce_`, `scan_`, `count_`

**Combine streams**
→ [Combination operators](API.md#combination-operators) —
`merge`, `concat`

**Handle errors**
→ [Tutorial 05](tutorials/05-error-handling.md)

**Understand V compiler workarounds**
→ [Known Compiler Limitations](API.md#known-compiler-limitations-v-05x)

---

## Design Notes

RxV is implemented with these design constraints:

- **No dependencies** — only the V standard library
- **Generics via channels** — `ObservableImpl[T]` uses `chan Item[T]` internally
- **Item\[T\] wrapper** — items carry either a value (`has_value = true`)
  or an error (`is_error() = true`)
- **Free functions for type-changing operators** — due to V 0.5.x compiler
  limitations, `map_`, `scan_`, `reduce_`, `flat_map_`, `concat_map_`, and
  `count_` are free functions rather than methods

---

## Concurrency Model

Understanding when and how goroutines are spawned helps write correct,
leak-free code.

### Goroutine lifecycle

Every operator that has an asynchronous source (channel, timer, interval)
spawns a **worker goroutine** that runs the `obs_*_run` function. The worker
reads from the source, optionally transforms, and pushes to the downstream
channel. The worker terminates when the source closes, or when an error is
encountered.

### Subscribing does NOT spawn a new goroutine

`for_each`, `observe`, and all other subscription methods read from the
observable's channel — they **do not** spawn new goroutines. The downstream
simply polls or receives from the channel that the upstream worker fills.

### Cancellation via context

Every `ObservableImpl[T]` carries a `context.Context` field (`parent`). This
context is passed to operators that need to time out or respond to external
cancellation signals (e.g. `debounce`, `timeout`, `interval`). When the context
is canceled, the operator's worker should terminate.

> **Note:** In the current V 0.5.x implementation, context cancellation is
> checked via polling loops (`try_pop` + `time.sleep`). There are no native
> `<-ctx.done()` selects inside workers. This means cancellation latency is
> bounded by the poll interval (~10µs for operators using `poll_sleep`).

### Memory leaks — how to avoid them

The most common source of leaks is **leaving a subscription hanging**:
creating an observable and never calling `observe()` or `for_each()`. The
source goroutine (e.g. in `interval`, `timer`, `from_channel`) will block
trying to send to a channel that nobody reads.

**Always consume or close:**

```v
mut obs := rxv.interval(100)
// BAD: goroutine leaks after 500ms
if false {
    // never subscribes
}

// GOOD: subscribe and dispose when done
mut ctx, cancel := context.with_cancel(context.background())
defer { cancel() }
ch := obs.observe()
// read some items, then cancel() kills the worker
```

### Thread safety

Each operator's worker runs independently. Channels between operators have
a configurable buffer size (default via `option.buffer_size`). When the
downstream is slow, the upstream may block or drop depending on the operator.

### Operators that spawn goroutines

| Operator | When worker spawns | When it terminates |
|----------|---------------------|-------------------|
| `interval` | On creation | Never (use `take` to limit) |
| `timer` | On creation | After emitting 0 or delay |
| `from_channel` | On `observe()` | When source channel closes |
| `debounce` | On `observe()` | On source close or cancel |
| `timeout` | On `observe()` | On source close or timeout |
| `sample` | On `observe()` | On source close |
| `throttle_first` | On `observe()` | On source close |
| `buffer_with_time` | On `observe()` | On source close |
| All synchronous operators (`just`, `from_slice`, `range`) | On `observe()` | Immediately after emit |

---

## Examples

All runnable examples live in [`examples/`](../examples/):

```sh
v run examples/hello_world/main.v
v run examples/03-filtering/main.v
v run examples/05-aggregation/main.v
```

---

## Back to project root

→ [README.md](../README.md)
