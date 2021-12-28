module rxv

type FactoryFn = fn (opts ...RxOption) chan Item

struct FactoryIterable {
	factory FactoryFn
}

fn new_factory_iterable(factory FactoryFn) Iterable {
	return &FactoryIterable{
		factory: factory
	}
}

pub fn (i &FactoryIterable) observe(opts ...RxOption) chan Item {
	factory := i.factory
	return factory(...opts)
}
