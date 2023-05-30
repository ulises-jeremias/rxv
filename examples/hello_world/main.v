import rxv

mut observable := rxv.just('Hello World')()
ch := observable.observe()
item := <-ch

if item.value is rxv.ItemValue {
	println(item.value)
}
