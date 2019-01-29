/*
 * Copyright (c) 2014-2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import MapKit
import RxSwift
import RxCocoa
import CoreLocation

class ViewController: UIViewController {

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var mapButton: UIButton!
  @IBOutlet weak var geoLocationButton: UIButton!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var searchCityName: UITextField!
  @IBOutlet weak var tempLabel: UILabel!
  @IBOutlet weak var humidityLabel: UILabel!
  @IBOutlet weak var iconLabel: UILabel!
  @IBOutlet weak var cityNameLabel: UILabel!
  
  let bag = DisposeBag()
  let locationManager = CLLocationManager()

  override func viewDidLoad() {
    super.viewDidLoad()

    style()

    mapButton.rx.tap
      .subscribe(onNext: {
        self.mapView.isHidden = !self.mapView.isHidden
      })
      .disposed(by: bag)

    let currentLocation = locationManager.rx.didUpdateLocations
      .map { locations in
        return locations[0]
      }
      .filter { location in
        return location.horizontalAccuracy < kCLLocationAccuracyHundredMeters
    }

    let geoInput = geoLocationButton.rx.tap.asObservable()
      .do(onNext: {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
      })
    let geoLocation = geoInput.flatMap {
      return currentLocation.take(1)
    }

    let geoSearch = geoLocation.flatMap { location in
      return APIController.shared.currentWeather(lat: location.coordinate.latitude,
                                                 lon: location.coordinate.longitude)
        .catchErrorJustReturn(APIController.Weather.dummy)
    }

    let searchInput = searchCityName.rx.controlEvent(.editingDidEndOnExit).asObservable()
      .map { self.searchCityName.text }
      .filter { ($0 ?? "").count > 0 }

    let textSearch = searchInput.flatMap { text in
      return APIController.shared.currentWeather(city: text ?? "Error")
        .catchErrorJustReturn(APIController.Weather.dummy)
    }

    let mapInput = mapView.rx.regionDidChangeAnimated
      .skip(1)
      .map { _ in self.mapView.centerCoordinate }

    let mapSearch = mapInput.flatMap { coordinate in
      return APIController.shared.currentWeather(lat: coordinate.latitude,
                                                 lon: coordinate.longitude)
        .catchErrorJustReturn(APIController.Weather.dummy)
    }

    let search = Observable.from([geoSearch, textSearch, mapSearch])
      .merge()
      .asDriver(onErrorJustReturn: APIController.Weather.dummy)

    let running = Observable.from([
      searchInput.map { _ in true },
      geoInput.map { _ in true },
      mapInput.map { _ in true},
      search.map { _ in false }.asObservable()
      ])
      .merge()
      .startWith(true)
      .asDriver(onErrorJustReturn: false)

    running
      .skip(1)
      .drive(activityIndicator.rx.isAnimating)
      .addDisposableTo(bag)

    running
      .drive(tempLabel.rx.isHidden)
      .addDisposableTo(bag)

    running
      .drive(iconLabel.rx.isHidden)
      .addDisposableTo(bag)

    running
      .drive(humidityLabel.rx.isHidden)
      .addDisposableTo(bag)

    running
      .drive(cityNameLabel.rx.isHidden)
      .addDisposableTo(bag)

    search.map { "\($0.temperature) ℃" }
      .drive(tempLabel.rx.text)
      .addDisposableTo(bag)

    search.map { "\($0.humidity)%" }
      .drive(humidityLabel.rx.text)
      .addDisposableTo(bag)

    search.map { $0.icon }
      .drive(iconLabel.rx.text)
      .addDisposableTo(bag)

    search.map { $0.cityName }
      .drive(cityNameLabel.rx.text)
      .addDisposableTo(bag)

    mapView.rx.setDelegate(self)
      .disposed(by: bag)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    Appearance.applyBottomLine(to: searchCityName)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Style

  private func style() {
    view.backgroundColor = UIColor.aztec
    searchCityName.textColor = UIColor.ufoGreen
    tempLabel.textColor = UIColor.cream
    humidityLabel.textColor = UIColor.cream
    iconLabel.textColor = UIColor.cream
    cityNameLabel.textColor = UIColor.cream
  }
}

extension ViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      if let overlay = overlay as? APIController.Weather.Overlay {
        let overlayView = APIController.Weather.OverlayView(overlay:
          overlay, overlayIcon: overlay.icon)
        return overlayView
      }
      return MKOverlayRenderer()
  }
}
