module rxv

import time

fn test_just_simple() {
    mut obs := just[int](1, 2, 3)
    ch := obs.observe()
    
    mut results := []int{}
    for {
        mut item := Item[int]{ has_value: false, err: none }
        s := ch.try_pop(mut item)
        if s == .success {
            if item.has_value {
                results << item.get_value()
            }
        } else if s == .closed {
            break
        } else {
            time.sleep(10 * time.microsecond)
        }
    }
    
    assert results == [1, 2, 3]
}
