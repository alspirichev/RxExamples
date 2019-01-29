//
//  MKMapView+Rx.swift
//  Wundercast
//
//  Created by Alexander Spirichev on 24/08/2017.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit

extension MKMapView: HasDelegate {
    public typealias Delegate = MKMapViewDelegate
}

class RxMKMapViewDelegateProxy: DelegateProxy<MKMapView, MKMapViewDelegate>, DelegateProxyType, MKMapViewDelegate {
    public weak private(set) var mapView: MKMapView?
    
    public init(mapView: ParentObject) {
        self.mapView = mapView
        super.init(parentObject: mapView, delegateProxy: RxMKMapViewDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { RxMKMapViewDelegateProxy(mapView: $0) }
    }
}

extension Reactive where Base: MKMapView {
    public var delegate: DelegateProxy<MKMapView, MKMapViewDelegate> {
        return RxMKMapViewDelegateProxy.proxy(for: self.base)
    }
    
    // uses forward proxy to handle delegate functions with teturn type
    public func setDelegate(_ delegate: MKMapViewDelegate) -> Disposable {
        return RxMKMapViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
    
    var overlays: Binder<[MKOverlay]> {
        return Binder(self.base) { mapView, overlays in
            mapView.removeOverlays(mapView.overlays)
            mapView.addOverlays(overlays)
        }
    }
    
    public var regionDidChangeAnimated: ControlEvent<Bool> {
        let source = delegate
            .methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
            .map { parameters in
                return (parameters[1] as? Bool) ?? false
        }
        return ControlEvent(events: source)
    }
    
    public var location: Binder<CLLocationCoordinate2D> {
        return Binder(base) { mapView, location in
            let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
            mapView.region = MKCoordinateRegion(center: location, span: span)
        }
    }
    
    public var text: Binder<String> {
        return Binder(base) { map, text in
            print("Hello \(text)")
        }
    }
}
