//
//  LFPreviewViewModel.swift
//  ImagePickerDemo
//
//  Created by Allen long on 2020/4/24.
//  Copyright © 2020 autocareai. All rights reserved.
//

import Foundation
import Photos
import UIKit

class LFPreviewViewModel {
    
    init(mainSource: [LFImageInfo]) {
        for (index, infoItem) in mainSource.enumerated(){
            //when index == 0, it's the camera image which we don't need here.
            if index == 0 { continue }
            let item = LFPreviewItem(isCheck: infoItem.isCheck, index: index)
            dataSource.append(item)
        }
    }
    
    let selfNavigationH = navigationH
    
    var dataSource: [LFPreviewItem] = []
    lazy var imageManager: PHImageManager = {
        let it = PHImageManager.default()
        return it
    }()
    
    let imageOptions = PHImageRequestOptions(quality: .high)
    
    func requestImage(at indexPath: IndexPath, finishCallBack: @escaping(_ image: UIImage)->()) {
        guard let assets = LFPHAssetsTool.shared.assets else { return }
        if indexPath.item >= assets.count { return }
        let asset = assets[indexPath.item]
//        let targetSize = calculateTargetsizeForAsset(asset)
        let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: imageOptions) { (image, info) in
            if let image = image {
                self.dataSource[indexPath.item].image = image
                DispatchQueue.main.async {
                    finishCallBack(image)
                }
            }
        }
    }
    
    func calculateTargetsizeForAsset(_ asset: PHAsset)-> CGSize {
        let physicalWidth = CGFloat(asset.pixelWidth)/kScreenScale
        let physicalHeight = CGFloat(asset.pixelHeight)/kScreenScale

        var targetSize: CGSize!
        let albumSize = CGSize(width: kScreenWidth, height: kScreenHeight - selfNavigationH)
        if physicalHeight >= physicalWidth {
            let scale = physicalHeight/albumSize.height
            let width = albumSize.width/scale
            targetSize = CGSize(width: width, height: physicalHeight)
        } else {
            let scale = physicalWidth/albumSize.width
            let height = albumSize.height/scale
            targetSize = CGSize(width: physicalWidth, height: height)
        }
        return targetSize
    }
}

extension Notification.Name {
    static let LFPreviewReloadData = Notification.Name("LFPreview_reloadData")
}




