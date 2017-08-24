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
import RxCocoa

class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet var tableView: UITableView!

  let categories = Variable<[EOCategory]>([])
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    categories
      .asObservable()
      .subscribe(onNext: { [weak self] _ in
        DispatchQueue.main.async {
          self?.tableView?.reloadData()
        }
      })
      .addDisposableTo(disposeBag)

    startDownload()
  }

  func startDownload() {
    let eoCategories = EONET.categories

    let downloadedEvents = eoCategories.flatMap { categories in
      return Observable.from(categories.map { category in
        EONET.events(forLast: 360, category: category)
      })
    }
      .merge(maxConcurrent: 2)

    let updatedCategories = eoCategories.flatMap { categories in
      downloadedEvents.scan(categories) { updated, events in
        return updated.map { category in
          let eventsForCategory = EONET.filteredEvents(events: events, forCategory: category)
          if !eventsForCategory.isEmpty {
            var cat = category
            cat.events = cat.events + eventsForCategory
            return cat
          }
          return category
        }
      }
    }

    eoCategories
      .concat(updatedCategories)
      .bind(to: categories)
      .addDisposableTo(disposeBag)
  }
  
  // MARK: UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.value.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!

    let category = categories.value[indexPath.row]
    cell.detailTextLabel?.text = category.description
    cell.textLabel?.text = "\(category.name) (\(category.events.count))"
    cell.accessoryType = (category.events.count > 0) ? .disclosureIndicator : .none

    return cell
  }

  // MARK: - UITableViewDelegate -

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let category = categories.value[indexPath.row]
    if !category.events.isEmpty {
      let eventsController = storyboard!.instantiateViewController(withIdentifier: "events") as! EventsViewController
      eventsController.title = category.name
      eventsController.events.value = category.events
      navigationController!.pushViewController(eventsController, animated: true)
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
  }

  
}

