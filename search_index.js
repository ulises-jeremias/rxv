var searchModuleIndex = ["rxv",];
var searchIndex = ["AssertPredicate","AssertApplyFn","IRxAssert","RxAssert","new_assertion","has_items","has_item","has_items_no_order","is_not_empty","is_empty","has_error","has_an_error","has_errors","has_no_error","custom_predicate","test","ItemValue","Item","is_error","send_blocking","send_context","send_non_blocking","TimestampItem","CloseChannelStrategy","of","error","send_items","Iterable","JustIterable","observe","RangeIterable","observe","SliceIterable","observe","RxOption","with_buffered_channel","with_context","with_observation_strategy","with_pool","with_cpu_pool","with_back_pressure_strategy","with_error_strategy","with_publish_strategy","serialize","Comparator","Func","FuncN","ErrorFunc","Predicate","Marshaller","Unmarshaller","Producer","Supplier","NextFunc","ErrFunc","CompletedFunc","BackpressureStrategy","OnErrorStrategy","ObservationStrategy",];
var searchModuleData = [[" ","rxv.html"],];
var searchData = [["rxv"," AssertPredicate is a custom predicate based on the items. ","rxv.html#AssertPredicate","type "],["rxv"," AssertApplyFn is a custom function to apply modifications to a RxAssert. ","rxv.html#AssertApplyFn","type "],["rxv"," RxAssert lists the Observable assertions. ","rxv.html#IRxAssert","interface "],["rxv","","rxv.html#RxAssert","struct "],["rxv","","rxv.html#new_assertion","fn "],["rxv"," has_items checks that the observable produces the corresponding items. ","rxv.html#has_items","fn "],["rxv"," has_item checks if a single or optional single has a specific item. ","rxv.html#has_item","fn "],["rxv"," has_items_no_order checks that an observable produces the corresponding items r","rxv.html#has_items_no_order","fn "],["rxv"," is_not_empty checks that the observable produces some items. ","rxv.html#is_not_empty","fn "],["rxv"," is_empty checks that the observable has not produce any item. ","rxv.html#is_empty","fn "],["rxv"," has_error checks that the observable has produce a specific error. ","rxv.html#has_error","fn "],["rxv"," has_an_error checks that the observable has produce an error. ","rxv.html#has_an_error","fn "],["rxv"," has_errors checks that the observable has produce a set of errors. ","rxv.html#has_errors","fn "],["rxv"," has_no_error checks that the observable has not raised any error. ","rxv.html#has_no_error","fn "],["rxv"," custom_predicate checks a custom predicate. ","rxv.html#custom_predicate","fn "],["rxv"," test asserts the result of an iterable against a list of assertions. ","rxv.html#test","fn "],["rxv","","rxv.html#ItemValue","type "],["rxv"," Item is a wrapper having either a value or an error. ","rxv.html#Item","struct "],["rxv"," is_error checks if an item is an error ","rxv.html#Item.is_error","fn (Item)"],["rxv"," send_blocking sends an item and blocks until it is sent ","rxv.html#Item.send_blocking","fn (Item)"],["rxv"," send_context sends an item and blocks until it is sent or a context canceled.  ","rxv.html#Item.send_context","fn (Item)"],["rxv"," send_non_blocking sends an item without blocking.  It returns a boolean to indi","rxv.html#Item.send_non_blocking","fn (Item)"],["rxv"," TimestampItem attach a timestamp to an item. ","rxv.html#TimestampItem","struct "],["rxv"," CloseChannelStrategy indicates a strategy on whether to close a channel. ","rxv.html#CloseChannelStrategy","enum "],["rxv"," of creates an item from a value ","rxv.html#of","fn "],["rxv"," error creates an item from an error ","rxv.html#error","fn "],["rxv"," send_items is an utility funtion that send a list of ItemValue and indicate  th","rxv.html#send_items","fn "],["rxv"," Iterable is the basic type that can be observed ","rxv.html#Iterable","interface "],["rxv","","rxv.html#JustIterable","type "],["rxv","","rxv.html#JustIterable.observe","fn (JustIterable)"],["rxv","","rxv.html#RangeIterable","type "],["rxv","","rxv.html#RangeIterable.observe","fn (RangeIterable)"],["rxv","","rxv.html#SliceIterable","type "],["rxv","","rxv.html#SliceIterable.observe","fn (SliceIterable)"],["rxv"," Options handles configurable options ","rxv.html#RxOption","interface "],["rxv"," with_buffered_channel allows to configure the capacity of a buffered channel. ","rxv.html#with_buffered_channel","fn "],["rxv"," with_context allows to pass a context. ","rxv.html#with_context","fn "],["rxv"," with_observation_strategy uses the eager observation mode meaning consuming the","rxv.html#with_observation_strategy","fn "],["rxv"," with_pool allows to specify an execution pool. ","rxv.html#with_pool","fn "],["rxv"," with_cpu_pool allows to specify an execution pool based on the number of logica","rxv.html#with_cpu_pool","fn "],["rxv"," with_back_pressure_strategy sets the back pressure strategy: drop or block. ","rxv.html#with_back_pressure_strategy","fn "],["rxv"," with_error_strategy defines how an observable should deal with_ error.  This st","rxv.html#with_error_strategy","fn "],["rxv"," with_publish_strategy converts an ordinary Observable into a connectable Observ","rxv.html#with_publish_strategy","fn "],["rxv"," serialize forces an Observable to make serialized calls and to be well-behaved.","rxv.html#serialize","fn "],["rxv"," Comparator defines a func that returns an int:  - 0 if two elements are equals ","rxv.html#Comparator","type "],["rxv"," ItemToObservable defines a function that computes an observable from an item.  ","rxv.html#Func","type "],["rxv"," Func2 defines a function that computes a value from two input values.  pub type","rxv.html#FuncN","type "],["rxv"," ErrorFunc defines a function that computes a value from an string. ","rxv.html#ErrorFunc","type "],["rxv"," Predicate defines a func that returns a bool from an input value. ","rxv.html#Predicate","type "],["rxv"," Marshaller defines a marshaller type (voidptr to []byte). ","rxv.html#Marshaller","type "],["rxv"," Unmarshaller defines an unmarshaller type ([]byte to interface). ","rxv.html#Unmarshaller","type "],["rxv"," Producer defines a producer implementation. ","rxv.html#Producer","type "],["rxv"," Supplier defines a function that supplies a result from nothing. ","rxv.html#Supplier","type "],["rxv"," Disposed is a notification channel indicating when an Observable is closed.  pu","rxv.html#NextFunc","type "],["rxv"," ErrFunc handles an string in a stream. ","rxv.html#ErrFunc","type "],["rxv"," CompletedFunc handles the end of a stream. ","rxv.html#CompletedFunc","type "],["rxv"," BackpressureStrategy is the backpressure strategy type. ","rxv.html#BackpressureStrategy","enum "],["rxv"," OnErrorStrategy is the Observable error strategy. ","rxv.html#OnErrorStrategy","enum "],["rxv"," ObservationStrategy defines the strategy to consume from an Observable. ","rxv.html#ObservationStrategy","enum "],];
