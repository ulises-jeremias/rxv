module rxv

import context

fn test_with_buffered_channel() {
	capacity := 2
	option := with_buffered_channel(capacity)
	assert !option.to_propagate()
	assert !option.is_eager_observation()
	assert !option.is_connectable()
	assert !option.is_connect_operation()
}

fn test_with_context() {
	mut ctx := context.background()
	option := with_context(mut ctx)
	assert !option.to_propagate()
	assert !option.is_eager_observation()
	assert !option.is_connectable()
	assert !option.is_connect_operation()
}

fn test_with_observation_strategy() {
	option := with_observation_strategy(.eager)
	assert !option.to_propagate()
	assert !option.is_eager_observation()
	assert !option.is_connectable()
	assert !option.is_connect_operation()
}

fn test_with_pool() {
	pool := 4
	option := with_pool(pool)
	assert !option.to_propagate()
	assert !option.is_eager_observation()
	assert !option.is_connectable()
	assert !option.is_connect_operation()
}

fn test_with_cpu_pool() {
	option := with_cpu_pool()
	assert !option.to_propagate()
	assert !option.is_eager_observation()
	assert !option.is_connectable()
	assert !option.is_connect_operation()
}

fn test_with_back_pressure_strategy() {
	option := with_back_pressure_strategy(.block)
	assert !option.to_propagate()
	assert !option.is_eager_observation()
	assert !option.is_connectable()
	assert !option.is_connect_operation()
}

fn test_with_error_strategy() {
	option := with_error_strategy(.stop_on_error)
	assert !option.to_propagate()
	assert !option.is_eager_observation()
	assert !option.is_connectable()
	assert !option.is_connect_operation()
}

fn test_with_publish_strategy() {
	option := with_publish_strategy()
	assert !option.to_propagate()
	assert !option.is_eager_observation()
	assert !option.is_connectable()
	assert !option.is_connect_operation()
}
