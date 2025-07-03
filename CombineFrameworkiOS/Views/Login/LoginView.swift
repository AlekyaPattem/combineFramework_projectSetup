//
//  ViewController.swift
//  CombineFrameworkiOS
//
//  Created by KSMACMINI-019 on 21/03/25.
//

import UIKit
import Combine

class LoginView: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    private var loginVM = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginApi()
        setupBindings()
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
    
    func setupBindings() {
        loginVM.$loginResponse.sink { [self] response in
        }.store(in: &cancellables)
    }
}
