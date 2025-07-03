//
//  Extensions.swift
//  RajaKiRani
//
//  Created by KS-MACIMINI-016 on 13/03/25.
//

import Foundation
import UIKit
extension Encodable {
  func encodePrint() -> String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do {
      let jsonData = try encoder.encode(self)
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        return jsonString
      }
    } catch {
      print("Error encoding JSON: \(error)")
    }
    return nil
  }
}

// For String
extension Optional where Wrapped == String {
  var orEmpty: String {
    return self ?? ""
  }
}

// For Int
extension Optional where Wrapped == Int {
  var orZero: Int {
    return self ?? 0
  }
}

// For Bool
extension Optional where Wrapped == Bool {
  var orFalse: Bool {
    return self ?? false
  }
}

// For Double
extension Optional where Wrapped == Double {
  var orZero: Double {
    return self ?? 0.0
  }
}

// For Array
extension Optional where Wrapped == [Any] {
  var orEmptyArray: [Any] {
    return self ?? []
  }
}

// For Dictionary
extension Optional where Wrapped == [String: Any] {
  var orEmptyDictionary: [String: Any] {
    return self ?? [:]
  }
}
extension Array{
  func chunked(into size: Int) -> [[Element]] {
    stride(from: 0, to: count, by: size).map {
      Array(self[$0..<Swift.min($0 + size, count)])
    }
  }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
  
    @IBInspectable var topCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            clipsToBounds = true
        }
    }
  
  @IBInspectable var bottomCornerRadius: CGFloat {
      get {
          return layer.cornerRadius
      }
      set {
          layer.cornerRadius = newValue
          layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
          clipsToBounds = true
      }
  }
}

extension String {
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
    func containsOnlyLettersAndWhitespace() -> Bool {
        let allowed = CharacterSet.letters.union(.whitespaces)
        return unicodeScalars.allSatisfy(allowed.contains)
    }
}

extension UIViewController{
  
  func showAlertInVC(title: String, message: String) {
    let alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    present(alert, animated: true, completion: nil)
  }
}
extension UIImage {
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 32)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.init(cgImage: image!.cgImage!)
    }
}
