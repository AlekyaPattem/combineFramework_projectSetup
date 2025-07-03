import Foundation
import UIKit

extension UIFont {
    // MARK: - Nested
    private struct AppFontName {
        static let regular         = "Inter-Regular"
        static let bold            = "Inter-Bold"
        static let semibold        = "Inter-SemiBold"
        static let medium          = "Inter-Medium"
        static let light           = "Inter-Light"
        static let italic          = "Inter-Italic"
        static let extraBold       = "Inter-Extrabold"
        static let lightItalic     = "Inter-Italic"
        static let semiBoldItalic  = "Inter-SemiboldItalic"
        static let extraBoldItalic = "Inter-ExtraboldItalic"
        static let boldItalic      = "Inter-BoldItalic"
        static let dMSerifItalic   = "DMSerifDisplay-Italic"
        static let dMSerifRegular  = "DMSerifDisplay-Regular"
    }
}

extension UIFontDescriptor.AttributeName {
    static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

extension UIFont {
    static var isOverrided: Bool = false
    @objc class func appRegularFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.regular, size: size)!
    }
    @objc class func appBoldFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.bold, size: size)!
    }
    @objc class func appBoldItalicFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.boldItalic, size: size)!
    }
    @objc class func appItalicFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.italic, size: size)!
    }
    @objc class func appSemiBoldFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.semibold, size: size)!
    }
    @objc class func appMediumFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.medium, size: size)!
    }
    @objc class func appLightFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.light, size: size)!
    }
    @objc class func appdMSerifItalicFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.dMSerifItalic, size: size)!
    }
    @objc class func appdMSerifRegularFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.dMSerifRegular, size: size)!
    }
    @objc convenience init(myCoder aDecoder: NSCoder) {
        guard
            let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor,
            let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String
        else {
            self.init(myCoder: aDecoder)
            return
        }
        var fontName = ""
        switch fontAttribute {
        case "CTFontLightUsage":
            fontName = AppFontName.regular
        case "CTFontBoldUsage":
            fontName = AppFontName.bold
        default:
            fontName = AppFontName.regular
        }
        self.init(name: fontName, size: fontDescriptor.pointSize)!
    }
    class func overrideInitialize() {
        guard self == UIFont.self, !isOverrided else { return }
        // Avoid method swizzling run twice and revert to original initialize function
        isOverrided = true
        if let regularSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
           let myFontMethod = class_getClassMethod(self, #selector(appRegularFont(ofSize:))) {
            method_exchangeImplementations(regularSystemFontMethod, myFontMethod)
        }
        if let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
           let myFontMethod = class_getClassMethod(self, #selector(appBoldFont(ofSize:))) {
            method_exchangeImplementations(boldSystemFontMethod, myFontMethod)
        }
        if let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))),
           let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:))) {
            method_exchangeImplementations(initCoderMethod, myInitCoderMethod)
        }
    }
}
