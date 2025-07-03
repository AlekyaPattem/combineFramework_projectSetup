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
    case getCountryCodes                = "getCountryCodes"
    case regenerateAccessToken          = "regenerateAccessToken"
    case logout                         = "logout"
    case updateProfileImage             = "updateProfileImage"
}

var authKey: String {
    get {
        return "Bearer \(Constants.getUserDefaultsValue(for: Constants.authKey))"
    }
}
