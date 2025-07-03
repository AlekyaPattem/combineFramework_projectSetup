//
//  ColorExtension.swift
//  RajaKiRani
//
//  Created by KS-MACIMINI-016 on 13/03/25.
//

import Foundation
import UIKit

// MARK: - UIColor Extension for Hex Support
public extension UIColor {
  convenience init(hexString: String) {
    let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
    let scanner = Scanner(string: hexString)
    if hexString.hasPrefix("#") {
      scanner.currentIndex = hexString.index(after: hexString.startIndex)
    }
    var color: UInt64 = 0
    scanner.scanHexInt64(&color)
    let mask = 0x000000FF
    let red = CGFloat((color >> 16) & UInt64(mask)) / 255.0
    let green = CGFloat((color >> 8) & UInt64(mask)) / 255.0
    let blue = CGFloat(color & UInt64(mask)) / 255.0
    self.init(red: red, green: green, blue: blue, alpha: 1.0)
  }
}
