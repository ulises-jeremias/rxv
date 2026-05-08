module rxv

import time

fn test_debug_map() {
    mut base := just[int](1, 2, 3)
    mut obs := map_[int, string](mut base, fn (v int) ?string { return v.str() })
    ch := obs.observe()
    
    for i := 0; i < 10; i++ {
        mut item := Item[string]{ has_value: false, err: none }
        s := ch.try_pop(mut item)
        if s == .success {
            println('loop ${i}: got ${item.get_value()}')
        } else if s == .closed {
            println('loop ${i}: closed')
            break
        } else {
            println('loop ${i}: waiting')
            time.sleep(10 * time.microsecond)
        }
    }
}
