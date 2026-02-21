//
//  Bundle+Extensions.swift
//  Learn The Clock!
//
//  Created by Sebastian Strus on 2/21/26.
//

import SwiftUI
import UIKit
import MessageUI

extension Bundle {
    var appVersion: String {
        "\(infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0") (\(infoDictionary?["CFBundleVersion"] as? String ?? "1"))"
    }
}
