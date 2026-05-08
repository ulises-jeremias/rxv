module rxv

import time

fn test_just_observe_debug() {
    mut obs := just[int](1, 2, 3)
    ch := obs.observe()
    
    mut count := 0
    mut total_wait := 0
    for i := 0; i < 50; i++ {
        mut item := Item[int]{ has_value: false, err: none }
        s := ch.try_pop(mut item)
        if s == .success {
            println('i=${i}: s=${s}, has_value=${item.has_value}, val=${item.get_value()}')
            if item.has_value {
                count++
            }
        } else if s == .closed {
            println('i=${i}: closed')
            break
        } else {
            time.sleep(10 * time.microsecond)
            total_wait += 10
        }
    }
    println('total_wait: ${total_wait}us, count: ${count}')
    assert count == 3
}
