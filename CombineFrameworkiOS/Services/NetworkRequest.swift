import Foundation
import Combine
import UIKit
import Reachability

class NetworkRequest {
    
    // MARK: - Properties
    static let shared         = NetworkRequest()
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
    
    //MARK: - API's
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
        extraParams : String? = nil,
        responseType: T.Type
    ) -> AnyPublisher<T, APIError> {
        return self.getRequest(endPoint: endPoint, token: token, showLoader: showLoader,extraParams: extraParams, responseType: responseType)
            .catch { error -> AnyPublisher<T, APIError> in
                if case .unauthorized = error {
                    return self.regenerateAccessAPI()
                        .flatMap {
                            return self.getRequest(endPoint: endPoint, token: authKey, showLoader: showLoader,extraParams: extraParams, responseType: responseType)
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
    
    func postMultipartApi<T: Decodable, U : Encodable>(
        endPoint    : Endpoint,
        method      : HTTPMethod,
        token       : String,
        body        : MultipartInput<U>?,
        showLoader: Bool = false,
        responseType: T.Type
    ) -> AnyPublisher<T, APIError> {
        return self.multiPartRequest(endPoint: endPoint, method: method,token: token,body: body,showLoader: showLoader, responseType: responseType)
            .catch { error -> AnyPublisher<T, APIError> in
                if case .unauthorized = error {
                    return self.regenerateAccessAPI()
                        .flatMap {
                            return self.multiPartRequest(endPoint: endPoint, method: method,token: authKey,body: body,showLoader: showLoader, responseType: responseType)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Request
    func getRequest<T: Decodable>(
        endPoint    : Endpoint,
        token       : String,
        showLoader  : Bool = false,
        extraParams : String? = nil,
        responseType: T.Type
    ) -> Future<T, APIError> { //A Future is a Combine publisher that emits one value or one failure, then completes. Then the subscription automatically completes (no more emissions)
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
            var finalEndpoint : String = endPoint.rawValue
            if extraParams != nil || extraParams != ""{
                finalEndpoint = endPoint.rawValue + (extraParams ?? "")
            }
            guard let url = self.createURL(with: finalEndpoint)
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
                        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: result.data) {
                            throw APIError.apiError(apiError.message)
                        }else{
                            throw APIError.responseError
                        }
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
                        LoaderManager.shared.hideLoader()
                        switch error {
                        case let urlError as URLError:
                            promise(.failure(.urlError(urlError)))
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
    
    //MARK: - Post Request
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
                    return promise(.failure(.badRequest))
                }
            }
            PrintLogger.log(type: .authToken, message: token)
            PrintLogger.log(type: .apiUrl, message: url.absoluteString)
            PrintLogger.modelLog(body, type: .inputParamenters)
            self.urlSession.dataTaskPublisher(for: request)
                .tryMap { result -> Data in
                    guard let httpResponse = result.response as? HTTPURLResponse else {
                        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: result.data) {
                            throw APIError.apiError(apiError.message)
                        }else{
                            throw APIError.responseError
                        }
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
                            promise(.failure(.urlError(urlError)))
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
    
    //MARK: - Post Request
    func multiPartRequest<T: Decodable, U: Encodable>(
        endPoint    : Endpoint,
        method      : HTTPMethod,
        token       : String,
        body        : MultipartInput<U>?,
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
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.addValue(token, forHTTPHeaderField: "Authorization")
            if let body = body {
                do {
                    request.httpBody = try? createMultipartBody(with: body, boundary: boundary)
                }
            }
            PrintLogger.log(type: .authToken, message: token)
            PrintLogger.log(type: .apiUrl, message: url.absoluteString)
            PrintLogger.modelLog(body?.parameters, type: .inputParamenters)
            self.urlSession.dataTaskPublisher(for: request)
                .tryMap { result -> Data in
                    guard let httpResponse = result.response as? HTTPURLResponse else {
                        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: result.data) {
                            throw APIError.apiError(apiError.message)
                        }else{
                            throw APIError.responseError
                        }
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
                            promise(.failure(.urlError(urlError)))
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
    
    private func createMultipartBody<T: Encodable>(with input: MultipartInput<T>, boundary: String) throws -> Data {
        var body = Data()
        
        let encoder = JSONEncoder()
        let parametersData = try encoder.encode(input.parameters)
        let parametersDict = try JSONSerialization.jsonObject(with: parametersData, options: []) as? [String: Any] ?? [:]
        
        for (key, value) in parametersDict {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
            
            // Handle arrays and other values differently
            if JSONSerialization.isValidJSONObject(value) {
                let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    body.append(Data("\(jsonString)\r\n".utf8))
                }
            } else {
                body.append(Data("\(value)\r\n".utf8))
            }
        }
        
        for (index, obj) in input.fileInput.enumerated() {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(obj.fieldName)\"; filename=\"profileImage\(index).png\"\r\n".utf8))
            body.append(Data("Content-Type: \(obj.mimeType)\r\n\r\n".utf8))
            body.append(obj.fileData)
            body.append(Data("\r\n".utf8))
        }
        
        body.append(Data("--\(boundary)--\r\n".utf8))
        
        return body
    }
}

//MARK: - Reachability
extension NetworkRequest{
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
