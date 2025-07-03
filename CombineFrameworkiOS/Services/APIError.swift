//
//  APIError.swift
//  RajaKiRani
//
//  Created by KS-MACIMINI-016 on 13/03/25.
//

import Foundation

/// Enum representing all types of API errors returned from requests supported by the application.
public enum APIError: Error {
    /// Error signaling undefined state of the request/response.
    case unknown(Int? = nil)
    case tokenRefreshed
    /// Request cancelled.
    case cancelled
    /// No internet connection.
    case noInternetConnection
    /// User has sent too many requests in a given amount of time.
    case tooManyRequests
    /// Server cannot or will not process the request due to an apparent client error.
    case badRequest
    /// Similar to 403 Forbidden, but specifically for use
    /// when authentication is required and has failed or has not yet been provided.
    case unauthorized
    /// Requested resource could not be found but may be available in the future.
    case notFound
    /// Server timed out waiting for the request.
    case requestTimeout
    /// Generic error message, given when an unexpected condition was encountered and no more specific message is suitable
    case internalServerError
    /// Server is currently unavailable (e.g. overloaded or down for maintenance).
    case serviceUnavailable
    /// Server was acting as a gateway or proxy and received an invalid response from the upstream server.
    case badGateway
    case refreshTokenFailed
    case serverError(code: Int, message: String)
    case urlError(URLError)
    case responseError(Int)
    case decodingError(DecodingError)
    case anyError
    
    var localizedDescription: String {
        switch self {
        case .urlError(let error):
            return error.localizedDescription
        case .decodingError(let error):
            return error.localizedDescription
        case .responseError(let error):
            return "Bad response code: \(error)"
        case .anyError:
            return "Unknown error has ocurred"
        case .unknown(_):
            return "Unknown error has ocurred"
        case .tokenRefreshed:
            return "tokenRefreshed"
        case .cancelled:
            return "cancelled"
        case .noInternetConnection:
            return "noInternetConnection"
        case .tooManyRequests:
            return "tooManyRequests"
        case .badRequest:
            return "badRequest"
        case .unauthorized:
            return "unauthorized 401"
        case .notFound:
            return "notFound"
        case .requestTimeout:
            return "requestTimeout"
        case .internalServerError:
            return "internalServerError"
        case .serviceUnavailable:
            return "serviceUnavailable"
        case .badGateway:
            return "badGateway"
        case .refreshTokenFailed:
            return "refreshTokenFailed"
        case .serverError(code: let code, message: let message):
            return "serverError: \(code): \(message)"
        }
    }
}
/// Allows to create `APIError` instance from a given status code.
extension APIError {
    // swiftlint:disable:next cyclomatic_complexity
    static func fromCode(_ statusCode: Int) -> APIError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 404: return .notFound
        case 408: return .requestTimeout
        case 429: return .tooManyRequests
        case 500: return .internalServerError
        case 502: return .badGateway
        case 503: return .serviceUnavailable
        case 25: return .cancelled
        case 15: return .noInternetConnection
        default: return .unknown(statusCode)
        }
    }
}
