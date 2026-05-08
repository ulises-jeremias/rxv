module rxv

import time

fn test_for_each_channel() {
    mut obs := just[int](1, 2, 3)
    
    results := chan int{cap: 10}
    done := obs.for_each(
        fn [results] (v int) {
            println('next_fn: ${v}')
            results <- v
        },
        fn (err IError) { println('err: ${err}') },
        fn [results] () {
            println('completed_fn')
            results.close()
        },
    )
    
    println('waiting for done signal')
    d := <-done
    println('got done: ${d}')
    
    mut collected := []int{}
    for {
        mut v := 0
        s := results.try_pop(mut v)
        if s == .success {
            collected << v
        } else if s == .closed {
            break
        } else {
            time.sleep(10 * time.microsecond)
        }
    }
    
    println('collected: ${collected}')
    assert collected == [1, 2, 3]
}
