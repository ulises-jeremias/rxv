# Tutorial 01 — Hello World

This tutorial shows the simplest possible RxV program.

## Install

```sh
v install rxv
```

## Code

```v
import rxv

fn main() {
	// Create an Observable that emits one string then completes
	mut obs := rxv.just[string]('Hello, RxV!')

	// Subscribe and print each item
	done := obs.for_each(fn (v string) {
		println(v)
	}, fn (e IError) {
		eprintln('error: ${e}')
	}, fn () {
		println('stream complete')
	})
	_ = <-done
}
```

## Output

```
Hello, RxV!
stream complete
```

## What's happening?

1. `just[string]('Hello, RxV!')` creates an Observable that emits exactly one item.
2. `for_each` subscribes to the stream, calling the first callback for each value.
3. The third callback fires when the stream completes.
4. `_ = <-done` blocks until the completion signal arrives.

## Next

→ [Tutorial 02 — Creating Observables](02-creating-observables.md)