//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import RxCocoa

/*

  There are four subject types in RxSwift:
 
   • PublishSubject: Starts empty and only emits new elements to subscribers.

   • BehaviorSubject: Starts with an initial value and replays it or the latest element to new subscribers.
   
   • ReplaySubject: Initialized with a buffer size and will maintain a buffer of elements up to that size and replay it to new subscribers.
   
   • Variable: Wraps a BehaviorSubject, preserves its current value as state, and replays only the latest/initial value to new subscribers.

*/

/* ------------------------------------------------------------------------------------------------------- */

/*
 
 You might use a publish subject when you’re modeling time-sensitive data, such as
 in an online bidding app.
 
 */

example(of: "PublishSubject") {

  /* Сначала получает информацию, оборачивает ее и отправлеяет подписчикам.
   Может принимать и отправлять только тот тип, который указан при создании (String в данном случае) */
  let subject = PublishSubject<String>()

  subject.onNext("Is anyone listening?")

  let subscriptionOne = subject
    .subscribe(onNext: { string in
      print(string)
      /* print ничего не выведет, т.к. мы подписылись послего того, как subject что-то получил */
    })

  /* .on(.next(<Element>))  - это форма для передачи элемента subject */
  subject.on(.next("1")) // выведет 1

  let subscriptionTwo = subject
    .subscribe({ event in
      print("2)", event.element ?? event)
    })

  subject.onNext("3")
  subscriptionOne.dispose()
  subject.onNext("4")

  subject.onCompleted()
  subject.onNext("5")
  subscriptionTwo.dispose()

  let disposeBag = DisposeBag()

  subject.subscribe({
    print("3)", $0.element ?? $0)
  })
  .addDisposableTo(disposeBag)

  subject.onNext("?")

}

/*

 Behavior subjects are useful when you want to pre-populate a view with the most
 recent data. For example, you could bind controls in a user profile screen to a
 behavior subject, so that the latest values can be used to pre-populate the display
 while the app fetches fresh data.

 */

enum MyError: Error {
  case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
  print(label, event.element ?? event.error ?? event)
}

example(of: "BehaviorSubject") { 
  let subject = BehaviorSubject(value: "Initial value")

  let disposeBag = DisposeBag()

  subject.on(.next("X"))

  subject
    .subscribe({
      print(label: "1)", event: $0)
    })
  .addDisposableTo(disposeBag)

  subject.onError(MyError.anError)

  subject.subscribe({
    print(label: "2)", event: $0)
  })
  .addDisposableTo(disposeBag)
}



/*
 
 Replay subjects will temporarily cache, or buffer, the latest elements it emits, up to
 a specified size of your choosing. It will then replay that buffer to new subscribers.
 
 */

example(of: "ReplaySubject") { 
  let subject = ReplaySubject<String>.create(bufferSize: 2)

  let disposeBag = DisposeBag()

  subject.onNext("1")
  subject.onNext("2")
  subject.onNext("3")

  subject.subscribe({
    print(label: "1)", event: $0)
  })
  .addDisposableTo(disposeBag)

  subject.subscribe({
    print(label: "2)", event: $0)
  })
    .addDisposableTo(disposeBag)

  subject.onNext("4")

  subject.onError(MyError.anError)
  subject.dispose()

  subject.subscribe({
    print(label: "3)", event: $0)
  })
    .addDisposableTo(disposeBag)
}


example(of: "Variable") {

  let variable = Variable("Initial value")
  let disposeBag = DisposeBag()

  variable.value = "New initial value"

  variable.asObservable()
    .subscribe({
      print(label: "1)", event: $0)
    })
  .addDisposableTo(disposeBag)

  variable.value = "1"

  variable.asObservable()
    .subscribe({
      print(label: "2)", event: $0)
    })
    .addDisposableTo(disposeBag)

  variable.value = "2"
}
