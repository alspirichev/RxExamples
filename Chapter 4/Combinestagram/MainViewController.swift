/*
 * Copyright (c) 2016 Razeware LLC
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
import RxSwift
import ReactiveSwift

class MainViewController: UIViewController {

  @IBOutlet weak var imagePreview: UIImageView!
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  @IBOutlet weak var itemAdd: UIBarButtonItem!
  
  private let bag = DisposeBag()
  private let images = Variable<[UIImage]>([])
  private var imageCache = [Int]()

  // MARK: - View Controller life cycle -
  
  override func viewDidLoad() {
    super.viewDidLoad()

    images.asObservable()
      .throttle(0.5, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] photos in
        guard let preview = self?.imagePreview else { return }
        preview.image = UIImage.collage(images: photos, size: preview.frame.size)
        self?.updateUI(photos: photos)
      })
      .disposed(by: bag)

    images.asObservable()
      .subscribe(onNext: { [unowned self] photos in
        self.imagePreview.image = UIImage.collage(images: photos, size: self.imagePreview.frame.size)
      })
      .disposed(by: bag)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    print("Resources: \(RxSwift.Resources.total)")
  }

  // MARK: - Actions and func -

  func updateUI(photos: [UIImage]) {
    buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
    buttonClear.isEnabled = photos.count > 0
    itemAdd.isEnabled = photos.count < 6
    title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
  }

  @IBAction func actionClear() {
    images.value = []
    imageCache = []
  }

  @IBAction func actionSave() {
    guard let image = imagePreview.image else { return }
    
    PhotoWriter.save(image)
      .subscribe(onError: { [weak self] error in
        self?.showMessage("Error", description: error.localizedDescription)
        }, onCompleted: { [weak self] in
          self?.showMessage("Saved")
          self?.actionClear()
      })
      .disposed(by: bag)
  }

  @IBAction func actionAdd() {
    let photosViewController = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController

    let newPhotos = photosViewController.selectedPhotos.share()

    newPhotos
      .takeWhile({ [weak self] image in
        return (self?.images.value.count ?? 0) < 6
      })
      .filter({ newImage in
        return newImage.size.width > newImage.size.height
      })
      .filter({ [weak self] newImage in
        let len = newImage.pngData()?.count ?? 0
        guard self?.imageCache.contains(len) == false
          else { return false }
        self?.imageCache.append(len)
        return true
      })
    .subscribe(onNext: { [weak self] newImage in
      guard let images = self?.images else { return }
      images.value.append(newImage)
    }, onDisposed: {
      print("completed photo selection")
    })
      .disposed(by: photosViewController.bag)
    
    navigationController!.pushViewController(photosViewController, animated: true)

    newPhotos
        .subscribe(onCompleted: { [weak self] in
            self?.updateNavigationIcon()
        })
        .disposed(by: photosViewController.bag)
  }

  private func updateNavigationIcon() {
    let icon = imagePreview.image?
    .scaled(CGSize(width: 22, height: 22))
    .withRenderingMode(.alwaysOriginal)

    navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon,
                                                       style: .done,
                                                       target: nil,
                                                       action: nil)
  }

  func showMessage(_ title: String, description: String? = nil) {
    showAlert(title: title, description: description)
      .subscribe()
      .disposed(by: bag)
  }
}
