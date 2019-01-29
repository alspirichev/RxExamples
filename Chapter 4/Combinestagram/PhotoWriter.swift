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

import Foundation
import UIKit
import RxSwift

class PhotoWriter: NSObject {
  typealias Callback = (NSError?) -> Void

  private var callback: Callback

  private init(callBack: @escaping Callback) {
    self.callback = callBack
  }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
    callback(error)
  }

  static func save(_ image: UIImage) -> Observable<Void> {
    return Observable.create({ observer in
      let writer = PhotoWriter(callBack: { error in
        if let error = error {
          observer.onError(error)
        } else {
          observer.onCompleted()
        }
      })

      UIImageWriteToSavedPhotosAlbum(image,
                                     writer,
                                     #selector(PhotoWriter.image(_:didFinishSavingWithError:contextInfo:)),
                                     nil)
      return Disposables.create()
    })
  }

}

