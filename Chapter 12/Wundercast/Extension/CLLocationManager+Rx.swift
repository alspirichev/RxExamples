//
//  CLLocationManager+Rx.swift
//  Wundercast
//
//  Created by Alexander Spirichev on 24/08/2017.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import CoreLocation
import RxCocoa
import RxSwift

class RxCLLocationManagerDelegateProxy: DelegateProxy, DelegateProxyType, CLLocationManagerDelegate {

  class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
    let locationManager: CLLocationManager = object as! CLLocationManager
    locationManager.delegate = delegate as? CLLocationManagerDelegate
  }

  class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
    let locationManager: CLLocationManager = object as! CLLocationManager
    return locationManager.delegate
  }

}

extension Reactive where Base: CLLocationManager {

  var delegate: DelegateProxy {
    return RxCLLocationManagerDelegateProxy.proxyForObject(base)
  }

  var didUpdateLocations: Observable<[CLLocation]> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
      .map { parameters in
        return parameters[1] as! [CLLocation]
    }
  }
}
