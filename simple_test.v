module rxv

import time

fn test_simple_channel_closure() {
    // Simple test: just verify channel closure pattern works
    ch := chan int{cap: 5}
    results := chan int{cap: 5}
    
    spawn fn [ch, results] () {
        for {
            mut v := 0
            s := ch.try_pop(mut v)
            if s == .success {
                results <- v
            } else if s == .closed {
                break
            } else {
                time.sleep(10 * time.microsecond)
            }
        }
        results.close()
    }()
    
    ch <- 1
    ch <- 2
    ch <- 3
    ch.close()
    
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
    
    assert collected == [1, 2, 3]
}
