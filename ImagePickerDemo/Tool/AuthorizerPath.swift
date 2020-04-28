//
//  AuthorizerPath.swift
//  youchelai
//
//  Created by Allen long on 2020/4/23.
//  Copyright © 2020 utimes. All rights reserved.
//

import Foundation
import UIKit

class PreferencesExplorer {
    static func openSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

