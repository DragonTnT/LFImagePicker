//
//  LFMainCollectionConfig.swift
//  ImagePickerDemo
//
//  Created by Allen long on 2020/4/22.
//  Copyright © 2020 autocareai. All rights reserved.
//

import Foundation
import UIKit

class LFMainUIConfig {
    
    var itemSpacing: CGFloat = 3
    var itemCountEveryRow: Int = 4
    var maxCountOfSelected: Int = 3
    
    var itemLength: CGFloat!
    
    //因屏幕分辨率不同，在从相册获取图片时，需要设置不同的分辨率
    var targetSize: CGSize!
    
    init(itemSpacing: CGFloat = 3, itemCountEveryRow: Int = 4) {
        self.itemSpacing = itemSpacing
        self.itemCountEveryRow = itemCountEveryRow
        setValueForOtherProperties()
    }
    
    func setValueForOtherProperties() {
        itemLength = (KScreenWidth - itemSpacing * CGFloat(itemCountEveryRow + 1))/CGFloat(itemCountEveryRow)
        targetSize = CGSize(width: itemLength * kScreenScale, height: itemLength * kScreenScale)
    }
}

fileprivate let KScreenWidth = UIScreen.main.bounds.width
let kScreenScale = UIScreen.main.scale
let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height
