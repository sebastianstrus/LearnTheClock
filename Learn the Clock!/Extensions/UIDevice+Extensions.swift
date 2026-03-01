//
//  UIDevice+Extensions.swift
//  Learn The Clock!
//
//  Created by Sebastian Strus on 2/21/26.
//

import UIKit

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}


extension UIDevice {
    var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    var modelName: String {
        let identifier = modelIdentifier
        return deviceMapping[identifier] ?? identifier
    }
    
    private var deviceMapping: [String: String] {
        return [
            // MARK: - iPhone
            "iPhone1,1": "iPhone",
            "iPhone1,2": "iPhone 3G",
            "iPhone2,1": "iPhone 3GS",
            "iPhone3,1": "iPhone 4 (GSM)",
            "iPhone3,2": "iPhone 4 (GSM Rev A)",
            "iPhone3,3": "iPhone 4 (CDMA)",
            "iPhone4,1": "iPhone 4S",
            "iPhone5,1": "iPhone 5 (GSM)",
            "iPhone5,2": "iPhone 5 (Global)",
            "iPhone5,3": "iPhone 5c (GSM)",
            "iPhone5,4": "iPhone 5c (Global)",
            "iPhone6,1": "iPhone 5s (GSM)",
            "iPhone6,2": "iPhone 5s (Global)",
            "iPhone7,1": "iPhone 6 Plus",
            "iPhone7,2": "iPhone 6",
            "iPhone8,1": "iPhone 6s",
            "iPhone8,2": "iPhone 6s Plus",
            "iPhone8,4": "iPhone SE (1st Gen)",
            "iPhone9,1": "iPhone 7 (GSM)",
            "iPhone9,3": "iPhone 7 (Global)",
            "iPhone9,2": "iPhone 7 Plus (GSM)",
            "iPhone9,4": "iPhone 7 Plus (Global)",
            "iPhone10,1": "iPhone 8 (GSM)",
            "iPhone10,4": "iPhone 8 (Global)",
            "iPhone10,2": "iPhone 8 Plus (GSM)",
            "iPhone10,5": "iPhone 8 Plus (Global)",
            "iPhone10,3": "iPhone X (GSM)",
            "iPhone10,6": "iPhone X (Global)",
            "iPhone11,2": "iPhone XS",
            "iPhone11,4": "iPhone XS Max (China)",
            "iPhone11,6": "iPhone XS Max (Global)",
            "iPhone11,8": "iPhone XR",
            "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",
            "iPhone12,8": "iPhone SE (2nd Gen)",
            "iPhone13,1": "iPhone 12 mini",
            "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,4": "iPhone 13 mini",
            "iPhone14,5": "iPhone 13",
            "iPhone14,6": "iPhone SE (3rd Gen)",
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            // 2024–2025 identifiers (confirmed)
            "iPhone17,1": "iPhone 16 Pro",
            "iPhone17,2": "iPhone 16 Pro Max",
            "iPhone17,3": "iPhone 16",
            "iPhone17,4": "iPhone 16 Plus",
            "iPhone17,5": "iPhone 16e",       // lower‑tier 2025 model :contentReference[oaicite:2]{index=2}
            "iPhone18,1": "iPhone 17 Pro",
            "iPhone18,2": "iPhone 17 Pro Max",
            "iPhone18,3": "iPhone 17",
            "iPhone18,4": "iPhone Air",       // new 2025 model :contentReference[oaicite:3]{index=3}

            // MARK: - iPad (most recent)
            // Legacy & older entries (from your original list) go here…

            // 2024–2025 newly added iPad models
            "iPad15,3": "iPad Air (11‑inch, M3)",
            "iPad15,4": "iPad Air (11‑inch, M3) Wi‑Fi+Cellular",
            "iPad15,5": "iPad Air (13‑inch, M3)",
            "iPad15,6": "iPad Air (13‑inch, M3) Wi‑Fi+Cellular",
            "iPad15,7": "iPad (A16)",
            "iPad15,8": "iPad (A16) Wi‑Fi+Cellular",
            "iPad16,1": "iPad mini (A17 Pro)",
            "iPad16,2": "iPad mini (A17 Pro) Wi‑Fi+Cellular",
            "iPad17,1": "iPad Pro 11‑inch (M5)",
            "iPad17,2": "iPad Pro 11‑inch (M5) Wi‑Fi+Cellular",
            "iPad17,3": "iPad Pro 13‑inch (M5)",
            "iPad17,4": "iPad Pro 13‑inch (M5) Wi‑Fi+Cellular",

            // MARK: - iPod touch
            "iPod1,1": "iPod touch (1st Gen)",
            "iPod2,1": "iPod touch (2nd Gen)",
            "iPod3,1": "iPod touch (3rd Gen)",
            "iPod4,1": "iPod touch (4th Gen)",
            "iPod5,1": "iPod touch (5th Gen)",
            "iPod7,1": "iPod touch (6th Gen)",
            "iPod9,1": "iPod touch (7th Gen)",

            // MARK: - Simulator
            "i386": "Simulator (32‑bit)",
            "x86_64": "Simulator (64‑bit)",
            "arm64": "Simulator (Apple Silicon)"
        ]
    }
}


extension UIView {

    /// Returns screen size in points (e.g., "390×844 pt")
    var screenSizePoints: String? {
        guard let screen = window?.windowScene?.screen else { return nil }
        let bounds = screen.bounds
        return "\(Int(bounds.width))×\(Int(bounds.height)) pt"
    }

    /// Returns screen size in pixels (e.g., "1170×2532 px")
    var screenSizePixels: String? {
        guard let screen = window?.windowScene?.screen else { return nil }
        let bounds = screen.nativeBounds
        return "\(Int(bounds.width))×\(Int(bounds.height)) px"
    }

    /// Returns screen scale (e.g., "3.0x")
    var screenScale: String? {
        guard let screen = window?.windowScene?.screen else { return nil }
        return String(format: "%.1fx", screen.scale)
    }
}

extension UIDevice {
    /// Returns current orientation as a readable string
    var orientationName: String {
        if UIDevice.current.orientation.isValidInterfaceOrientation {
            switch UIDevice.current.orientation {
            case .portrait:
                return "Portrait"
            case .portraitUpsideDown:
                return "Portrait Upside Down"
            case .landscapeLeft:
                return "Landscape Left"
            case .landscapeRight:
                return "Landscape Right"
            case .faceUp:
                return "Face Up"
            case .faceDown:
                return "Face Down"
            default:
                return "Unknown Orientation"
            }
        } else {
            return "Flat (Not determined)"
        }
    }
}
