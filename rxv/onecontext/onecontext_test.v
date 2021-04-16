import context
import rxv.onecontext
import time

fn eventually(ch chan int) bool {
	timeout := context.with_timeout(context.background(), 30 * time.millisecond)
	defer {
		context.cancel(timeout)
	}

	tdone := timeout.done()
	select {
		_ := <-ch {
			return true
		}
		_ := <-tdone {
			return false
		}
	}

	return false
}

fn test_merge_nomilan() {
	foo := 'foo'
	ctx1 := context.with_cancel(context.with_value(context.background(), 'foo', &foo))
	defer {
		context.cancel(ctx1)
	}

	bar := 'bar'
	ctx2 := context.with_cancel(context.with_value(context.background(), 'bar', &bar))

	ctx := onecontext.merge(ctx1, ctx2)

	if deadline := ctx.deadline() {
		assert deadline.unix_time() == 0
	}

	val1_ptr := ctx.value('foo') or { panic('wrong value access for key `foo`') }
	assert foo == *(&string(val1_ptr))

	val2_ptr := ctx.value('bar') or { panic('wrong value access for key `bar`') }
	assert bar == *(&string(val2_ptr))

	if _ := ctx.value('baz') {
		panic('this should never happen')
	}

	assert !eventually(ctx.done())
	assert ctx.err() is none

	onecontext.cancel(ctx)
	assert eventually(ctx.done())
	assert ctx.err() is Error
}
