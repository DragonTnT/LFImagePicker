//
//  PickerCollectionViewCell.swift
//  ImagePickerDemo
//
//  Created by Allen long on 2020/4/21.
//  Copyright © 2020 autocareai. All rights reserved.
//

import UIKit

protocol PickerCollectionViewCellDelegate: class {
    func didTapCheck(on cell: PickerCollectionViewCell)
}

class PickerCollectionViewCell: UICollectionViewCell {
    weak var delegate: PickerCollectionViewCellDelegate?
    
    var isCheck: Bool = false {
        didSet {
            checkBtn.isSelected = isCheck
        }        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.masksToBounds = true
        contentView.addSubview(contentImageView)
        contentView.addSubview(checkBtn)
        contentImageView.frame = contentView.bounds
        let originX = contentView.bounds.width - contentLength - checkPaddingRight
        checkBtn.frame = CGRect(x: originX, y: checkPaddingRight, width: contentLength, height: contentLength)
        
        checkBtn.addTarget(self, action: #selector(checkAction), for: .touchUpInside)
    }
    
    let contentImageView: UIImageView = {
        let it = UIImageView()
        it.contentMode = .scaleAspectFill
        it.isUserInteractionEnabled = true
        return it
    }()
    
    let checkBtn: UIButton = {
        let it = UIButton()
        it.setImage(#imageLiteral(resourceName: "photo_check_default"), for: .normal)
        it.setImage(#imageLiteral(resourceName: "photo_check_selected"), for: .selected)
        return it
    }()
    
    @objc private func checkAction() {
        delegate?.didTapCheck(on: self)
    }
    
    func refreshUI(with imageInfo: LFImageInfo, on indexPath: IndexPath) {
        checkBtn.isHidden = (indexPath.item == 0)
        isCheck = imageInfo.isCheck
        contentImageView.contentMode = (indexPath.item == 0) ? .center : .scaleAspectFill
        contentImageView.image = imageInfo.image
    }
}

fileprivate let checkPaddingRight: CGFloat = 0
fileprivate let contentLength: CGFloat = 40
