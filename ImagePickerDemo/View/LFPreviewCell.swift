//
//  LFPreviewCell.swift
//  ImagePickerDemo
//
//  Created by Allen long on 2020/4/23.
//  Copyright © 2020 autocareai. All rights reserved.
//

import UIKit

protocol LFPreviewCellDelegate: class {
    func didTapCheck(on cell: LFPreviewCell)
}

class LFPreviewCell: UICollectionViewCell {
    
    weak var delegate: LFPreviewCellDelegate?
    
    let checkBtn: UIButton = {
        let it = UIButton()
        it.setImage(#imageLiteral(resourceName: "photo_check_default"), for: .normal)
        it.setImage(#imageLiteral(resourceName: "photo_check_selected"), for: .selected)
        return it
    }()
    
    var isCheck: Bool = false {
        didSet {
            checkBtn.isSelected = isCheck
        }
    }
    
    let contImgView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contImgView.frame = contentView.bounds
        contImgView.contentMode = .scaleAspectFit
        contentView.addSubview(contImgView)
        
        let originX = contentView.bounds.width - contentLength - checkPaddingRight
        checkBtn.frame = CGRect(x: originX, y: checkPaddingRight, width: contentLength, height: contentLength)
        checkBtn.addTarget(self, action: #selector(checkAction), for: .touchUpInside)
        contentView.addSubview(checkBtn)
    }
    
    @objc private func checkAction() {
        delegate?.didTapCheck(on: self)
    }
}

fileprivate let checkPaddingTop: CGFloat = 40
fileprivate let checkPaddingRight: CGFloat = 10
fileprivate let contentLength: CGFloat = 60
