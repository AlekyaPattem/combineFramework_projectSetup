//
//  ViewController.swift
//  CombineFrameworkiOS
//
//  Created by KSMACMINI-019 on 21/03/25.
//

import UIKit
import Combine
import SDWebImage

extension Notification.Name {
    static let myNotification = Notification.Name("myNotification")
    static let userLoggedIn = Notification.Name("userLoggedIn")
}

struct User : Codable {
    var id: Int
    var name: String
}

class LoginView: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var profileImgView: UIImageView!
    
    //MARK: - Variables
    private var cancellables    = Set<AnyCancellable>()
    private var loginVM         = LoginViewModel()
    var imagePicker             = UIImagePickerController.init()
    var timer                   : Timer?
    var secondsLeft             = 10
    var timerCancellable        : AnyCancellable?
    
    //MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        loginVM.name.send("Alekya Pattem")
        
        loginVM.name.send(nil) //nil case
        
        deviceOrientation()
        
        notificationCenterExample()
        NotificationCenter.default.post(name: .myNotification, object: nil)
        
        notificationCenterObjectExample()
        let user = User(id: 101, name: "Alekhya")
        NotificationCenter.default.post(name: .userLoggedIn, object: user)
        
        notificationCenterUserInfoExample()
        NotificationCenter.default.post(
            name: .userLoggedIn,
            object: nil,
            userInfo: ["user": user]
        )
        
        NotificationCenter.default.post(
            name: .userLoggedIn,
            object: nil,
            userInfo: [
                "username": "alekhya",
                "age": 25
            ]
        )
    }
    
    //MARK: - User defined methods
    func setupBindings() {
        loginVM.$loginResponse.sink {response in
            guard response != nil else {
                return
            }
            print("login response")
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
                print("profileImageResponse")
                self.profileImgView.sd_setImage(with: URL(string: response.data?.profile ?? ""))
            }.store(in: &cancellables)
        
        
        loginVM.profile
        //            .compactMap{ $0 } //will only get non-nil values
            .sink{
                response in
                //                guard let response = response else {
                //                    return
                //                }
                print("Prfile \(response)")
            }.store(in: &cancellables)
        
        loginVM.name
//                    .compactMap{ $0 }
//            .filter { !$0.isEmpty }
            .sink { response in
//                                guard let response = response else { //“If response is not nil, unwrap it into a non-optional response and continue.But if it is nil, then exit the current block (with return).”
//                                    return
//                                }
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
    
    func notificationCenterExample(){
        NotificationCenter.default
            .publisher(for: .myNotification)
            .sink { notification in
                print("Received Notification via Combine:")
            }.store(in: &cancellables)
    }
    
    func notificationCenterObjectExample(){
        NotificationCenter.default
            .publisher(for: .userLoggedIn)
            .compactMap { $0.object as? User } // cast the object
            .sink { user in
//                let userss = user.object as? User
//                guard let users = userss else { return }
                print("Received user via Combine object: \(user.name), id: \(user.id)")
            }.store(in: &cancellables)
    }
    
    func notificationCenterUserInfoExample(){
        NotificationCenter.default
            .publisher(for: .userLoggedIn)
            .compactMap { $0.userInfo?["user"] as? User }
            .sink { user in
                print("Received user via Combine user info: \(user.name), id: \(user.id)")
            }
            .store(in: &cancellables)
        
            NotificationCenter.default
                .publisher(for: .userLoggedIn)
                .sink { notification in
                    if let userInfo = notification.userInfo,
                       let username = userInfo["username"] as? String,
                       let age = userInfo["age"] as? Int {
                        print("Received: username = \(username), age = \(age)")
                    } else {
                        print("Invalid or missing data")
                    }
                }.store(in: &cancellables)
    }
    
    func traditionalNC(){
//        NotificationCenter.default.post(name: Notification.Name("orders"), object: nil, userInfo: ["orderObj": orderObj, "notificationType": 0])
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "chefSpecial"), object: nil)
//        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "chefSpecial"), object: nil, queue: nil) { notification in
//            if let order = notification.userInfo?["orderObj"] as? String {
//                self.selectedId = order
//                self.initialSetup()
//                self.filterBtnStatusSetup()
//            }
//        }
        
        
//        NotificationCenter.default.post(name: Notification.Name("chatClose"), object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "chatClose"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ChatRoomVC.onCloseBtnAction), name: NSNotification.Name(rawValue:"chatClose"), object: nil)
    }
    
    func startTraditionalTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            print("⏰ Traditional Timer fired at \(Date())")
        }
    }
    
    func startCombineTimer() {
        timerCancellable?.cancel()
        secondsLeft = 30
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.secondsLeft > 0 {
                    self.secondsLeft -= 1
                    print("seconds - \(self.secondsLeft)")
                } else {
                    print("⏰ Countdown finished!")
                    timerCancellable?.cancel()
                }
            }
    }
    
    //MARK: - Button Actions
    @IBAction func getCountriesBtnActn(_ sender: Any) {
        getCountriesApi()
    }
    
    @IBAction func loginBtnActn(_ sender: Any) {
//        loginApi()
//        startTraditionalTimer()
//        timer?.invalidate()
        startCombineTimer()
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
