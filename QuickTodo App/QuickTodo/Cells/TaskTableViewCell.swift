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
import Action
import RxSwift

class TaskItemTableViewCell: UITableViewCell {

  @IBOutlet var title: UILabel!
  @IBOutlet var button: UIButton!
  var disposeBag = DisposeBag()

  func configure(with item: TaskItem, action: CocoaAction) {
    button.rx.action = action

    item.rx.observe(String.self, "title")
      .subscribe(onNext: { [weak self] title in
        self?.title.text = title
      })
      .disposed(by: disposeBag)

    item.rx.observe(Date.self, "checked")
      .subscribe(onNext: { [weak self] date in
        let image = UIImage(named: (date == nil) ? "ItemNotChecked" : "ItemChecked")
        self?.button.setImage(image, for: .normal)
      })
      .disposed(by: disposeBag)
  }

  override func prepareForReuse() {
    button.rx.action = nil
    disposeBag = DisposeBag()
    super.prepareForReuse()
  }

}
