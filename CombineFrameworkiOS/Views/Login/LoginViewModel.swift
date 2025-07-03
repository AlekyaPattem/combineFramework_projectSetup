//
//  LoginVM.swift
//  CombineFrameworkiOS
//
//  Created by KSMACMINI-019 on 01/07/25.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    
    private var subscriptions           = Set<AnyCancellable>()
    var apiReference                    = NetworkRequest.shared
    @Published var loginResponse        : LoginResponse?
    @Published var getCountriesResponse : GetCountriesResponse?
    //    @Published var profileImageResponse : UpdateProfileImageResponse?
    var profileImageResponse = CurrentValueSubject<UpdateProfileImageResponse?,Never>(nil)
    
    var profile = CurrentValueSubject<String,Never>("alekyasjkf")
    //    var profile = CurrentValueSubject<String?,Never>(nil)
    var name = PassthroughSubject<String,Never>()
    //    var name = PassthroughSubject<String?,Never>()
    
    func login(input:LoginRequest) {
        apiReference.postApi(endPoint: Endpoint.login, method: .POST,token: defaultAuthKey,body: input,showLoader: true, responseType: LoginResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: Endpoint.login)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            Constants.saveDefaults(value: response.data?.accessToken, key: Constants.authKey)
            Constants.saveDefaults(value: response.data?.refreshToken, key: Constants.refreshKey)
            Constants.saveDefaults(value: response.data?.userId, key: Constants.userId)
            self.loginResponse = response
        }
        .store(in: &self.subscriptions)
    }
    
    func getCountries() {
        apiReference.getApi(endPoint: Endpoint.getCountryCodes, token: defaultAuthKey, showLoader: true, responseType: GetCountriesResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: Endpoint.getCountryCodes)
                }
            }
        receiveValue: { [unowned self] in
            PrintLogger.modelLog($0, type: .response, isInput: false)
            self.getCountriesResponse = $0
        }
        .store(in: &self.subscriptions)
    }
    
    func logout(input:LogoutRequest) {
        apiReference.postApi(endPoint: Endpoint.logout, method: .POST,token: authKey,body: input,showLoader: true, responseType: LogoutResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: Endpoint.logout)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            Constants.resetDefaults()
        }
        .store(in: &self.subscriptions)
    }
    
    func uploadImagePic(input:UpdateProfileImageRequest,fileData:[MultiPartFileInput]){
        apiReference.postMultipartApi(endPoint: Endpoint.updateProfileImage, method: .POST,token: authKey,body: MultipartInput(parameters: input, fileInput: fileData),showLoader: true, responseType: UpdateProfileImageResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: Endpoint.updateProfileImage)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            //                profileImageResponse = response
            profileImageResponse.send(response)
        }
        .store(in: &self.subscriptions)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : Endpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
