
public struct LoginRequest: Codable {
  let emailMobile : String
  let countryCode : String
  let password    : String
  let deviceId    : String
  let platform    : Int
  let pushMode    : Int?
  let uniqueId  : String
  public init(
    emailMobile: String,countryCode:String, password: String, deviceId: String, platform: Int,pushMode: Int,uniqueId:String) {
      self.emailMobile   = emailMobile
      self.countryCode   = countryCode
      self.password      = password
      self.deviceId      = deviceId
      self.platform      = platform
      self.pushMode      = pushMode
      self.uniqueId      = uniqueId
    }
}

public struct LoginResponse: Codable {
    var message: String?
    var data: LoginResponseData?
}


public struct LoginResponseData: Codable {
  var userId                    : String?
  var accessToken               : String?
  var refreshToken              : String?
  var emailVerificationStatus   : Bool?
  var mobileVerificationStatus  : Bool?
  var name                      : String?
  var email                     : String?
  var countryCode               : String?
  var mobile                    : String?
  var gender                    : Int?
  var subscriptionId            : String?
  var profileStatus             : Bool?
  var sunsign                   : String?
  var birthDate                 : String?
  var birthPlace                : String?
  var profile                   : String?
  var blockStatus               : Bool?
  public init(
    userId                      : String? = nil,
    accessToken                 : String? = nil,
    refreshToken                : String? = nil,
    emailVerificationStatus     : Bool? = nil,
    mobileVerificationStatus    : Bool? = nil,
    name                        : String? = nil,
    email                       : String? = nil,
    countryCode                 : String? = nil,
    mobile                      : String? = nil,
    gender                      : Int?  = 0,
    subscriptionId              : String? = nil,
    profileStatus               : Bool? = nil,
    sunsign                     : String? = nil,
    profile                     : String? = nil,
    birthDate                   : String? = nil,
    birthPlace                  : String? = nil,
    blockStatus                 : Bool? = nil
  ) {
    self.userId                     = userId
    self.accessToken                = accessToken
    self.refreshToken               = refreshToken
    self.emailVerificationStatus    = emailVerificationStatus
    self.mobileVerificationStatus   = mobileVerificationStatus
    self.name                       = name
    self.email                      = email
    self.countryCode                = countryCode
    self.mobile                     = mobile
    self.gender                     = gender
    self.subscriptionId             = subscriptionId
    self.profileStatus              = profileStatus
    self.sunsign                    = sunsign
    self.profile                    = profile
    self.birthDate                  = birthDate
    self.birthPlace                 = birthPlace
    self.blockStatus                = blockStatus
  }
}




