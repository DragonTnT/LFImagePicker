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
    
    enum SelectionStyle {
        case single
        case multiple
    }
    
    //以下的item指的是：图片列表中每一个cell
    var itemSpacing: CGFloat = 3 {
        didSet {
            calculateItemLength()
        }
    }
    var itemCountEveryRow: Int = 4 {
        didSet {
            calculateItemLength()
        }
    }
    var itemLength: CGFloat! {
        didSet {
            calculateTargetSize()
        }
    }
    //最多可以选择的数量,仅在`selectionStyle`为true时生效
    var maxCountOfSelected: Int = 3
    //因屏幕分辨率不同，在从相册获取图片时，需要设置不同的分辨率
    var targetSize: CGSize!
    
    init() {
        calculateItemLength()
        calculateTargetSize()
    }
    
    func calculateItemLength() {
        itemLength = (KScreenWidth - itemSpacing * CGFloat(itemCountEveryRow + 1))/CGFloat(itemCountEveryRow)
    }
    
    func calculateTargetSize() {
        targetSize = CGSize(width: itemLength * kScreenScale, height: itemLength * kScreenScale)
    }
}

fileprivate let KScreenWidth = UIScreen.main.bounds.width
let kScreenScale = UIScreen.main.scale
let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height
