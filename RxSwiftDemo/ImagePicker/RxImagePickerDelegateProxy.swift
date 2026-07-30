//
//  RxImagePickerDelegateProxy.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/30.
//

#if os(iOS)

import UIKit
import RxSwift

@MainActor
final class RxImagePickerDelegateProxy: NSObject,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {

    let didFinishPickingMedia = PublishSubject<[UIImagePickerController.InfoKey: Any]>()
    let didCancel = PublishSubject<Void>()

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        didFinishPickingMedia.onNext(info)
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        didCancel.onNext(())
        picker.dismiss(animated: true)
    }
}

#endif
