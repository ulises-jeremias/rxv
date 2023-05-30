module rxv

import time

// infinite represents an infinite wait time
const infinite = -1

// Duration represents a duration
pub interface Duration {
	duration() time.Duration
}

// DurationImpl is the default implementation of Duration
struct DurationImpl {
	d time.Duration
}

// duration returns the duration
fn (d &DurationImpl) duration() time.Duration {
	return d.d
}

// with_duration is a duration option
fn with_duration(d time.Duration) Duration {
	return &DurationImpl{
		d: d
	}
}
