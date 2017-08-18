//
//  AlertViewExtension.swift
//  Combinestagram
//
//  Created by Alexander Spirichev on 18/08/2017.
//  Copyright © 2017 Underplot ltd. All rights reserved.
//

import RxSwift
import UIKit

extension UIViewController {

  func showAlert(title: String, description: String?) -> Observable<Void> {
    return Observable.create({ [weak self] observer in
      let alertVC = UIAlertController(title: title,
                                      message: description,
                                      preferredStyle: .alert)
      alertVC.addAction(UIAlertAction(title: "Close",
                                      style: .default,
                                      handler: { _ in
                                        observer.onCompleted()
      }))
      self?.present(alertVC, animated: true, completion: nil)
      
      return Disposables.create(with: { 
        self?.dismiss(animated: true, completion: nil)
      })
    })
  }
}
