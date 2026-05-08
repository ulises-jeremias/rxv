# RxV Documentation

Welcome to the RxV documentation — a ReactiveX implementation for the
[V programming language](https://vlang.io/).

---

## Contents

| Document | Description |
|----------|-------------|
| [API Reference](API.md) | Full type and function reference |
| [Operators](OPERATORS.md) | All operators with usage examples |
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
