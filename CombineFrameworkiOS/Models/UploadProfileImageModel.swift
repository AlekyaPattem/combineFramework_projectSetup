//
//  UploadProfileImageModel.swift
//  CombineFrameworkiOS
//
//  Created by KSMACMINI-019 on 03/07/25.
//

import Foundation

public struct UpdateProfileImageRequest: Codable {
    let userId  : String
    enum CodingKeys: String, CodingKey {
        case userId
    }
}
public struct UpdateProfileImageResponse: Codable {
    let message     : String?
    let data        : UpdateProfileImageResponseData?
}

public struct UpdateProfileImageResponseData: Codable {
    let profile: String?
    public init(
        profile : String?
    ) {
      self.profile  = profile
    }
}
