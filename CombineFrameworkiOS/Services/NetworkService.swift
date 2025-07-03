import Foundation
import Combine
import UIKit
import Reachability

class NetworkService {
    
    // MARK: - Properties
    static let shared         = NetworkService()
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
    
    func regenerateAccessAPI() -> Future<Void, APIError> {
        return Future<Void, APIError> { promise in
            self.getApi(endPoint    : .regenerateAccessToken,
                        token       : Constants.getUserDefaultsValue(for: Constants.refreshKey),
                        showLoader  : false,
                        responseType: RefreshTokenResponse.self)
            .sink { completion in
                if case let .failure(error) = completion {
                    promise(.failure(error))
                }
            } receiveValue: { refreshData in
                print("new access - \(refreshData.data?.accessToken ?? "") \n new refresh - \(refreshData.data?.refreshToken ?? "")")
                Constants.saveDefaults(value: refreshData.data?.accessToken, key: Constants.authKey)
                Constants.saveDefaults(value: refreshData.data?.refreshToken, key: Constants.refreshKey)
                promise(.success(()))
            }
            .store(in: &self.subscriptions)
        }
    }
    
    func getApi<T: Decodable>(
        endPoint    : Endpoint,
        token       : String,
        showLoader  : Bool = false,
        responseType: T.Type
    ) -> AnyPublisher<T, APIError> {
        return self.getRequest(endPoint: endPoint, token: token, showLoader: showLoader, responseType: responseType)
            .catch { error -> AnyPublisher<T, APIError> in
                if case .unauthorized = error {
                    return self.regenerateAccessAPI()
                        .flatMap {
                            return self.getRequest(endPoint: endPoint, token: authKey, showLoader: showLoader, responseType: responseType)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func postApi<T: Decodable, U : Encodable>(
        endPoint    : Endpoint,
        method      : HTTPMethod,
        token       : String,
        body        : U?,
        showLoader: Bool = false,
        responseType: T.Type
    ) -> AnyPublisher<T, APIError> {
        return self.postRequest(endPoint: endPoint, method: method,token: token,body: body,showLoader: showLoader, responseType: responseType)
            .catch { error -> AnyPublisher<T, APIError> in
                if case .unauthorized = error {
                    return self.regenerateAccessAPI()
                        .flatMap {
                            return self.postRequest(endPoint: endPoint, method: method,token: authKey,body: body,showLoader: showLoader, responseType: responseType)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Api
    func getRequest<T: Decodable>(
        endPoint    : Endpoint,
        token       : String,
        showLoader  : Bool = false,
        responseType: T.Type
    ) -> Future<T, APIError> {
        return Future<T, APIError> { [self] promise in
            
            guard isInternetAvailable() else {
                DispatchQueue.main.async {
                    UIApplication.topViewController()?.showAlertForNoInternet()
                }
                return promise(.failure(.noInternetConnection))
            }
            
            if showLoader{
                LoaderManager.shared.showLoader()
            }
            
            guard let url = self.createURL(with: endPoint.rawValue)
            else {
                return promise(.failure(.badRequest))
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.GET.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(token, forHTTPHeaderField: "Authorization")
            
            PrintLogger.log(type: .authToken, message: token)
            PrintLogger.log(type: .apiUrl, message: url.absoluteString)
            
            self.urlSession.dataTaskPublisher(for: request)
                .tryMap { result -> Data in
                    guard let httpResponse = result.response as? HTTPURLResponse else {
                        throw APIError.responseError(-1)
                    }
                    print("Status Code : \(httpResponse.statusCode)")
                    switch httpResponse.statusCode {
                    case 400 :
                        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: result.data) {
                            throw APIError.apiError(apiError.message)
                        }else{
                            throw APIError.badRequest
                        }
                    case 401:
                        throw APIError.unauthorized
                    case 500:
                        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: result.data) {
                            throw APIError.apiError(apiError.message)
                        }else{
                            throw APIError.internalServerError
                        }
                    case 409: //Someone logged
                        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: result.data) {
                            throw APIError.apiError(apiError.message)
                        }else{
                            throw APIError.someOneLoggedInElsewhere
                        }
                    case 403: //Account blocked
                        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: result.data) {
                            throw APIError.apiError(apiError.message)
                        }else{
                            throw APIError.accountBlocked
                        }
                    default:
                        return result.data
                    }
                }
                .decode(type: T.self,
                        decoder: self.jsonDecoder)
                .receive(on: RunLoop.main)
                .sink { completion in
                    if case let .failure(error) = completion {
                        switch error {
                        case let urlError as URLError:
                            promise(.failure(.badRequest))
                        case let decodingError as DecodingError:
                            promise(.failure(.decodingError(decodingError)))
                        case let apiError as APIError:
                            showSnakbarMsg(message: apiError.localizedDescription, typeofMsg: .error)
                            promise(.failure(apiError))
                        default:
                            promise(.failure(.unknown))
                        }
                    }
                }
            receiveValue: {
                promise(.success($0))
            }
            .store(in: &self.subscriptions)
        }
    }
    
    //MARK: - Post Api
    func postRequest<T: Decodable, U : Encodable>(
        endPoint    : Endpoint,
        method      : HTTPMethod,
        token       : String,
        body        : U?,
        showLoader  : Bool = false,
        responseType: T.Type
    ) -> Future<T, APIError> {
        return Future<T, APIError> { [self] promise in
            
            guard isInternetAvailable() else {
                DispatchQueue.main.async {
                    UIApplication.topViewController()?.showAlertForNoInternet()
                }
                return promise(.failure(.noInternetConnection))
            }
            
            if showLoader{
                LoaderManager.shared.showLoader()
            }
            
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
            PrintLogger.log(type: .authToken, message: token)
            PrintLogger.log(type: .apiUrl, message: url.absoluteString)
            PrintLogger.modelLog(body, type: .inputParamenters)
            self.urlSession.dataTaskPublisher(for: request)
                .tryMap { result -> Data in
                    guard let httpResponse = result.response as? HTTPURLResponse else {
                        throw APIError.responseError(-1)
                    }
                    print("Status Code : \(httpResponse.statusCode)")
                    switch httpResponse.statusCode {
                    case 400 :
                        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: result.data) {
                            throw APIError.apiError(apiError.message)
                        }else{
                            throw APIError.badRequest
                        }
                    case 401:
                        throw APIError.unauthorized
                    case 500:
                        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: result.data) {
                            throw APIError.apiError(apiError.message)
                        }else{
                            throw APIError.internalServerError
                        }
                    case 409: //Someone logged
                        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: result.data) {
                            throw APIError.apiError(apiError.message)
                        }else{
                            throw APIError.someOneLoggedInElsewhere
                        }
                    case 403: //Account blocked
                        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: result.data) {
                            throw APIError.apiError(apiError.message)
                        }else{
                            throw APIError.accountBlocked
                        }
                    default:
                        return result.data
                    }
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case let .failure(error) = completion {
                        LoaderManager.shared.hideLoader()
                        switch error {
                        case let urlError as URLError:
                            promise(.failure(.badRequest))
                        case let decodingError as DecodingError:
                            promise(.failure(.decodingError(decodingError)))
                        case let apiError as APIError:
                            showSnakbarMsg(message: apiError.localizedDescription, typeofMsg: .error)
                            promise(.failure(apiError))
                        default:
                            promise(.failure(.unknown))
                        }
                    }
                }
            receiveValue: {
                LoaderManager.shared.hideLoader()
                promise(.success($0))
            }
            .store(in: &self.subscriptions)
        }
    }
}

//MARK: - Reachability
extension NetworkService{
    private func isInternetAvailable() -> Bool {
        guard let reachability = try? Reachability() else {
            return false
        }
        return reachability.connection != .unavailable
    }
}

extension UIViewController {
    func showAlertForNoInternet() {
        let alert = UIAlertController(
            title: "No Internet Connection",
            message: "Please check your internet connection.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
