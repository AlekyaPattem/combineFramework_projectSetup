/*
 CryptoService.swift
 
 The service to decode any type
 of JSON format.
 
 Created by Cristina Dobson
 */


import Foundation
import Combine

protocol NetworkService {
    func login<T: Codable>(from endpoint: String) -> Future<T, APIError>
}

let baseurl         = "https://devfindingmynirvana.krify.com/api/"
let defaultAuthKey  = "VJ06gLh8UtPVVviwsVzeSYPSbsmbI2MVWcfPqAfoiq8yhBDewoKWtqJE0Hy8zOVa"

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH
}

enum Endpoint: String {
    case login               = "userLogin"
}

public struct ResponseContainer<T: Codable>: Codable {
  public let status: Int?
  public let message: String?
  public let data: T?
  public init(data: T?, message: String?, status: Int?) {
    self.data = data
    self.message = message
    self.status = status
  }
}
