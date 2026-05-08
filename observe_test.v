module rxv

import time

fn test_map_observe_debug() {
    mut base := just[int](1, 2, 3)
    mut mapped := map_[int, string](mut base, fn (v int) ?string { return v.str() })
    ch := mapped.observe()

    for i := 0; i < 5; i++ {
        mut item := Item[string]{ has_value: false, err: none }
        s := ch.try_pop(mut item)
        if s == .success {
            println('got ${item.get_value()}')
        } else if s == .closed {
            println('closed')
            break
        } else {
            println('waiting')
            time.sleep(20 * time.microsecond)
        }
    }
}
