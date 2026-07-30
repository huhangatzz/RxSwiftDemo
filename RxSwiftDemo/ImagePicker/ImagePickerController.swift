//
//  ImagePickerController.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/30.
//

import UIKit
import RxSwift
import RxCocoa

// 了解一下即可,感觉这样写反而复杂了
final class ImagePickerController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var galleryButton: UIButton!
    @IBOutlet var cropButton: UIButton!

    private let imagePickerDelegate = RxImagePickerDelegateProxy()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)

        cameraButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentCamera()
            })
            .disposed(by: disposeBag)

        imagePickerDelegate.didFinishPickingMedia
            .compactMap { info in
                info[.originalImage] as? UIImage
            }
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
    }

    private func presentCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = imagePickerDelegate
        present(picker, animated: true)
    }
}
