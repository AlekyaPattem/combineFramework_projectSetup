import UIKit
import Foundation
import Lottie

// MARK: - Designable Extension

@IBDesignable
extension UIView {
    
    //Add border
    func addBorder(){
        self.borderColor = ColorConstants.gray
        self.borderWidth = 1.2
    }
    
    @IBInspectable
    /// Should the corner be as circle
    public var circleCorner: Bool {
        get {
            return min(bounds.size.height, bounds.size.width) / 2 == cornerRadius
        }
        set {
            cornerRadius = newValue ? min(bounds.size.height, bounds.size.width) / 2 : cornerRadius
        }
    }
    
    @IBInspectable
    /// Border color of view; also inspectable from Storyboard.
    public var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
        set {
            guard let color = newValue else {
                layer.borderColor = nil
                return
            }
            layer.borderColor = color.cgColor
        }
    }
    
    @IBInspectable
    /// Border width of view; also inspectable from Storyboard.
    public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    /// Shadow color of view; also inspectable from Storyboard.
    public var shadowColor: UIColor? {
        get {
            guard let color = layer.shadowColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    /// Shadow offset of view; also inspectable from Storyboard.
    public var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    /// Shadow opacity of view; also inspectable from Storyboard.
    public var shadowOpacity: Double {
        get {
            return Double(layer.shadowOpacity)
        }
        set {
            layer.shadowOpacity = Float(newValue)
        }
    }
    
    @IBInspectable
    /// Shadow radius of view; also inspectable from Storyboard.
    public var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    /// Shadow path of view; also inspectable from Storyboard.
    public var shadowPath: CGPath? {
        get {
            return layer.shadowPath
        }
        set {
            layer.shadowPath = newValue
        }
    }
    
    @IBInspectable
    /// Should shadow rasterize of view; also inspectable from Storyboard.
    /// cache the rendered shadow so that it doesn't need to be redrawn
    public var shadowShouldRasterize: Bool {
        get {
            return layer.shouldRasterize
        }
        set {
            layer.shouldRasterize = newValue
        }
    }
    
    @IBInspectable
    /// Should shadow rasterize of view; also inspectable from Storyboard.
    /// cache the rendered shadow so that it doesn't need to be redrawn
    public var shadowRasterizationScale: CGFloat {
        get {
            return layer.rasterizationScale
        }
        set {
            layer.rasterizationScale = newValue
        }
    }
    
    @IBInspectable
    /// Corner radius of view; also inspectable from Storyboard.
    public var maskToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
}


//MARK: Xib initialization
extension UIViewController{
//        func tab_bar()->TabBar{
//            return Bundle.main.loadNibNamed("TabBar", owner: self, options: nil)! [0] as! TabBar
//        }
    
    //    func head_bar()->HeaderView{
    //        return Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)! [0] as! HeaderView
    //    }
}

// MARK: - Properties

public extension UIView {
    
    /// Size of view.
    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.width = newValue.width
            self.height = newValue.height
        }
    }
    
    /// Width of view.
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    /// Height of view.
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    func gradient(){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: frame.width+100, height: frame.height)
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.2),UIColor.black.cgColor]
        gradientLayer.startPoint = CGPoint(x: frame.width, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: frame.width, y: 0.5)
        layer.addSublayer(gradientLayer)
    }
    
    func addGradient(cornerRadius: CGFloat = 0) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [
            UIColor(red: 0.84, green: 0.70, blue: 0.48, alpha: 1).cgColor, // #D6B37B
            UIColor(red: 1.0, green: 0.86, blue: 0.64, alpha: 1).cgColor,  // #FFDCA4
            UIColor(red: 0.62, green: 0.53, blue: 0.38, alpha: 1).cgColor  // #9F8760
        ]
        gradient.startPoint     = CGPoint(x: 0.0, y: 0.5) // Left
        gradient.endPoint       = CGPoint(x: 1.0, y: 0.5)   // Right
        gradient.cornerRadius   = cornerRadius
        // Remove previous gradient layers if any
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func removeGradient() {
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
    }
    
  func addGradientBorder(cornerRadius: CGFloat = 0, borderWidth: CGFloat = 2) {
      // Remove existing gradient border layers if any
      self.layer.sublayers?.removeAll(where: { $0.name == "gradientBorder" })
      
      // Create gradient layer
      let gradient = CAGradientLayer()
      gradient.name = "gradientBorder"
      gradient.frame = self.bounds
      gradient.colors = [
          UIColor(red: 0.84, green: 0.70, blue: 0.48, alpha: 1).cgColor, // #D6B37B
          UIColor(red: 1.0, green: 0.86, blue: 0.64, alpha: 1).cgColor,  // #FFDCA4
          UIColor(red: 0.62, green: 0.53, blue: 0.38, alpha: 1).cgColor  // #9F8760
      ]
      gradient.startPoint = CGPoint(x: 0.0, y: 0.5) // Left
      gradient.endPoint = CGPoint(x: 1.0, y: 0.5)   // Right
      gradient.cornerRadius = cornerRadius
      
      // Create shape layer for border mask
      let shape = CAShapeLayer()
      let insetRect = self.bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
      shape.path = UIBezierPath(roundedRect: insetRect, cornerRadius: cornerRadius).cgPath
      shape.lineWidth = borderWidth
      shape.fillColor = UIColor.clear.cgColor
      shape.strokeColor = UIColor.black.cgColor
      
      // Mask gradient with shape layer to show border only
      gradient.mask = shape
      
      // Add gradient border layer above other layers
      self.layer.addSublayer(gradient)
  }

    
    func addSilverGradient(cornerRadius: CGFloat = 0) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [
            UIColor(red: 0.74, green: 0.74, blue: 0.74, alpha: 1).cgColor, // #BDBDBD
            UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).cgColor, // #F2F2F2
            UIColor(red: 0.74, green: 0.74, blue: 0.74, alpha: 1).cgColor  // #BDBDBD
        ]
        gradient.startPoint     = CGPoint(x: 0.0, y: 0.5) // Left
        gradient.endPoint       = CGPoint(x: 1.0, y: 0.5)   // Right
        gradient.cornerRadius   = cornerRadius
        // Remove previous gradient layers if any
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        self.layer.insertSublayer(gradient, at: 0)
    }
}




//MARK: - Extension
private var key = "gradientLayerKey"
extension UIView {
    var gradientLayer: CAGradientLayer? {
        get {
            return objc_getAssociatedObject(self, &key) as? CAGradientLayer
        }
        set {
            objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private func gradientLayerInstance(color1:UIColor,color2:UIColor,startPoint:CGPoint,endPoint:CGPoint)->CAGradientLayer {
        let newGradientLayer = CAGradientLayer()
        newGradientLayer.frame = self.bounds
        newGradientLayer.startPoint = startPoint
        newGradientLayer.endPoint = endPoint
        newGradientLayer.colors = [
            color1.cgColor,
            color2.cgColor
        ]
        
        return newGradientLayer
    }
    
    //MARK: applyGradientColor
    open func applyGradientColor(cornerRadius: CGFloat,color1:UIColor,color2:UIColor,startPoint:CGPoint,endPoint:CGPoint) {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = gradientLayerInstance(color1: color1, color2: color2,startPoint:startPoint,endPoint:endPoint)
        gradientLayer?.cornerRadius = cornerRadius
        self.layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    //MARK: removeGradientLayer
    public func removeGradientLayer() {
        gradientLayer?.removeFromSuperlayer()
    }
    
    //MARK: addShadowToView
    public func addShadowToView(shadow_color: UIColor,offset: CGSize,shadow_radius: CGFloat,shadow_opacity: Float,corner_radius: CGFloat) {
        self.layer.shadowColor   = shadow_color.cgColor
        self.layer.shadowOpacity = shadow_opacity
        self.layer.shadowOffset  = offset
        self.layer.shadowRadius  = shadow_radius
        self.layer.cornerRadius  = corner_radius
        self.clipsToBounds       = false
        self.backgroundColor     = .white
    }
    
    // Corner radius for required corners
    func applyRoundedCorners(corners: UIRectCorner, radius: CGFloat) {
        layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        layer.cornerRadius = 30
    }
    
    func applyCorners(radius: CGFloat,color: UIColor, borderWidth: CGFloat) {
        layer.borderColor = color.cgColor
        layer.cornerRadius = radius
        layer.borderWidth = borderWidth
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}

extension UIView {
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview.flatMap { $0.superview(of: T.self) }
    }
}

extension UIView {
    
    func searchVisualEffectsSubview() -> UIVisualEffectView? {
        if let visualEffectView = self as? UIVisualEffectView {
            return visualEffectView
        } else {
            for subview in subviews {
                if let found = subview.searchVisualEffectsSubview() {
                    return found
                }
            }
        }
        return nil
    }
    
    /// This is the function to get subViews of a view of a particular type
    /// https://stackoverflow.com/a/45297466/5321670
    func subViews<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        for view in self.subviews {
            if let aView = view as? T{
                all.append(aView)
            }
        }
        return all
    }
    
    
    /// This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T
    /// https://stackoverflow.com/a/45297466/5321670
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T{
                all.append(aView)
            }
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}

//MARK: - Shadow for MyHUb
extension UIView {
    func applyInnerShadow(radiusInt: CGFloat) {
        let innerShadow = CALayer()
        innerShadow.name = "innerShadow"
        innerShadow.frame = self.bounds
        // Shadow path (1pt ring around bounds)
        let radius = self.layer.cornerRadius
        let path = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: 2, dy:2), cornerRadius:radius)
        let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius:radius).reversing()
        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        // Shadow properties
        innerShadow.shadowColor = UIColor.black.cgColor
        innerShadow.shadowOffset = CGSize(width: 0, height: 2)
        innerShadow.shadowOpacity = 0.3
        innerShadow.shadowRadius = 3.5
        innerShadow.cornerRadius = radiusInt
        //self.removeAllSublayers()
        layer.shadowOpacity = 0
        layer.addSublayer(innerShadow)
    }
    
    func applyOuterShadow(corner        : CGFloat,
                          shadowColor   : UIColor = (ColorConstants.gray.withAlphaComponent(0.17)),
                          shadowRadius  : Int = 10,
                          shadowOffset  : CGSize = CGSize(width: 0, height: 0)) {
        layer.shadowColor   = shadowColor.cgColor
        layer.shadowOpacity = 1
        layer.cornerRadius  = corner
        layer.shadowOffset  = shadowOffset
        layer.shadowRadius  = CGFloat(shadowRadius)
        layer.masksToBounds = false
    }
    
    func removeAllSublayers(){
        if let sublayers = self.layer.sublayers, !sublayers.isEmpty{
            for sublayer in sublayers{
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
    @discardableResult
    func addLineDashedStroke() {
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = ColorConstants.gray.cgColor
        borderLayer.lineDashPattern = [5, 5]
        borderLayer.frame = bounds
        borderLayer.fillColor = nil
        borderLayer.borderWidth = 0 // Set to 0 to remove the default border
        borderLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 6, height: 6)).cgPath
        layer.addSublayer(borderLayer)
    }
    
    func addBumpInMiddleTop(height: CGFloat, width: CGFloat, color: UIColor) {
        let bumpLayer = CALayer()
        bumpLayer.frame = CGRect(x: (bounds.width - width) / 2, y: 0, width: width, height: height)
        bumpLayer.backgroundColor = color.cgColor
        
        let bumpPath = UIBezierPath()
        bumpPath.move(to: CGPoint(x: 0, y: height))
        bumpPath.addQuadCurve(to: CGPoint(x: width, y: height), controlPoint: CGPoint(x: width / 2, y: 0))
        bumpPath.close()
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = bumpPath.cgPath
        bumpLayer.mask = maskLayer
        
        layer.addSublayer(bumpLayer)
    }
    
}
//MARK: - Lottie animation
extension UIView {
    //Loading indicator
    func showLottie(_ show: Bool,lottieName:String, loaderSize: CGSize,loopMode:LottieLoopMode = .loop) {
        let tag = 808404
        if show {
            //self.isEnabled = false
            //            self.alpha = 0.5
            DispatchQueue.main.async{
                let indicator = UIActivityIndicatorView()
                let buttonHeight = loaderSize.height
                let buttonWidth = loaderSize.width
                indicator.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
                indicator.tag = tag
                
                var animationView = LottieAnimationView()
                //            animationView.removeFromSuperview()
                animationView           = .init(name: lottieName)
                animationView.center    = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
                animationView.bounds    = self.bounds
                animationView.width     = loaderSize.width
                animationView.height    = loaderSize.height
                animationView.center    = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
                animationView.loopMode  = loopMode//.loop
                animationView.tag       = tag
                //            animationView.backgroundColor = ColorConstants.wn_red
                if let animateView = self.viewWithTag(tag) as? LottieAnimationView {
                    animateView.stop()
                    animateView.removeFromSuperview()
                }
                self.addSubview(animationView)
                self.bringSubviewToFront(animationView)
                animationView.play()
                indicator.startAnimating()
            }
        } else {
            if let animateView = self.viewWithTag(tag) as? LottieAnimationView {
                animateView.stop()
                animateView.removeFromSuperview()
            }
        }
    }
}

extension UIView {
    func blink(duration: TimeInterval = 0.5) {
        self.alpha = 1.0
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [.repeat, .autoreverse, .allowUserInteraction],
            animations: {
                self.alpha = 0.5
            },
            completion: nil
        )
    }
}

extension UIView {
    func startZoomAnimation(duration: TimeInterval = 2.0, scale: CGFloat = 1.2) {
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.repeat, .autoreverse], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self.transform = CGAffineTransform.identity
            }
        })
    }
    
    func stopZoomAnimation() {
        self.layer.removeAllAnimations()
        self.transform = .identity // Reset to original state
    }
}

class ZoomableView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Check if the point falls within any subview's frame
        for subview in subviews {
            let convertedPoint = subview.convert(point, from: self)
            if let hitView = subview.hitTest(convertedPoint, with: event) {
                return hitView
            }
        }
        // If no subview is hit, return the default behavior
        return super.hitTest(point, with: event)
    }
}

//MARK: No internet animation
extension UIView{
    //    func noInternetAnimation()->Bool{
    //        if !ApiUrl.shared.isNetworkEnabled(){
    //            self.showLottie(true, lottieName: "No_internet", loaderSize: self.bounds.applying(CGAffineTransform(scaleX: 0.5, y: 0.5)).size)
    //            return false
    //        }else{
    //            self.showLottie(false, lottieName: "No_internet", loaderSize: self.bounds.applying(CGAffineTransform(scaleX: 0.5, y: 0.5)).size)
    //            return true
    //        }
    //    }
    
    func noDataAnimation(Show:Bool, scale:CGFloat? = 0.6)->Bool{
        if Show{
            self.showLottie(true, lottieName: "No_Data", loaderSize: self.bounds.applying(CGAffineTransform(scaleX: scale!, y: scale!)).size)
            return false
        }else{
            self.showLottie(false, lottieName: "No_Data", loaderSize: self.bounds.applying(CGAffineTransform(scaleX: scale!, y: scale!)).size)
            return true
        }
    }
}

//MARK: To get leading and trailing constraints of a view programatically
extension UIView {
    var leadingConstraint: NSLayoutConstraint? {
        return superview?.constraints.first(where: {
            ($0.firstItem as? UIView == self && $0.firstAttribute == .leading) ||
            ($0.secondItem as? UIView == self && $0.secondAttribute == .leading)
        })
    }
    
    var trailingConstraint: NSLayoutConstraint? {
        return superview?.constraints.first(where: {
            ($0.firstItem as? UIView == self && $0.firstAttribute == .trailing) ||
            ($0.secondItem as? UIView == self && $0.secondAttribute == .trailing)
        })
    }
    
    var topConstraint: NSLayoutConstraint? {
        return superview?.constraints.first(where: {
            ($0.firstItem as? UIView == self && $0.firstAttribute == .top) ||
            ($0.secondItem as? UIView == self && $0.secondAttribute == .top)
        })
    }
    
    var bottomConstraint: NSLayoutConstraint? {
        return superview?.constraints.first(where: {
            ($0.firstItem as? UIView == self && $0.firstAttribute == .bottom) ||
            ($0.secondItem as? UIView == self && $0.secondAttribute == .bottom)
        })
    }
    
    var heightConstraint: NSLayoutConstraint? {
        return constraints.first(where: {
            ($0.firstAttribute == .height && $0.firstItem as? UIView == self) ||
            ($0.secondAttribute == .height && $0.secondItem as? UIView == self)
        })
    }
}

//Scroll to top
extension UIScrollView {
    func scrollToTop(animated: Bool) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }
}

//MARK: Images grid view using stackView
protocol ImageTapDelegate: AnyObject {
    func didTapImage(_ image: UIImage,tag:Int)
}

extension UIStackView {
    // Create delegate to get Tapping action of the images
    private struct AssociatedKeys {
        static var imageTapDelegate = "imageTapDelegate"
    }
    
    weak var imageTapDelegate: ImageTapDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.imageTapDelegate) as? ImageTapDelegate
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.imageTapDelegate, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    func addTapGesture(to view: UIView,tag:Int) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        tapGesture.view?.tag = tag
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    @objc private func handleImageTap(_ gesture: UITapGestureRecognizer) {
        if let imageView = gesture.view as? UIImageView, let image = imageView.image {
            imageTapDelegate?.didTapImage(image, tag: imageView.tag )
        }
    }
}

extension UIImageView {
    // Adding blur effect with image assigned
    func addBlurredBackground() {
        guard let image = self.image else {
            return
        }
        self.removeAllSublayers()
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let backgroundImageView = UIImageView(image: image)
        backgroundImageView.contentMode = .scaleAspectFit
        backgroundImageView.frame = self.bounds
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurView)
        self.sendSubviewToBack(blurView)
    }
    
    // Adding color as image
    func imageWithColor(color: UIColor) {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.alpha = 0.5
        self.image = image!
    }
}

//MARK: Document Preview
import WebKit

//extension UIView {
//    func displayDocument(withURL url: URL) {
//        let webView = WKWebView(frame: bounds)
//        addSubview(webView)
//        webView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            webView.topAnchor.constraint(equalTo: topAnchor),
//            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//
//        let request = URLRequest(url: url)
////        URLCache.shared.removeAllCachedResponses()
//        webView.load(request)
//    }
//}

import UIKit
import WebKit

import UIKit
import WebKit

extension UIView {
    func displayDocument(withURL url: URL) {
        let webView = WKWebView(frame: bounds)
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Create the activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = webView.center
        addSubview(activityIndicator)
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        // Show the activity indicator when the web view starts loading
        activityIndicator.startAnimating()
        
        // Set up the web view's navigation delegate
        webView.navigationDelegate = self
        
        // Save the activity indicator as an associated object for later use in navigation delegate methods
        objc_setAssociatedObject(webView, &AssociatedKeys.activityIndicator, activityIndicator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// Associated key for storing the activity indicator as an associated object
private struct AssociatedKeys {
    static var activityIndicator = "activityIndicator"
}

// WKNavigationDelegate implementation for the activity indicator
extension UIView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Hide the activity indicator when the web view finishes loading
        if let activityIndicator = objc_getAssociatedObject(webView, &AssociatedKeys.activityIndicator) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // Hide the activity indicator in case of failure
        if let activityIndicator = objc_getAssociatedObject(webView, &AssociatedKeys.activityIndicator) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
}

struct scrollText:Equatable{
    let bold:String
    let normal:String
    var id : String = "dummyId"
}
// Text Auto scroll extension
extension UIView {
    func addDashedBorder(color: UIColor, width: CGFloat, dashPattern: [NSNumber], cornerRadius: CGFloat? = nil) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = width
        shapeLayer.lineDashPattern = dashPattern
        shapeLayer.fillColor = nil
        shapeLayer.name = "border"
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius ?? layer.cornerRadius)
        shapeLayer.path = path.cgPath
        layer.addSublayer(shapeLayer)
    }
    func applyShadow(color: UIColor, alpha: Float, x: CGFloat, y: CGFloat, blur: CGFloat, spread: CGFloat) {
        layer.name = "color"
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = alpha
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowRadius = blur / UIScreen.main.scale
        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
  
    //Wall messages animation
    //    func setupInfiniteHorizontalScrollingLabels(withData data: [scrollText], scrollSpeed: CGFloat) {
    //        DispatchQueue.main.async {
    //            // Remove any existing UIScrollView from the subviews
    //            for subview in self.subviews {
    //                if subview is UIScrollView {
    //                    subview.removeFromSuperview()
    //                }
    //            }
    //
    //            let scrollView = UIScrollView()
    //            scrollView.clipsToBounds = true
    //            scrollView.frame = self.bounds
    //            scrollView.backgroundColor = .clear
    //            var currentIndex = 0
    //            var totalWidth: CGFloat = 0
    //
    //            for (index, item) in data.enumerated() {
    //                let label = UILabel()
    //                label.backgroundColor = .clear
    //
    //                // Create attributed string with bold and normal attributes
    //                let attributedString = NSMutableAttributedString()
    //                let boldText = NSAttributedString(string: item.bold, attributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
    //                let normalText = NSAttributedString(string: item.normal, attributes: [.font: UIFont.systemFont(ofSize: 16)])
    //                attributedString.append(boldText)
    //                attributedString.append(normalText)
    //
    //                label.attributedText = attributedString
    //
    //                label.sizeToFit()
    //                // Position each label horizontally
    //                label.frame.origin.x = totalWidth
    //                label.frame.size.height = scrollView.frame.size.height
    //                label.contentMode = .left
    //                label.clipsToBounds = true  // Ensure no extra space is shown between labels
    //                print("scrollView.addSubview1")
    //                scrollView.addSubview(label)
    //                totalWidth += label.frame.size.width
    //            }
    //
    //            // Duplicate labels for seamless looping effect
    //            for (_, item) in data.enumerated() {
    //                let label = UILabel()
    //                label.backgroundColor = .clear
    //
    //                // Create attributed string with bold and normal attributes
    //                let attributedString = NSMutableAttributedString()
    //                let boldText = NSAttributedString(string: item.bold, attributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
    //                let normalText = NSAttributedString(string: item.normal, attributes: [.font: UIFont.systemFont(ofSize: 16)])
    //                attributedString.append(boldText)
    //                attributedString.append(normalText)
    //
    //                label.attributedText = attributedString
    //
    //                label.sizeToFit()
    //
    //                // Position each duplicated label after the original labels
    //                label.frame.origin.x = totalWidth
    //                label.frame.size.height = scrollView.frame.size.height
    //                label.contentMode = .left
    //                label.clipsToBounds = true
    //                print("scrollView.addSubview2")
    //                scrollView.addSubview(label)
    //                totalWidth += label.frame.size.width
    //            }
    //
    //            // Set up the content size based on the total width of labels
    //            scrollView.contentSize = CGSize(width: totalWidth * 2, height: scrollView.frame.size.height)
    //
    //            // Optionally, you can enable scrolling in the horizontal direction
    //            scrollView.showsHorizontalScrollIndicator = false
    //            scrollView.isPagingEnabled = true
    //            scrollView.contentInset = UIEdgeInsets.zero  // Set contentInset to zero to remove extra spacing
    //
    //            // Set up continuous horizontal scrolling
    //            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
    //                let newOffset = CGPoint(x: scrollView.contentOffset.x + scrollSpeed, y: 0)
    //
    //                if newOffset.x > totalWidth {
    //                    // Reset to the beginning for infinite loop effect
    //                    scrollView.contentOffset = CGPoint(x: 0, y: 0)
    //                } else {
    //                    UIView.animate(withDuration: 0.01, delay: 0, options: .curveLinear, animations: {
    //                        scrollView.contentOffset = newOffset
    //                    }, completion: nil)
    //                }
    //            }
    //            self.addSubview(scrollView)
    //        }
    //    }
    
    //    func setupInfiniteVerticalScrollingLabels(withData data: [scrollText], scrollSpeed: CGFloat, delayBetweenObjects: TimeInterval) {
    //        DispatchQueue.main.async {
    //            // Remove any existing UIScrollView from the subviews
    //            for subview in self.subviews {
    //                if subview is UIScrollView {
    //                    subview.removeFromSuperview()
    //                }
    //            }
    //
    //            let scrollView = UIScrollView()
    //            scrollView.clipsToBounds = true
    //            scrollView.frame = self.bounds
    //            scrollView.backgroundColor = .clear
    //
    //            for (_, item) in data.enumerated() {
    //                let label = UILabel()
    //                label.backgroundColor = .clear
    //
    //                // Create attributed string with bold and normal attributes
    //                let attributedString = NSMutableAttributedString()
    //                let boldText = NSAttributedString(string: item.bold, attributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
    //                let normalText = NSAttributedString(string: item.normal, attributes: [.font: UIFont.systemFont(ofSize: 16)])
    //                attributedString.append(boldText)
    //                attributedString.append(normalText)
    //
    //                label.attributedText = attributedString
    //
    //                label.frame = CGRect(x: 0, y: scrollView.contentSize.height, width: scrollView.frame.width, height: scrollView.frame.height)
    //                label.contentMode = .topLeft
    //                label.clipsToBounds = true
    //                scrollView.addSubview(label)
    //                scrollView.contentSize.height += scrollView.frame.height
    //            }
    //
    //            // Optionally, you can enable scrolling in the vertical direction
    //            scrollView.showsVerticalScrollIndicator = false
    //            scrollView.isPagingEnabled = true
    //            scrollView.contentInset = UIEdgeInsets.zero  // Set contentInset to zero to remove extra spacing
    //
    //            // Set up continuous vertical scrolling
    //            var currentIndex = 0
    //            let timer = Timer.scheduledTimer(withTimeInterval: delayBetweenObjects, repeats: true) { timer in
    //                let newOffset = CGPoint(x: 0, y: CGFloat(currentIndex) * scrollView.frame.height)
    //
    //                UIView.animate(withDuration: 0.5) {
    //                    scrollView.contentOffset = newOffset
    //                }
    //
    //                currentIndex = (currentIndex + 1) % data.count
    //            }
    //            RunLoop.current.add(timer, forMode: .common)
    //            
    //            self.addSubview(scrollView)
    //        }
    //    }
    
}
