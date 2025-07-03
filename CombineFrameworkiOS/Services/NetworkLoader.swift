/*
 CryptoDataLoader.swift
 
 A Singleton used to fetch the data
 through the API and decode it.
 
 Created by Cristina Dobson
 */


import Foundation
import Combine
import UIKit

class NetworkLoader: NetworkService {
    
    // MARK: - Properties
    static let shared         = NetworkLoader()
    private let urlSession    = URLSession.shared
    private var subscriptions = Set<AnyCancellable>()
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        return jsonDecoder
    }()
    
    // MARK: - Init method
    private init() {}
    
    // MARK: - Create Endpoint
    private func createURL(with endpoint: String) -> URL? {
        guard let urlComponents = URLComponents(string: "\(baseurl)\(endpoint)")
        else { return nil }
        return urlComponents.url
    }
    
    // MARK: - Login protocol
    func login<T: Codable>(from endpoint: String) -> Future<T, APIError> {
        
        // Initialize and return Future
        return Future<T, APIError> { [unowned self] promise in
            guard let url = self.createURL(with: endpoint)
            else {
                return promise(.failure(.badRequest))
            }
            
            // Start fetching the data
            self.urlSession.dataTaskPublisher(for: url)
            /*
             Check that the http response status code
             is between 200 and 299.
             */
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          200...299 ~= httpResponse.statusCode
                    else {
                        throw APIError.responseError(
                            (response as? HTTPURLResponse)?.statusCode ?? 500)
                    }
                    return data
                }
            /*
             Decode the published JSON data into the CryptoMarket model
             */
                .decode(type: T.self,
                        decoder: self.jsonDecoder)
            /*
             Make sure completion runs on the main thread
             */
                .receive(on: RunLoop.main)
            /*
             Subscribe to receive a value
             */
                .sink { completion in
                    if case let .failure(error) = completion {
                        switch error {
                        case let urlError as URLError:
                            promise(.failure(.badRequest))
                        case let decodingError as DecodingError:
                            promise(.failure(.decodingError(decodingError)))
                        case let apiError as APIError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(.anyError))
                        }
                    }
                }
            receiveValue: {
                promise(.success($0))
            }
            /*
             Make sure the subscription still works after
             the execution is finished.
             */
            .store(in: &self.subscriptions)
            
        }
    }
    
    func postApiRequest<T: Decodable, U : Encodable>(
        endPoint: Endpoint,
        method: HTTPMethod,
        token:String,
        body: U?,
        responseType: T.Type
    ) -> Future<T, APIError> {
        return Future<T, APIError> { [unowned self] promise in
            guard let url = self.createURL(with: endPoint.rawValue)
            else {
                return promise(.failure(.badRequest))
            }
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(token, forHTTPHeaderField: "Authorization")
            if let body = body {
                do {
                    request.httpBody = try JSONEncoder().encode(body)
                } catch {
                    return
                }
            }
            PrintLogger.log(type: .apiUrl, message: url.absoluteString)
            PrintLogger.modelLog(body, type: .inputParamenters)
            self.urlSession.dataTaskPublisher(for: request)
                .tryMap { result -> Data in
                    guard let httpResponse = result.response as? HTTPURLResponse else {
                        throw APIError.responseError(-1)
                    }
                    switch httpResponse.statusCode {
                    case 200...299:
                        return result.data // success
                    case 401:
                        throw APIError.unauthorized
                    case 500...599:
                        throw APIError.serverError(code: httpResponse.statusCode, message: httpResponse.debugDescription)
                    default:
                        throw APIError.unknown(httpResponse.statusCode)
                    }
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case let .failure(error) = completion {
                        switch error {
                        case let urlError as URLError:
                            promise(.failure(.badRequest))
                        case let decodingError as DecodingError:
                            promise(.failure(.decodingError(decodingError)))
                        case let apiError as APIError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(.anyError))
                        }
                    }
                }
            receiveValue: {
                promise(.success($0))
            }
            .store(in: &self.subscriptions)
        }
    }
}

////MARK: - Reachability
//extension NetworkLoader{
//    private func isInternetAvailable() -> Bool {
//        guard let reachability = try? Reachability() else {
//            return false
//        }
//        return reachability.connection != .unavailable
//    }
//}
