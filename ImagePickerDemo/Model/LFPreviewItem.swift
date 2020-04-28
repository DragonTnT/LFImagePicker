//
//  LFPreviewItem.swift
//  ImagePickerDemo
//
//  Created by Allen long on 2020/4/24.
//  Copyright © 2020 autocareai. All rights reserved.
//

import Foundation
import UIKit


class LFPreviewItem {
    var image: UIImage?
    var isCheck: Bool = false
    var index: Int
    
    init(isCheck: Bool, index: Int) {
        self.isCheck = isCheck
        self.index = index
    }
}
