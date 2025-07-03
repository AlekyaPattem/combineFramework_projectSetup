//
//  GetCountriesModel.swift
//  CombineFrameworkiOS
//
//  Created by KSMACMINI-019 on 02/07/25.
//

import Foundation
public struct GetCountriesResponse: Codable {
    let message : String?
    let data    : [GetCountriesData]?
}

public struct GetCountriesData: Codable {
    var id      : Int? = nil
    var name    : String? = nil
    var code    : String? = nil
    var flag    : String? = nil
}
