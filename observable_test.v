module rxv

fn test_observable_from_channel() {
	ch := chan Item{}
	obs := from_channel(ch)
}
