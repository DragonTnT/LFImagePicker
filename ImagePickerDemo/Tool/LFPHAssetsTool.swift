//
//  LFPHAssetsTool.swift
//  ImagePickerDemo
//
//  Created by Allen long on 2020/4/28.
//  Copyright © 2020 autocareai. All rights reserved.
//

import Foundation
import Photos

class LFPHAssetsTool {
    static let shared = LFPHAssetsTool()
    
    func loadAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assets = PHAsset.fetchAssets(with: .image, options: options)
    }
    
    func clear() {
        assets = nil
    }
    var assets: PHFetchResult<PHAsset>?
}
