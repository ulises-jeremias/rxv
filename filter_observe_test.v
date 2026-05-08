module rxv

import time

fn test_filter_observe_fixed() {
    mut base := just[int](1, 2, 3, 4, 5)
    mut filtered := base.filter(fn (v int) bool { return v % 2 == 0 })
    ch := filtered.observe()
    
    mut count := 0
    for i := 0; i < 50; i++ {
        mut item := Item[int]{ has_value: false, err: none }
        s := ch.try_pop(mut item)
        if s == .success && item.has_value {
            count++
        } else if s == .closed {
            break
        } else {
            time.sleep(10 * time.microsecond)
        }
    }
    println('count: ${count}')
    assert count == 2
}
