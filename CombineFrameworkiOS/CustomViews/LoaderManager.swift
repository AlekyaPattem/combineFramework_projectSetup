import UIKit
import JGProgressHUD
import Lottie

class LoaderManager: UIView {
    
    static let shared = LoaderManager()
    var animationView = LottieAnimationView()
    var loaderView    = UIView()
    
    lazy var transparentView: UIView = {
        var frm = CGRect()
        if !DeviceType.shared.isIphone(){
            print(UIDeviceOrientation.landscapeLeft)
            if DeviceType.shared.isIpadLandscape() {
                if UIScreen.main.bounds.height > UIScreen.main.bounds.width{
                    frm = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
                }else{
                    frm = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                }
            }else{
                if UIScreen.main.bounds.height > UIScreen.main.bounds.width{
                    frm = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                }else{
                    frm = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
                }
            }
        }else{
            frm = UIScreen.main.bounds
        }
        let transparentView = UIView(frame: frm)
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        DispatchQueue.main.async {
            transparentView.isUserInteractionEnabled = true
        }
        return transparentView
    }()
    
    func loaderViewSetup(labelText: String){
        let loadView = UIView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 160,
                                            y: UIScreen.main.bounds.height/2 - 160,
                                            width: 160,
                                            height: 160))
        let loadingLabel    = UILabel(frame: CGRect(x: 0,
                                                    y: loadView.frame.height - 40,
                                                    width: loadView.frame.width,
                                                    height: 50))
        let loadingImg = UIImageView()
        loadingImg.frame            = CGRect(x: loadView.frame.width/2 - 75,
                                             y: 0,
                                             width: 150,
                                             height: 150)
        //        loadView.layer.cornerRadius             = 20
        //        loadView.backgroundColor                = .clear
        loadingLabel.numberOfLines              = 0
        if !labelText.isEmpty || labelText != ""{
            loadingLabel.text                   = labelText
        }else{
            loadingLabel.text                   = ""
        }
        loadingLabel.font                       = UIFont.systemFont(ofSize: 15)//.appBoldFont(ofSize: 15)
        loadingLabel.textColor                  = UIColor.gray
        loadingLabel.textAlignment              = .center
        animationView.removeFromSuperview()
        animationView                           = .init(name: "splash")
        animationView.frame                     = loadingImg.bounds
        animationView.loopMode                  = .loop
        loadingImg.addSubview(animationView)
        loadView.addSubview(loadingImg)
        loadView.addSubview(loadingLabel)
        animationView.play()
        loaderView = loadView
    }
    
    lazy var hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.vibrancyEnabled = true
        return hud
    }()
    
    func updateLoadingLabelText(_ newText: String) {
        guard let loadingLabel = loaderView.subviews.compactMap({ $0 as? UILabel }).first else {
            return // Ensure loadingLabel exists
        }
        loadingLabel.numberOfLines              = 0
        if showLabel == true{
            loadingLabel.text                   = "\(newText)\nUploaded"
        }else{
            loadingLabel.text                   = ""
        }
        loadingLabel.font                       = UIFont.systemFont(ofSize: 15)//.appBoldFont(ofSize: 15)
        loadingLabel.textColor                  = ColorConstants.gray
        loadingLabel.textAlignment              = .center
    }
    
    func transparentViewSetup(){
        var frm = CGRect()
        if !DeviceType.shared.isIphone(){
            print(UIDeviceOrientation.landscapeLeft)
            if DeviceType.shared.isIpadLandscape() {
                if UIScreen.main.bounds.height > UIScreen.main.bounds.width{
                    frm = CGRect(x: 0,
                                 y: 0,
                                 width: UIScreen.main.bounds.height,
                                 height: UIScreen.main.bounds.width)
                }else{
                    frm = CGRect(x: 0,
                                 y: 0,
                                 width: UIScreen.main.bounds.width,
                                 height: UIScreen.main.bounds.height)
                }
            }else{
                if UIScreen.main.bounds.height > UIScreen.main.bounds.width{
                    frm = CGRect(x: 0,
                                 y: 0,
                                 width: UIScreen.main.bounds.width,
                                 height: UIScreen.main.bounds.height)
                }else{
                    frm = CGRect(x: 0,
                                 y: 0,
                                 width: UIScreen.main.bounds.height,
                                 height: UIScreen.main.bounds.width)
                }
            }
            self.transparentView.frame = frm
        }
    }
    
    func showLoader(text:String = "") {
        
        DispatchQueue.main.async { [self] in
            loaderViewSetup(labelText: text)
            transparentViewSetup()
            transparentView.tag = 1
            UIWindow.key?.addSubview(self.transparentView)
            loaderView.center = self.transparentView.center
//            self.hud.show(in: loaderView)
            transparentView.addSubview(self.loaderView)
        }
//        DispatchQueue.main.async
//        {
//            SVProgressHUD.setDefaultStyle(.dark)
//            SVProgressHUD.setDefaultMaskType(.black)
//            print("startload - general")
//            SVProgressHUD.show()
//            self.hud.show(in: <#T##UIView#>)
//        }
    }
    
    func hideLoader() {
        DispatchQueue.main.async {
            self.transparentView.tag = 0
            self.transparentView.isUserInteractionEnabled = true
            self.transparentView.removeFromSuperview()
            self.loaderView.removeFromSuperview()
            DontHideLoader = false
//            self.hud.dismiss()
        }
//        DispatchQueue.main.async {
//            print("stopload - general")
//            SVProgressHUD.dismiss()
//        }
    }
}
