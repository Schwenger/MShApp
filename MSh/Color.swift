//
//  Color.swift
//  MSh
//
//  Created by Maximilian Schwenger on 10.03.23.
//

import Foundation
import SwiftUI

extension Color {
    
    // MARK: - Text Colors
    static let lightText = Color(UIColor.lightText)
    static let darkText = Color(UIColor.darkText)
    static let placeholderText = Color(UIColor.placeholderText)
    
    // MARK: - Label Colors
    static let label = Color(UIColor.label)
    static let secondaryLabel = Color(UIColor.secondaryLabel)
    static let tertiaryLabel = Color(UIColor.tertiaryLabel)
    static let quaternaryLabel = Color(UIColor.quaternaryLabel)
    
    // MARK: - Background Colors
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)
    
    // MARK: - Fill Colors
    static let systemFill = Color(UIColor.systemFill)
    static let secondarySystemFill = Color(UIColor.secondarySystemFill)
    static let tertiarySystemFill = Color(UIColor.tertiarySystemFill)
    static let quaternarySystemFill = Color(UIColor.quaternarySystemFill)
    
    // MARK: - Grouped Background Colors
    static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
    static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let tertiarySystemGroupedBackground = Color(UIColor.tertiarySystemGroupedBackground)
    
    // MARK: - Gray Colors
    static let systemGray = Color(UIColor.systemGray)
    static let systemGray2 = Color(UIColor.systemGray2)
    static let systemGray3 = Color(UIColor.systemGray3)
    static let systemGray4 = Color(UIColor.systemGray4)
    static let systemGray5 = Color(UIColor.systemGray5)
    static let systemGray6 = Color(UIColor.systemGray6)
    
    // MARK: - Other Colors
    static let separator = Color(UIColor.separator)
    static let opaqueSeparator = Color(UIColor.opaqueSeparator)
    static let link = Color(UIColor.link)
    
    // MARK: System Colors
    static let systemBlue = Color(UIColor.systemBlue)
    static let systemPurple = Color(UIColor.systemPurple)
    static let systemGreen = Color(UIColor.systemGreen)
    static let systemYellow = Color(UIColor.systemYellow)
    static let systemOrange = Color(UIColor.systemOrange)
    static let systemPink = Color(UIColor.systemPink)
    static let systemRed = Color(UIColor.systemRed)
    static let systemTeal = Color(UIColor.systemTeal)
    static let systemIndigo = Color(UIColor.systemIndigo)
    
}

extension Color {
    func hsv() -> (Double, Double, Double) {
        let col = UIColor(self)
        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var val: CGFloat = 0
        col.getHue(&hue, saturation: &sat, brightness: &val, alpha: nil)
        return (hue, sat, val)
    }
}

//extension Color {
//    func rgb() -> String? {
//        let col = UIColor(self)
//        var fRed : CGFloat = 0
//        var fGreen : CGFloat = 0
//        var fBlue : CGFloat = 0
//        var fAlpha: CGFloat = 0
//        if col.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
//            let iRed = Int(fRed * 255.0)
//            let iGreen = Int(fGreen * 255.0)
//            let iBlue = Int(fBlue * 255.0)
//            return String(format:"#%02X%02X%02X", iRed, iGreen, iBlue)
//        } else {
//            return nil
//        }
//    }
//
//    init(hex: String) {
//        let hex = hex.suffix(6).trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//            case 3: // RGB (12-bit)
//                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//            case 6: // RGB (24-bit)
//                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//            case 8: // ARGB (32-bit)
//                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//            default:
//                (a, r, g, b) = (1, 1, 1, 0)
//        }
//
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue:  Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}
