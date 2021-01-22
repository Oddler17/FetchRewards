//
//  Colors.swift
//  FetchRewards
//
//  Created by Arseniy Oddler on 1/20/21.
//

import UIKit

// MARK: - Colors

extension UIColor {

    /// Bright red color
    public static var brightRed: UIColor = .init(hex: "#D73C4B")
    /// Label color
    public static var label: UIColor = .dynamicColor(
        light: .black,
        dark: .white)
    /// Disabled label color
    public static var disabledLabel: UIColor = .dynamicColor(
        light: .gray(level: 2),
        dark: .gray(level: 5))
    /// Primary background color
    public static var primaryBackground: UIColor = .dynamicColor(
        light: .white,
        dark: .black)
    /// Secondary background color
    public static var secondaryBackground: UIColor = .dynamicColor(
        light: .gray(level: 1),
        dark: .gray(level: 6))

    /// - Parameter level: 1 to 6, light to dark scale
    /// - Returns: gray color
    private static func gray(level: Int) -> UIColor {

        switch max(level, 1) {
        case 1: return .init(hex: "#DDDFE1")
        case 2: return .init(hex: "#B4B9BE")
        case 3: return .init(hex: "#91989E")
        case 4: return .init(hex: "#4F555C")
        case 5: return .init(hex: "#31363B")
        default: return .init(hex: "#14171A")
        }
    }
}

// MARK: - Utility

extension UIColor {

    /// Initialize a color according to the hexadecimal string value
    public convenience init(hex: String, alpha: CGFloat = 1) {
        guard hex.hasPrefix("#") else {
            fatalError()
        }
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        guard hexColor.count == 6 else { fatalError() }
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else { fatalError() }

        let r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
        let g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
        let b = CGFloat((hexNumber & 0x0000FF) >> 0) / 255

        self.init(displayP3Red: r, green: g, blue: b, alpha: alpha)
    }

    /// Generate a dynamic color that changes according to the operating system dark/light mode
    public class func dynamicColor(
        light: UIColor,
        dark: UIColor) -> UIColor {

        if #available(iOS 13.0, *) {
            return UIColor {
                switch $0.userInterfaceStyle {
                case .dark: return dark
                default: return light
                }
            }
        } else {
            return light
        }
    }
}

