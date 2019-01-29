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

extension UINavigationController {
    public typealias Delegate = UINavigationControllerDelegate
}

/// For more information take a look at `DelegateProxyType`.
open class RxNavigationControllerDelegateProxy
    : DelegateProxy<UINavigationController, UINavigationControllerDelegate>
    , DelegateProxyType
, UINavigationControllerDelegate {
    
    /// Typed parent object.
    public weak private(set) var navigationController: UINavigationController?
    
    /// - parameter navigationController: Parent object for delegate proxy.
    public init(navigationController: ParentObject) {
        self.navigationController = navigationController
        super.init(parentObject: navigationController, delegateProxy: RxNavigationControllerDelegateProxy.self)
    }
    
    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxNavigationControllerDelegateProxy(navigationController: $0) }
    }
}

//extension Reactive where Base: UINavigationController {
//  /**
//     Reactive wrapper for `delegate`.
//     For more information take a look at `DelegateProxyType` protocol documentation.
//     */
//  public var delegate: DelegateProxy<AnyObject, Any> {
//    return RxNavigationControllerDelegateProxy.proxyForObject(base)
//  }
//}
