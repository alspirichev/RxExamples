//: Playground - noun: a place where people can play

import UIKit
import RxSwift

// MARK: - Ignoring operators -

example(of: "ignoreElements") {
    let strikes = PublishSubject<String>()
    let disposeBag = DisposeBag()

    strikes
        .ignoreElements()
        .subscribe { _ in
            print("You're out!")
        }
        .disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")

    strikes.onCompleted()
}


example(of: "elementAt") {
    let strikes = PublishSubject<String>()
    let disposeBag = DisposeBag()

    strikes
        .elementAt(2)
        .subscribe(onNext: { _ in
            print("You're out!")
        })
        .disposed(by: disposeBag)

    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
}

example(of: "filter") { 
    let bag = DisposeBag()

    Observable.of(1, 2, 3, 4, 5, 6)
        .filter { int in
            int % 2 == 0
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: bag)
}

// MARK: - Skipping operators -

example(of: "skip") {
    let disposeBag = DisposeBag()

    Observable.of("A", "B", "C", "D", "E", "F")
        .skip(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "skipWhile") {
    let disposeBag = DisposeBag()

    Observable.of(2, 2, 3, 4, 4)
        .skipWhile { integer in
          integer % 2 == 0
        }
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "skipUntil") {
    let disposeBag = DisposeBag()

    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()

    subject
        .skipUntil(trigger)
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)

    subject.onNext("A")
    subject.onNext("B")

    trigger.onNext("C")
    subject.onNext("D")
}

// MARK: - Taking operators -

example(of: "take") {
    let disposeBag = DisposeBag()

    Observable.of(1, 2, 3, 4, 5, 6)
        .take(3)
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "takeWhileWithIndex") { 
    let disposeBag = DisposeBag()

    Observable.of(2, 2, 4, 4, 6, 6)
        .enumerated()
        .takeWhile { index, value in
            value % 2 == 0 && index < 3
        }
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "takeUntil") {
    let disposeBag = DisposeBag()

    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()

    subject
        .takeUntil(trigger)
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)

    subject.onNext("1")
    subject.onNext("2")

    trigger.onNext("3")
    subject.onNext("4")
}

// MARK: - Distinct operators -

example(of: "distinctUntilChanged") {
    let disposeBag = DisposeBag()

    Observable.of("A", "A", "B", "B", "A")
        .distinctUntilChanged()
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "distinctUntilChanged(_:)") {
    let disposeBag = DisposeBag()

    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut

    Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
        .distinctUntilChanged { a, b in
          guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
            let bWords = formatter.string(from: b)?.components(separatedBy: " ")
            else { return false }
          var containsMatch = false

          for aWord in aWords {
            for bWord in bWords {
              if aWord == bWord {
                containsMatch = true
                break
              }
            }
          }
          return containsMatch
        }
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
}
