//
//  LoginVM.swift
//  CombineFrameworkiOS
//
//  Created by KSMACMINI-019 on 01/07/25.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    
    private var subscriptions       = Set<AnyCancellable>()
    var apiReference                = NetworkLoader.shared
    @Published var loginResponse    : LoginResponse?
    
    func login(input:LoginRequest) {
        apiReference.postApiRequest(endPoint: Endpoint.login, method: .POST,token: defaultAuthKey,body: input, responseType: LoginResponse.self)
            .sink { [unowned self] completion in
              if case let .failure(error) = completion {
                self.handleError(error)
              }
            }
            receiveValue: { [unowned self] in
                PrintLogger.modelLog($0, type: .response, isInput: false)
                self.loginResponse = $0
            }
            .store(in: &self.subscriptions)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError) {
      print("ERROR: \(apiError.localizedDescription)!!!!!")
    }
}
