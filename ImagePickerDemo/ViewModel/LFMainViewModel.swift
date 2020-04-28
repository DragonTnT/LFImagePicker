//
//  LFImagePickerViewModel.swift
//  ImagePickerDemo
//
//  Created by Allen long on 2020/4/22.
//  Copyright © 2020 autocareai. All rights reserved.
//

import Foundation
import UIKit
import Photos

class LFMainViewModel {
    
    deinit {
        LFPHAssetsTool.shared.clear()
    }
    
    init(UIConfig: LFMainUIConfig) {
        self.mainUIConfig = UIConfig
        fetchTotalAssets()
        fetchTotalImages()
    }
    
    // collectionView的数据源
    var dataSource: [LFImageInfo] = []
    //已选图片
    var selectedPreviewItems: [LFPreviewItem] = [] {
        didSet {
            NotificationCenter.default.post(name: .LFSelectedImageCountChanged, object: selectedPreviewItems.count)
        }
    }
    //collectionView相关UI配置
    let mainUIConfig: LFMainUIConfig
    
    let selfNavigationH = navigationH
    
    let imageOptions = PHImageRequestOptions(quality: .low)
    
    lazy var imageManager: PHImageManager = {
        let it = PHImageManager.default()
        return it
    }()
    
    
    // 当相册图片数量较多时，一次加载所有图片会导致界面的渲染时间较长，所以分批次加载。
    // 第一次加载的图片数量，不建议自定义
    private var firstLoadImagesCount: Int = 50
    // 加载更多时，每次加载图片的数量。不建议自定义
    private var loadMoreCountEveryTime: Int = 200
    
    private var totalAssets: [PHAsset] = []
    
    /// 取到相册里所有的assets
    private func fetchTotalAssets() {
        LFPHAssetsTool.shared.loadAssets()
        LFPHAssetsTool.shared.assets?.enumerateObjects() { (asset, index, stop) in
            self.totalAssets.append(asset)
        }
        
    }
    
    /// 先获取firstLoadImagesCount个照片，让页面可以及时展示
    /// 再通过getRemainingImages，获取剩余的照片
    private func fetchTotalImages() {
        if totalAssets.isEmpty { return }
        if totalAssets.count <= firstLoadImagesCount {
            firstLoadImagesCount = totalAssets.count
        }
        DispatchQueue.global().async {
            self.dataSource = self.getImage(count: self.firstLoadImagesCount)
            self.dataSource.insert(LFImageInfo(image: #imageLiteral(resourceName: "phot_picker_camera")), at: 0)
            DispatchQueue.main.async {
                self.notifiyReloadData()
                self.getRemainingImages()
            }
        }
    }
}
// MARK: - Helper
extension LFMainViewModel {
            
    func addSelectedImage(at indexPath: IndexPath) {
        guard let assets = LFPHAssetsTool.shared.assets else { return }
        if indexPath.item  > dataSource.count - 1 { return }
        let asset = assets[indexPath.item - 1]
        let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        let options = PHImageRequestOptions(quality: .high)

        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
            if let image = image {
                let item = LFPreviewItem(isCheck: true, index: indexPath.item)
                item.image = image
                self.selectedPreviewItems.append(item)
            }
        }
    }
    
    func removeSelectedImage(at indexPath: IndexPath) {
        for (idx,item) in selectedPreviewItems.enumerated() {
            if item.index == indexPath.item {
                selectedPreviewItems.remove(at: idx)
                return
            }
        }
    }
    //串行队列取剩下的图片
    private func getRemainingImages() {
        if totalAssets.isEmpty { return }
        var getCount = totalAssets.count/loadMoreCountEveryTime
        if getCount * loadMoreCountEveryTime < totalAssets.count {
            getCount += 1
        }
        let queue = DispatchQueue(label: "image_picker_serial")
        for _ in 0..<getCount {
            queue.async {
                self.dataSource.append(contentsOf: self.getImage(count: self.loadMoreCountEveryTime))
                DispatchQueue.main.async {
                    self.notifiyReloadData()
                }
            }
        }
    }
    
    private func getImage(count: Int)-> [LFImageInfo] {
        var assets: [PHAsset] = []
        
        for (index,asset) in totalAssets.enumerated() {
            if index == count {
                break
            }
            assets.append(asset)
        }
        var loadMoreIndex: Int!
        if count < totalAssets.count {
            loadMoreIndex = count - 1
        } else {
            loadMoreIndex = totalAssets.count - 1
        }
        totalAssets.removeSubrange(0...loadMoreIndex)

        let imageInfos: [LFImageInfo] = getAssetThumbnail(assets: assets)
        return imageInfos
    }
        
    //TODO: 这里可以考虑将图片的请求过程变为并行，  目前为了保证顺序，图片的请求是串行。
    //可以考虑增加Index,变为并行。
    func getAssetThumbnail(assets: [PHAsset]) -> [LFImageInfo] {
        var imageInfoArray: [LFImageInfo] = []
        for asset in assets {
            imageManager.requestImage(for: asset, targetSize: mainUIConfig.targetSize, contentMode: .aspectFit, options: imageOptions, resultHandler: {(image, info)->Void in
                imageInfoArray.append(LFImageInfo(image: image!))
            })
        }
        return imageInfoArray
    }
    
    private func notifiyReloadData() {
        NotificationCenter.default.post(name: .LFImagePickerReloadData, object: nil)
    }
    
    func appendImageFromCamera(image: UIImage) {
        let imageInfo = LFImageInfo(image: image, isCheck: true)
        dataSource.insert(imageInfo, at: 1)
        // add index number on every item
        for item in selectedPreviewItems {
            if item.index != 0 {
                item.index += 1
            }
        }
        let previewItem = LFPreviewItem(isCheck: true, index: 1)
        previewItem.image = image
        selectedPreviewItems.append(previewItem) 
    }
}

extension Notification.Name {
    static let LFImagePickerReloadData = Notification.Name("LFImagePicker_reloadData")
    static let LFSelectedImageCountChanged = Notification.Name("LFImagePicker_selectedChanged")
}


