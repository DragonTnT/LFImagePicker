//
//  PhotoCameraAuthorizer.swift
//  youchelai
//
//  Created by Allen long on 2020/4/23.
//  Copyright © 2020 utimes. All rights reserved.
//

import UIKit
import Photos

class PhotoCameraAuthorizer {
    
    static var completionClosure: (()->())?
    static var dealingController: UIViewController?
    
    static func authorizeType(_ authenticationType: AuthenticationType, dealingController: UIViewController ,completionClosure: @escaping ()->()) {
        self.dealingController = dealingController
        self.completionClosure = completionClosure
        
        switch authenticationType {
        case .photo:
            authorizePhotos(authType: authenticationType)
        case .camera:
            authorizeCamera(authType: authenticationType)
        }
    }
    
    
    static private func authorizePhotos(authType: AuthenticationType) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                if status == PHAuthorizationStatus.authorized {
                    self.completionAction()
                }
            }
        case .authorized:
            self.completionAction()
        case .denied, .restricted:
            alertTips(autType: authType)
        @unknown default:
            return
        }
    }
    
    static private func authorizeCamera(authType: AuthenticationType) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    self.completionAction()
                }
            }
        case .authorized:
            self.completionAction()
        case .denied, .restricted:
            alertTips(autType: authType)
        @unknown default:
            return
        }
    }
    
    static private func completionAction() {
        DispatchQueue.main.async {
            self.completionClosure?()
            self.dealingController = nil
            self.completionClosure = nil
        }
    }
    
    static private func alertTips(autType: AuthenticationType) {
        let title = "无法打开你的\(autType.rawValue)"
        let appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) ?? "App"
        let message = "\(appName)没有获得相册的使用权限，请在设置中开启「\(autType.rawValue)」"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let alertAction = UIAlertAction(title: "开启权限", style: .default) { (_) in
            PreferencesExplorer.openSetting()
        }
        alert.addAction(cancelAction)
        alert.addAction(alertAction)
        dealingController?.present(alert, animated: true, completion: nil)
    }
}

enum AuthenticationType: String{
    case photo = "照片"
    case camera = "相机"
}


