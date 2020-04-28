//
//  LFExtensions.swift
//  ImagePickerDemo
//
//  Created by Allen long on 2020/4/22.
//  Copyright © 2020 autocareai. All rights reserved.
//

import Foundation
import UIKit
import Photos

extension UICollectionView {
    // 注册cell
    func lf_registerClassCell<T>(_ cellType: T.Type) where T: UICollectionViewCell {
        let identifier = "\(cellType)"
        register(cellType, forCellWithReuseIdentifier: identifier)
    }
    
    // 从缓存池池出队已经存在的 cell
    func lf_dequeueReusable<T: UICollectionViewCell>(_ cell: T.Type, for indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withReuseIdentifier: "\(T.self)", for: indexPath) as! T
        return cell
    }
}

extension UIViewController {
    //获取当前控制器在navigation栈内的前一个控制器
    func getPreviousControllerInNavigation()-> UIViewController? {
        guard let controllers = navigationController?.viewControllers else { return nil }
        for (index,controller) in controllers.enumerated() {
            if controller == self && index > 0 {
                return controllers[index - 1]
            }
        }
        return nil
    }
}

extension PHImageRequestOptions {
    convenience init(quality: LFQualityOfImage) {
        self.init()
        if quality == .high {
            resizeMode = .fast
            deliveryMode = .highQualityFormat
            isSynchronous = false
        } else {
            resizeMode = .fast
            deliveryMode = .fastFormat
            isSynchronous = true
        }
    }
}

enum LFQualityOfImage {
    case high
    case low
}
