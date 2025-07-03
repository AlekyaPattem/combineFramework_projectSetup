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
        setupBindings()
    }
    
    @IBAction func getCountriesBtnActn(_ sender: Any) {
        getCountriesApi()
    }
    
    @IBAction func loginBtnActn(_ sender: Any) {
        loginApi()
    }
    
    @IBAction func logoutBtnActn(_ sender: Any) {
        logoutApi()
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
    
    func setupBindings() {
        loginVM.$loginResponse.sink {response in
        }.store(in: &cancellables)
        
        loginVM.$getCountriesResponse.sink{
            response in
        }.store(in: &cancellables)
    }
}
