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

typealias AnyDict = [String: Any]

class Event {
  let repo: String
  let name: String
  let imageUrl: URL
  let action: String

  // MARK: - JSON -> Event
  init?(dictionary: AnyDict) {
    guard let repoDict = dictionary["repo"] as? AnyDict,
      let actor = dictionary["actor"] as? AnyDict,
      let repoName = repoDict["name"] as? String,
      let actorName = actor["display_login"] as? String,
      let actorUrlString = actor["avatar_url"] as? String,
      let actorUrl  = URL(string: actorUrlString),
      let actionType = dictionary["type"] as? String
      else {
        return nil
    }

    repo = repoName
    name = actorName
    imageUrl = actorUrl
    action = actionType
  }

  // MARK: - Event -> JSON
  var dictionary: AnyDict {
    return [
      "repo" : ["name": repo],
      "actor": ["display_login": name, "avatar_url": imageUrl.absoluteString],
      "type" : action
    ]
  }
}
