//
//  LogoutModel.swift
//  CombineFrameworkiOS
//
//  Created by KSMACMINI-019 on 02/07/25.
//

import Foundation
public struct LogoutRequest: Codable {
    let userId: String
}

public struct LogoutResponse: Codable {
    let message: String
}
