//
//  Theme.swift
//  BudgetApp
//
//  Created by AKWEYU on 19/11/2026.
//

import SwiftUI
import UIKit

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(UIColor(hex: hex))
    }

    init(light: UInt32, dark: UInt32) {
        self.init(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

enum Theme {
    static let primary = Color(hex: 0x80BA27)
    static let secondary = Color(hex: 0x00513A)
    static let background = Color(light: 0xF1F0F5, dark: 0x010100)
    static let surface = Color(light: 0xFFFFFF, dark: 0x121212)
    static let border = Color(light: 0xD9D9DE, dark: 0x2C2C2E)
    static let danger = Color(hex: 0xD32F2F)
}

enum AppFont {
    static func regular(_ size: CGFloat) -> Font {
        .custom("ProductSans-Regular", size: size)
    }

    static func medium(_ size: CGFloat) -> Font {
        .custom("ProductSans-Medium", size: size)
    }

    static func bold(_ size: CGFloat) -> Font {
        .custom("ProductSans-Bold", size: size)
    }
}

func money(_ value: Double) -> String {
    String(format: "%.1f", value)
}
