//
//  UIImagePickerController+Rx.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/30.
//

#if os(iOS)

import RxCocoa
import RxSwift
import UIKit

public extension Reactive where Base: UIImagePickerController {
    /**
     Reactive wrapper for `delegate` message.
     */
    var didFinishPickingMediaWithInfo: Observable<[UIImagePickerController.InfoKey: AnyObject]> {
        delegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
            .map { a in
                try castOrThrow([UIImagePickerController.InfoKey: AnyObject].self, a[1])
            }
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    var didCancel: Observable<Void> {
        delegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
            .map { _ in () }
    }
}

#endif

private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}
