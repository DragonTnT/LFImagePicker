//
//  CommonConfig.swift
//  ImagePickerDemo
//
//  Created by Allen long on 2020/4/24.
//  Copyright © 2020 autocareai. All rights reserved.
//

import UIKit


public var navigationH: CGFloat {
    if isHairScreen() {
        return 88
    }
    return 64
}

/** 是否是刘海屏*/
func isHairScreen() -> Bool {
    if #available(iOS 11, *), UIApplication.shared.statusBarFrame.height == 44 {
        return true
    }
    return false
}
