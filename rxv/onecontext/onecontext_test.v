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
		panic('this should never happen')
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

fn test_merge_deadline_context_1() {
	ctx1 := context.with_timeout(context.background(), time.second)
	defer {
		context.cancel(ctx1)
	}
	ctx2 := context.background()
	ctx := onecontext.merge(ctx1, ctx2)

	if deadline := ctx.deadline() {
		assert deadline.unix_time() != 0
	} else {
		panic('this should never happen')
	}
}

fn test_merge_deadline_context_2() {
	ctx1 := context.background()
	ctx2 := context.with_timeout(context.background(), time.second)
	defer {
		context.cancel(ctx2)
	}
	ctx := onecontext.merge(ctx1, ctx2)

	if deadline := ctx.deadline() {
		assert deadline.unix_time() != 0
	} else {
		panic('this should never happen')
	}
}

fn test_merge_deadline_context_n() {
	ctx1 := context.background()

	mut ctxs := []context.Context{cap: 21}
	for i in 0 .. 10 {
		ctxs << context.background()
	}
	ctx_n := context.with_timeout(context.background(), time.second)
	ctxs << ctx_n

	for i in 0 .. 10 {
		ctxs << context.background()
	}

	ctx := onecontext.merge(ctx1, ...ctxs)

	assert !eventually(ctx.done())
	assert ctx.err() is none
	onecontext.cancel(ctx)
	assert eventually(ctx.done())
	assert ctx.err() is Error
}

fn test_merge_deadline_none() {
	ctx1 := context.background()
	ctx2 := context.background()

	ctx := onecontext.merge(ctx1, ctx2)

	if _ := ctx.deadline() {
		panic('this should never happen')
	}
}

fn test_merge_cancel_two() {
	ctx1 := context.background()
	ctx2 := context.background()

	ctx := onecontext.merge(ctx1, ctx2)
	onecontext.cancel(ctx)

	assert eventually(ctx.done())
	assert ctx.err() is Error
	assert ctx.err().str() == 'canceled context'
}

fn test_merge_cancel_multiple() {
	ctx1 := context.background()
	ctx2 := context.background()
	ctx3 := context.background()

	ctx := onecontext.merge(ctx1, ctx2, ctx3)
	onecontext.cancel(ctx)

	assert eventually(ctx.done())
	assert ctx.err() is Error
	assert ctx.err().str() == 'canceled context'
}
