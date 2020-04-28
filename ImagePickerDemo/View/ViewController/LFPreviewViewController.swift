//
//  LFPreviewViewController.swift
//  ImagePickerDemo
//
//  Created by Allen long on 2020/4/23.
//  Copyright © 2020 autocareai. All rights reserved.
//

import UIKit

protocol LFPreviewViewControllerDelegate: class {
    func previewViewControllerGoBack(on controller: LFPreviewViewController)
}

class LFPreviewViewController: UIViewController {
    
    deinit {
        
    }
    
    weak var delegate: LFPreviewViewControllerDelegate?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: .LFImagePickerReloadData, object: nil)
    }
    
    init(mainDataSource: [LFImageInfo], scrollIndexPath: IndexPath, selectedCount: Int) {
        vm = LFPreviewViewModel(mainSource: mainDataSource)
        self.scrollIndexPath = scrollIndexPath
        self.nextStepBtn.changeUI(with: selectedCount)
        super.init(nibName: nil, bundle: nil)        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let scrollIndexPath: IndexPath
    let vm: LFPreviewViewModel
    let goBackBtn = LFNavigationBtn(title: "返回")
    let nextStepBtn = LFNavigationBtn(title: "下一步")
    
    lazy var collectionView: UICollectionView = {
        var frame = self.view.bounds
        frame.size.height -= navigationH
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = frame.size
        layout.minimumLineSpacing = 0
        
        let it = UICollectionView(frame: frame, collectionViewLayout: layout)
        it.isPagingEnabled = true
        it.showsHorizontalScrollIndicator = false
        return it
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectedImagesCountChanged(notification:)), name: .LFSelectedImageCountChanged, object: nil)
    }
    
    private func setupUI() {
        title = "预览"
        view.backgroundColor = .black
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.lf_registerClassCell(LFPreviewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.scrollToItem(at: scrollIndexPath, at: .right, animated: false)
        setupNavigations()
    }
    
    private func setupNavigations() {
        goBackBtn.addTarget(self, action: #selector(goBackAction), for: .touchUpInside)
        nextStepBtn.addTarget(self, action: #selector(nextStepAction), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: goBackBtn)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextStepBtn)
    }
    
    @objc private func goBackAction() {
        delegate?.previewViewControllerGoBack(on: self)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func nextStepAction() {
        guard let pickerVC = getPreviousControllerInNavigation() as? LFImagePickerViewController else { return }
        pickerVC.nextStepAction()
    }
    
    @objc private func selectedImagesCountChanged(notification: Notification) {
        guard let selectedImagesCount = notification.object as? Int else { return }
        nextStepBtn.changeUI(with: selectedImagesCount)
    }
}

extension LFPreviewViewController: UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.lf_dequeueReusable(LFPreviewCell.self, for: indexPath)
        cell.delegate = self
        cell.isCheck = vm.dataSource[indexPath.item].isCheck
        if let image = vm.dataSource[indexPath.item].image {
            cell.contImgView.image = image
        } else {
            vm.requestImage(at: indexPath) { requestedImage in
                cell.contImgView.image = requestedImage
            }
        }
        return cell
    }
    
    //清除未选图片的内存，防止内存暴增
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = vm.dataSource[indexPath.item]
        if !item.isCheck {
            item.image = nil
        }
    }
}

extension LFPreviewViewController: LFPreviewCellDelegate {
    func didTapCheck(on cell: LFPreviewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard let pickerVC = getPreviousControllerInNavigation() as? LFImagePickerViewController else { return }
        if indexPath.item >= vm.dataSource.count { return }
        
        let checkItem = LFPreviewItem(isCheck: true, index: indexPath.item + 1)
        checkItem.image = cell.contImgView.image
        if !cell.isCheck {
            if pickerVC.vm.selectedPreviewItems.count == pickerVC.vm.mainUIConfig.maxCountOfSelected {
                pickerVC.delegate?.selectedCountHasReachedTheMaximum(on: self)
            } else {
                cell.isCheck = true
                vm.dataSource[indexPath.item].isCheck = true
                pickerVC.vm.selectedPreviewItems.append(checkItem)
            }
        } else {
            for (idx,item) in pickerVC.vm.selectedPreviewItems.enumerated() {
                if item.index == indexPath.item + 1 {
                    pickerVC.vm.selectedPreviewItems.remove(at: idx)
                    break
                }
            }
            cell.isCheck = false
            vm.dataSource[indexPath.item].isCheck = false
        }
        
        
    }
}

