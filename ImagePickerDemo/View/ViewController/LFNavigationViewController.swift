//
//  LFNavigationViewController.swift
//  ImagePickerDemo
//
//  Created by Allen long on 2020/4/21.
//  Copyright © 2020 autocareai. All rights reserved.
//

import UIKit

class LFNavigationViewController: UINavigationController {
    
    deinit {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.tintColor = .black
        navigationBar.barTintColor = .white
        navigationBar.isTranslucent = false
    }
}

