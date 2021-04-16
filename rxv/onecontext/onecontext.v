// module onecontext provides a mechanism to merge multiple existing contexts
module onecontext

import context
import sync
import time

// canceled is the error returned when the cancel function is called on a merged context
pub const canceled = error('canceled context')

struct OneContext {
mut:
	ctx        context.Context
	ctxs       []context.Context
	done       chan int
	err        IError
	err_mutex  sync.Mutex
	cancel_ctx context.Context
}

pub fn cancel(ctx context.Context) {
	match mut ctx {
		OneContext {
			ctx.cancel(onecontext.canceled)
		}
		else {
			context.cancel(ctx)
		}
	}
}

// merge allows to merge multiple contexts
// it returns the merged context
pub fn merge(ctx context.Context, ctxs ...context.Context) context.Context {
	cancel_ctx := context.with_cancel(context.background())
	mut octx := &OneContext{
		done: chan int{cap: 3}
		ctx: ctx
		ctxs: ctxs
		cancel_ctx: cancel_ctx
	}
	go octx.run()
	return context.Context(octx)
}

pub fn (octx OneContext) deadline() ?time.Time {
	mut min := time.Time{}

	if deadline := octx.ctx.deadline() {
		min = deadline
	}

	for ctx in octx.ctxs {
		if deadline := ctx.deadline() {
			if min.unix_time() == 0 || deadline < min {
				min = deadline
			}
		}
	}

	if min.unix_time() == 0 {
		return none
	}

	return min
}

pub fn (octx OneContext) done() chan int {
	return octx.done
}

pub fn (mut octx OneContext) err() IError {
	octx.err_mutex.@lock()
	defer {
		octx.err_mutex.unlock()
	}
	return octx.err
}

pub fn (octx OneContext) value(key string) ?voidptr {
	if value := octx.ctx.value(key) {
		return value
	}

	for ctx in octx.ctxs {
		if value := ctx.value(key) {
			return value
		}
	}

	return none
}

pub fn (mut octx OneContext) run() {
	if octx.ctxs.len == 1 {
		octx.run_two_contexts(octx.ctx, octx.ctxs[0])
		return
	}

	octx.run_multiple_contexts(octx.ctx)
	for ctx in octx.ctxs {
		octx.run_multiple_contexts(ctx)
	}
}

pub fn (octx OneContext) str() string {
	return ''
}

pub fn (mut octx OneContext) cancel(err IError) {
	context.cancel(octx.cancel_ctx)
	octx.err_mutex.@lock()
	octx.err = err
	octx.err_mutex.unlock()
	if !octx.done.closed {
		octx.done <- 0
		octx.done.close()
	}
}

pub fn (mut octx OneContext) run_two_contexts(ctx1 context.Context, ctx2 context.Context) {
	go fn (mut octx OneContext, ctx1 context.Context, ctx2 context.Context) {
		octx_cancel_done := octx.cancel_ctx.done()
		c1done := ctx1.done()
		c2done := ctx2.done()
		select {
			_ := <-octx_cancel_done {
				octx.cancel(onecontext.canceled)
			}
			_ := <-c1done {
				octx.cancel(ctx1.err())
			}
			_ := <-c2done {
				octx.cancel(ctx1.err())
			}
		}
	}(mut octx, ctx1, ctx2)
}

pub fn (mut octx OneContext) run_multiple_contexts(ctx context.Context) {
	go fn (mut octx OneContext, ctx context.Context) {
		octx_cancel_done := octx.cancel_ctx.done()
		cdone := ctx.done()
		select {
			_ := <-octx_cancel_done {
				octx.cancel(onecontext.canceled)
			}
			_ := <-cdone {
				octx.cancel(ctx.err())
			}
		}
	}(mut octx, ctx)
}
