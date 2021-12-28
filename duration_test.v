module rxv

import time

fn test_with_frequency() {
	frequency := with_duration(100 * time.millisecond)
	assert 100 * time.millisecond == frequency.duration()
}
