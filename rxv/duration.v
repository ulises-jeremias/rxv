module rxv

import time

// Duration represents a duration
pub interface Duration {
	duration() time.Duration
}

struct DurationImpl {
	d time.Duration
}

fn (d &DurationImpl) duration() time.Duration {
	return d.d
}

// with_duration is a duration option
fn with_duration(d time.Duration) Duration {
	return &DurationImpl{
		d: d
	}
}
