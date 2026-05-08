module rxv

import time

fn test_just_with_foreach() {
    mut obs := just[int](1, 2, 3)
    
    results := chan int{cap: 10}
    done := obs.for_each(
        fn [results] (v int) { 
            println('next: ${v}')
            results <- v
        },
        fn (err IError) { println('err: ${err}') },
        fn [results] () { 
            println('completed')
            results.close() 
        },
    )
    
    _ = <-done
    
    mut collected := []int{}
    for {
        mut v := 0
        s := results.try_pop(mut v)
        if s == .success {
            collected << v
        } else if s == .closed {
            break
        } else {
            time.sleep(poll_sleep)
        }
    }
    
    println('collected: ${collected}')
    assert collected == [1, 2, 3]
}
