//
//  Landing.swift
//  RippleGeography_UI
//
//  Created by Sebastian Strus on 22/08/25.
//

import SwiftUI

struct Landing: Identifiable {
    
    let id: String = UUID().uuidString
    let title: String
    let subtitle: String
    let cover: String
    let xOffset: CGFloat
    let yOffset: CGFloat
    var opacity: CGFloat = 1
    var scale: CGFloat = 1
}
