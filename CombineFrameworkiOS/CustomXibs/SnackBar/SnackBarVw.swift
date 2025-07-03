//
//  SnackBarVw.swift
//  Your moca
//
//  Created by KSMACMINI-016 on 31/10/23.
//

import UIKit

class SnackBarVw: UIView {
    
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var parentVw: UIView!
    @IBOutlet weak var imgVw1: UIImageView!
    @IBOutlet weak var mesgLabel: UILabel!
    
    func loadingDefaultUI(typeofMsg : SnackBarType)
    {
        parentVw.clipsToBounds = true
        parentVw.layer.cornerRadius = parentVw.height/2
        parentVw.layer.shadowOffset = CGSize(width: 0, height: 3)
        parentVw.layer.shadowOpacity = 0.8
        parentVw.layer.shadowRadius = 3.0
        parentVw.layer.shadowColor = UIColor.darkGray.cgColor
        imgVw1.isHidden = true
        imgVw.isHidden = true//false
        mesgLabel.textAlignment = .center
        mesgLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)//.appBoldFont(ofSize: 16))
        switch typeofMsg {
        case .warning:
            self.parentVw.backgroundColor = #colorLiteral(red: 1, green: 0.5961, blue: 0.1961, alpha: 1)
            self.imgVw.image = UIImage.init(named: "warning")
            self.imgVw1.image = UIImage.init(named: "warning")
        case .info:
            self.parentVw.backgroundColor = #colorLiteral(red: 0, green: 0.6039, blue: 0.9255, alpha: 1)
            self.imgVw.image = UIImage.init(named: "info")?.withRenderingMode(.alwaysTemplate)
            self.imgVw.tintColor = UIColor.white
            self.imgVw1.image = UIImage.init(named: "info")?.withRenderingMode(.alwaysTemplate)
            self.imgVw1.tintColor = UIColor.white
        case .success:
            self.parentVw.backgroundColor = #colorLiteral(red: 0.2431, green: 0.6784, blue: 0.3569, alpha: 1)
            self.imgVw.image = UIImage.init(named: "success")
            self.imgVw1.image = UIImage.init(named: "success")
        case .error:
            self.parentVw.backgroundColor = #colorLiteral(red: 0.9765, green: 0.2431, blue: 0.2275, alpha: 1)
            self.imgVw.image = UIImage.init(named: "info")?.withRenderingMode(.alwaysTemplate)
            self.imgVw.tintColor = UIColor.white
            self.imgVw1.image = UIImage.init(named: "info")?.withRenderingMode(.alwaysTemplate)
            self.imgVw1.tintColor = UIColor.white
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.height - self.parentVw.frame.height , width: UIScreen.main.bounds.width, height: self.parentVw.frame.height)
    }
}
