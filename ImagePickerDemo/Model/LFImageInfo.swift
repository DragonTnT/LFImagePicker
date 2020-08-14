//
//  LFImageInfo.swift
//  ImagePickerDemo
//
//  Created by Allen long on 2020/4/22.
//  Copyright © 2020 autocareai. All rights reserved.
//

import Foundation
import UIKit

class LFImageInfo {
    var image: UIImage?
    var isCheck: Bool
    var index: Int
    
    init(image: UIImage? = nil, isCheck: Bool = false, index: Int = 0) {
        self.image = image
        self.isCheck = isCheck
        self.index = index
    }
}
