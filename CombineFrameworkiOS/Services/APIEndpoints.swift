import Foundation
import UIKit
import Combine

let baseurl         = "https://devfindingmynirvana.krify.com/api/"
let defaultAuthKey  = "VJ06gLh8UtPVVviwsVzeSYPSbsmbI2MVWcfPqAfoiq8yhBDewoKWtqJE0Hy8zOVa"

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH
}

enum Endpoint: String {
    case login                          = "userLogin"
    case getCountryCodes                = "getCountryodes"
    case regenerateAccessToken          = "regenerateAccessToken"
    case logout                         = "logout"
}

var authKey: String {
    get {
//        print("access Token: - Bearer \(Constants.getUserDefaultsValue(for: Constants.authKey))")
        return "Bearer \(Constants.getUserDefaultsValue(for: Constants.authKey))"
    }
}
