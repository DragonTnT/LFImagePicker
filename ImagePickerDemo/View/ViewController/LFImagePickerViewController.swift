//
//  LFImagePickerViewController.swift
//  ImagePickerDemo
//
//  Created by Allen long on 2020/4/21.
//  Copyright © 2020 autocareai. All rights reserved.
//

import UIKit

protocol LFImagePickerViewControllerDelegate: class {
    func didSelectImages(on pickerController: LFImagePickerViewController, with images: [UIImage])
    func selectedCountHasReachedTheMaximum(on controller: UIViewController)
    func didSelectedCancel(on pickerController: LFImagePickerViewController)
}

extension LFImagePickerViewControllerDelegate {
    func didSelectedCancel(on pickerController: LFImagePickerViewController) {
        pickerController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Lifecycle and properties
class LFImagePickerViewController: UIViewController {
    
    @discardableResult
    class func present(on callerVC: UIViewController, delegate: LFImagePickerViewControllerDelegate, UIConfig: LFMainUIConfig = LFMainUIConfig())-> LFImagePickerViewController {
        let pickerVC = LFImagePickerViewController(mainUIConfig: UIConfig)
        pickerVC.delegate = delegate
        callerVC.present(pickerVC.navigationVC!, animated: true, completion: nil)
        return pickerVC
    }
    
    deinit {
        
    }
    
    init(mainUIConfig: LFMainUIConfig = LFMainUIConfig()) {
        self.vm = LFMainViewModel(UIConfig: mainUIConfig)
        super.init(nibName: nil, bundle: nil)
        navigationVC = LFNavigationViewController(rootViewController: self)
        navigationVC?.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .LFImagePickerReloadData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectedImagesCountChanged(notification:)), name: .LFSelectedImageCountChanged, object: nil)
    }
    
    weak var delegate: LFImagePickerViewControllerDelegate?
    
    //视图模型
    let vm: LFMainViewModel
    let cancelBtn = LFNavigationBtn(title: "取消")
    let nextStepBtn: LFNavigationBtn = {
        let it = LFNavigationBtn(title: "下一步")
        it.changeUI(with: 0)
        return it
    }()
    
    private var navigationVC: LFNavigationViewController?
    private var collectionView: UICollectionView!
}

// MARK: - UICollectionViewDataSource,UICollectionViewDelegate
extension LFImagePickerViewController: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.lf_dequeueReusable(PickerCollectionViewCell.self, for: indexPath)
        let imageInfo = vm.dataSource[indexPath.item]
        cell.refreshUI(with: imageInfo, on: indexPath)
        cell.delegate = self        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            #if targetEnvironment(simulator)
              fatalError("camera can not open on simulator")
            #else
            PhotoCameraAuthorizer.authorizeType(.camera, dealingController: self) {
                if self.vm.selectedPreviewItems.count == self.vm.mainUIConfig.maxCountOfSelected {
                    self.delegate?.selectedCountHasReachedTheMaximum(on: self)
                    return
                }
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }
            #endif
        } else {
            let scrollIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            let vc = LFPreviewViewController(mainDataSource: vm.dataSource, scrollIndexPath: scrollIndexPath, selectedCount: vm.selectedPreviewItems.count)
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }        
    }
}

// MARK: - PickerCollectionViewCellDelegate
extension LFImagePickerViewController: PickerCollectionViewCellDelegate {
    func didTapCheck(on cell: PickerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        
        if !cell.isCheck {
            if vm.selectedPreviewItems.count == vm.mainUIConfig.maxCountOfSelected {
                //The quantity has reached the maximum
                delegate?.selectedCountHasReachedTheMaximum(on: self)
            } else {
                cell.isCheck = true
                vm.dataSource[indexPath.item].isCheck = true
                vm.addSelectedImage(at: indexPath)                
            }
        } else {
            cell.isCheck = false
            vm.dataSource[indexPath.item].isCheck = false
            vm.removeSelectedImage(at: indexPath)
        }
    }
}

extension LFImagePickerViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            vm.appendImageFromCamera(image: image)
            picker.dismiss(animated: true, completion: {
                self.collectionView.performBatchUpdates({
                    let indexPath = IndexPath(item: 1, section: 0)
                    self.collectionView.insertItems(at: [indexPath])
                }, completion: nil)
            })
        } else {
            // can not get image from camera
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

extension LFImagePickerViewController: LFPreviewViewControllerDelegate {
    func previewViewControllerGoBack(on controller: LFPreviewViewController) {
        let previewDataSouce = controller.vm.dataSource
        for (index,item) in previewDataSouce.enumerated() {
            vm.dataSource[index+1].isCheck = item.isCheck
        }
        collectionView.reloadData()
    }
}

// MARK: - Helper
extension LFImagePickerViewController {
    
    private func setupUI() {
        //注意第一次进入时需要提醒，在此处就取asset是为空
        view.backgroundColor = .white
        configNaivigationItems()
        configCollectionView()
    }
    
    private func configNaivigationItems() {
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        nextStepBtn.addTarget(self, action: #selector(nextStepAction), for: .touchUpInside)
        nextStepBtn.changeUI(with: 0)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBtn)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextStepBtn)
        
    }
    
    private func configCollectionView() {
        let config = vm.mainUIConfig
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = config.itemSpacing
        layout.minimumInteritemSpacing = config.itemSpacing
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: config.itemLength, height: config.itemLength)
        
        var frame = self.view.bounds
        frame.size.height -=  navigationH
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.lf_registerClassCell(PickerCollectionViewCell.self)        
        view.addSubview(collectionView)
    }

}

// MARK: - selector function
extension LFImagePickerViewController {
    @objc private func reloadData() {
        collectionView.reloadData()
    }
    
    @objc private func selectedImagesCountChanged(notification: Notification) {
        guard let selectedImagesCount = notification.object as? Int else { return }
        nextStepBtn.changeUI(with: selectedImagesCount)
    }
    
    @objc private func cancelAction() {
        navigationVC = nil
        delegate?.didSelectedCancel(on: self)
    }
    
    @objc func nextStepAction() {
        navigationVC = nil
        dismiss(animated: true, completion: nil)
        var images: [UIImage] = []
        for item in vm.selectedPreviewItems {
            if let image = item.image {
                images.append(image)
            }
        }
        delegate?.didSelectImages(on: self, with: images)
    }
}


