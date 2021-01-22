//
//  Fonts.swift
//  FetchRewards
//
//  Created by Arseniy Oddler on 1/20/21.
//

import UIKit

// MARK: - Fonts
extension UIFont {
    /// Title label font
    public static var title: UIFont = UIFont(name: .regular, size: 16)!
    /// Description label font
    public static var body: UIFont = UIFont(name: .light, size: 13)!
}

// MARK: - Font Names
extension String {
    fileprivate static let regular: String = "HelveticaNeue"
    fileprivate static let light: String = "HelveticaNeue-UltraLight"
}
