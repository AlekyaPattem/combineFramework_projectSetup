//
//  ViewController.swift
//  CombineFrameworkiOS
//
//  Created by KSMACMINI-019 on 21/03/25.
//

import UIKit
import Combine
import SDWebImage

class LoginView: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var profileImgView: UIImageView!
    
    //MARK: - Variables
    private var cancellables    = Set<AnyCancellable>()
    private var loginVM         = LoginViewModel()
    var imagePicker             = UIImagePickerController.init()
    
    //MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        loginVM.name.send("Alekya Pattem")
        //        loginVM.name.send(nil)
        deviceOrientation()
    }
    
    //MARK: - User defined methods
    func setupBindings() {
        loginVM.$loginResponse.sink {response in
            guard response != nil else {
                return
            }
        }.store(in: &cancellables)
        
        loginVM.$getCountriesResponse.sink{
            response in
            guard let response = response else {
                return
            }
        }.store(in: &cancellables)
        
        //        loginVM.$profileImageResponse
        //            .compactMap{ $0 }
        //            .sink{
        //                response in
        //                self.profileImgView.sd_setImage(with: URL(string: response.data?.profile ?? ""))
        //            }.store(in: &cancellables)
        
        loginVM.profileImageResponse
            .compactMap{ $0 }
            .sink{
                response in
                self.profileImgView.sd_setImage(with: URL(string: response.data?.profile ?? ""))
            }.store(in: &cancellables)
        
        
        loginVM.profile
        //            .compactMap{ $0 }
            .sink{
                response in
                //                guard let response = response else {
                //                    return
                //                }
                print("Prfile \(response)")
            }.store(in: &cancellables)
        
        loginVM.name
        //            .compactMap{ $0 }
            .sink { response in
                //                guard let response = response else {
                //                    return
                //                }
                print("name is\(response)")
            }.store(in: &cancellables)
    }
    
    @objc func changeProfileTapped() {
        let alertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        let alertSheet1 = UIAlertAction(title: "Camera", style: .default){ [self]_ in
            self.imagePicker.allowsEditing  = true
            self.imagePicker.sourceType     = .camera
            self.imagePicker.delegate       = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            self.present(self.imagePicker, animated: true)
        }
        let alertSheet2 = UIAlertAction(title: "Gallery", style: .default){ [self]_ in
            self.imagePicker.allowsEditing  = true
            self.imagePicker.sourceType     = .photoLibrary
            self.imagePicker.delegate       = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            self.present(self.imagePicker, animated: true)
        }
        let alertSheet3 = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(alertSheet1)
        alertController.addAction(alertSheet2)
        alertController.addAction(alertSheet3)
        self.present(alertController, animated: true)
    }
    
    func getCountriesApi(){
        loginVM.getCountries()
    }
    
    func loginApi(){
        let input = LoginRequest(emailMobile: "tiya@krify.com",
                                 countryCode: "+91",
                                 password: "Krify@123",
                                 deviceId: "1234",
                                 platform: 1,
                                 pushMode: 1,
                                 uniqueId: "1234")
        loginVM.login(input: input)
    }
    
    func logoutApi(){
        let input = LogoutRequest(userId: Constants.getUserId())
        loginVM.logout(input: input)
    }
    
    func uploadProfileImageApi(data:Data?){
        let input = UpdateProfileImageRequest(userId: Constants.getUserId())
        loginVM.uploadImagePic(input: input, fileData: [MultiPartFileInput(
            fieldName   : "profile",
            fileName    : "profile",
            mimeType    : "image/jpeg",
            fileData    : data ?? Data()
        )])
    }
    
    func deviceOrientation(){
        NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
        //                .filter() { _ in UIDevice.current.orientation == .portrait }
            .sink() { _ in
                switch (UIDevice.current.orientation){
                case .portrait :
                    print("potrait")
                case .portraitUpsideDown:
                    print("potrait upside down")
                case .landscapeLeft:
                    print( "landscape left")
                case .landscapeRight:
                    print( "landscape right")
                default:
                    print("unknown")
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Button Actions
    @IBAction func getCountriesBtnActn(_ sender: Any) {
        getCountriesApi()
    }
    
    @IBAction func loginBtnActn(_ sender: Any) {
        loginApi()
    }
    
    @IBAction func uploadImageBtnActn(_ sender: Any) {
        changeProfileTapped()
    }
    
    @IBAction func logoutBtnActn(_ sender: Any) {
        logoutApi()
    }
}

// MARK: - UIImagePickerControllerDelegate Methods
extension LoginView : UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Get image and file URL
        guard let image = info[.editedImage] as? UIImage else {
            print("Invalid image.")
            return
        }
        if let imageURL = info[.imageURL] as? URL {
            // Check allowed file types
            let allowedExtensions = ["jpg", "jpeg", "png", "heic"]
            let fileExtension = imageURL.pathExtension.lowercased()
            guard allowedExtensions.contains(fileExtension) else {
                showSnakbarMsg(message: "Only JPG, PNG, or HEIC files accepted. Convert and retry.", typeofMsg: .error)
                return
            }
            
            // Check file size
            if let fileSize = try? FileManager.default.attributesOfItem(atPath: imageURL.path)[.size] as? NSNumber {
                let sizeInMB = Double(truncating: fileSize) / (1024 * 1024)
                guard sizeInMB <= 10 else {
                    showSnakbarMsg(message: "Image must be under 10MB. Compress or choose another file.", typeofMsg: .error)
                    return
                }
            }
        }
        if let selectedImage = info[.editedImage] as? UIImage {
            uploadProfileImageApi(data: selectedImage.jpegData(compressionQuality: 1.0) ?? Data())
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
