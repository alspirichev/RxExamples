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
    /* It first receives information, wraps it up and sends it to subscribers.
     It can accept and send only the type specified during creation (String in this case) */
    
    let subject = PublishSubject<String>()
    
    subject.onNext("Is anyone listening?")

    let subscriptionOne = subject
        .subscribe(onNext: { string in
            print(string)
            /* func print does not print anything, because we subscribe after subject got something */
        })
    
    /* .on(.next(<Element>))  - this is the form to submit the subject element */
    subject.on(.next("1")) // print 1

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

    subject
        .subscribe({
            print("3)", $0.element ?? $0)
        })
        .disposed(by: disposeBag)
    
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
    print(label, (event.element ?? event.error ?? event) ?? "N/A")
}

example(of: "BehaviorSubject") { 
    let subject = BehaviorSubject(value: "Initial value")

    let disposeBag = DisposeBag()

    subject.on(.next("X"))

    subject
        .subscribe({
            print(label: "1)", event: $0)
        })
        .disposed(by: disposeBag)
    
    subject.onError(MyError.anError)

    subject
        .subscribe({
            print(label: "2)", event: $0)

        })
        .disposed(by: disposeBag)
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

    subject
        .subscribe({
            print(label: "1)", event: $0)
        })
        .disposed(by: disposeBag)

    subject
        .subscribe({
            print(label: "2)", event: $0)
        })
        .disposed(by: disposeBag)

    subject.onNext("4")

    subject.onError(MyError.anError)
    subject.dispose()

    subject
        .subscribe({
            print(label: "3)", event: $0)
        })
        .disposed(by: disposeBag)
}


example(of: "Variable") {

    let variable = Variable("Initial value")
    let disposeBag = DisposeBag()

    variable.value = "New initial value"

    variable.asObservable()
        .subscribe({
            print(label: "1)", event: $0)
        })
        .disposed(by: disposeBag)

    variable.value = "1"

    variable.asObservable()
        .subscribe({
            print(label: "2)", event: $0)
        })
        .disposed(by: disposeBag)

    variable.value = "2"
}
