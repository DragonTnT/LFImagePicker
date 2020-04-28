//
//  LFNavigationBtn.swift
//  ImagePickerDemo
//
//  Created by Allen long on 2020/4/24.
//  Copyright © 2020 autocareai. All rights reserved.
//

import UIKit

class LFNavigationBtn: UIButton {
    init(title: String? = "") {
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        super.init(frame: frame)
        if let title = title {
            setTitle(title, for: .normal)
        }        
        setTitleColor(.black, for: .normal)
        setTitleColor(.gray, for: .disabled)
        titleLabel?.font = UIFont.systemFont(ofSize: 16)
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeUI(with count: Int) {
        if count == 0 {
            setTitle("下一步", for: .normal)
            setTitleColor(.gray, for: .normal)
            isUserInteractionEnabled = false
            frame.size.width = 40
        } else {
            let title = "下一步(\(count))"
            setTitle(title, for: .normal)
            setTitleColor(.black, for: .normal)
            isUserInteractionEnabled = true
            
        }
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let font = titleLabel?.font else { return }
        guard let width = titleLabel?.text?.calculateWidthWith(height: font.pointSize, font: font) else { return }
        frame.size.width = (width >= 40 ? width : 40)
    }
}

private extension String {
    func calculateWidthWith(height: CGFloat, font: UIFont)-> CGFloat {
        let attr = [(NSAttributedString.Key.font): font]
        //文字最大尺寸
        let maxSize: CGSize = CGSize(width: CGFloat(MAXFLOAT), height: height)
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        return self.boundingRect(with: (maxSize), options: option, attributes: attr, context: nil).size.width
    }
}
