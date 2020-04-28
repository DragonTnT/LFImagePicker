//
//  ViewController.swift
//  ImagePickerDemo
//
//  Created by Allen long on 2020/4/21.
//  Copyright © 2020 autocareai. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        imageView.addGestureRecognizer(tapGes)
        view.addSubview(imageView)
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.backgroundColor = .blue
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        return imageView
    }()
    
    @objc private func tapAction() {        
        PhotoCameraAuthorizer.authorizeType(.photo, dealingController: self) {
            let config = LFMainUIConfig()
            config.maxCountOfSelected = maxCountOfSelectedImages
            LFImagePickerViewController.present(on: self, delegate: self, UIConfig: config)
        }
    }
}

extension ViewController: LFImagePickerViewControllerDelegate {
    func selectedCountHasReachedTheMaximum(on pickerController: UIViewController) {
        print("最多只能选取\(maxCountOfSelectedImages)张图片")
    }
    
    func didSelectImages(on pickerController: LFImagePickerViewController, with images: [UIImage]) {

    }
}

fileprivate let maxCountOfSelectedImages: Int = 6



