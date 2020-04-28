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
    
    init(image: UIImage? = nil, isCheck: Bool = false) {
        self.image = image
        self.isCheck = isCheck
    }
}
