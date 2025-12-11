//
//  TPApiClient.swift
//  ios-app
//
//  Copyright © 2017 Testpress. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Alamofire
import UIKit

public enum AuthProvider: String {
    case TESTPRESS
    case FACEBOOK
}

public class TPApiClient {
    public static var authErrorDelegate: AuthErrorHandlingDelegate?

    public static func apiCall(endpointProvider: TPEndpointProvider,
                        parameters: Parameters? = nil,
                        headers: HTTPHeaders? = nil,
                        completion: @escaping (String?, TPError?) -> Void) -> Void {
        
        guard let url = URL(string: endpointProvider.getUrl()) else {
            completion(nil, TPError(message: "Invalid URL", kind: .unexpected))
            return
        }
        
        var request = createRequest(url: url, endpointProvider: endpointProvider, headers: headers, parameters: parameters)
        self.request(dataRequest: request, endpointProvider: endpointProvider, completion: completion)
    }
    
    static private func createRequest(url: URL,
                                      endpointProvider: TPEndpointProvider,
                                      headers: HTTPHeaders?,
                                      parameters: Parameters?) -> DataRequest {
        var request = URLRequest(url: url)
        request.httpMethod = endpointProvider.endpoint.method.rawValue

        if let customHeaders = headers?.dictionary {
            request.allHTTPHeaderFields = customHeaders
        }
        request.setValue(getUserAgent(), forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
       if (KeychainTokenItem.isExist()) {
           let token: String = KeychainTokenItem.getToken()
           request.setValue("JWT " + token, forHTTPHeaderField: "Authorization")
       }
        
        if let params = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        }
        return Alamofire.AF.request(request)
    }
    
    public static func request(dataRequest: DataRequest,
                        endpointProvider: TPEndpointProvider,
                        completion: @escaping (String?, TPError?) -> Void) {
        
        dataRequest.responseString(queue: .main, encoding: .utf8) { response in
            #if DEBUG
                debugLog(response: response)
            #endif
            
            guard let httpResponse = response.response else {
                handleError(error: response.error ?? TPError(message: "Unknown error", kind: .unexpected), completion: completion)
                return
            }
            
            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                let json = (try? response.result.get()) ?? ""
                handleSuccess(json: json, statusCode: httpResponse.statusCode, httpResponse: httpResponse, endpointProvider: endpointProvider, completion: completion)
                return
            }
            
            switch response.result {
            case .success(let json):
                handleSuccess(json: json, statusCode: httpResponse.statusCode, httpResponse: httpResponse, endpointProvider: endpointProvider, completion: completion)
                
            case .failure(let error):
                handleError(error: error, httpResponse: httpResponse, completion: completion)
            }
        }
    }
    
    private static func handleSuccess(json: String, statusCode: Int, httpResponse: HTTPURLResponse, endpointProvider: TPEndpointProvider, completion: @escaping (String?, TPError?) -> Void) {
        if statusCode >= 200 && statusCode < 300 {
            completion(json, nil)
        } else {

            var error = createError(for: statusCode, message: json, httpResponse: httpResponse, endpointProvider: endpointProvider)

            if (statusCode == 401 && ![TPEndpoint.logout, TPEndpoint.unRegisterDevice].contains(endpointProvider.endpoint)) {
                authErrorDelegate?.handleUnauthenticatedError()
            } else if error.kind == .custom {
                handleCustomError(error: error)
            }
            
            error.logErrorToSentry()
            completion(nil, error)
        }
    }
    
    private static func createError(for statusCode: Int, message: String, httpResponse: HTTPURLResponse, endpointProvider: TPEndpointProvider) -> TPError {
        switch statusCode {
        case 403:
            return TPError(message: message, response: httpResponse, kind: .unauthenticated)
        case 401 where ![TPEndpoint.logout, TPEndpoint.unRegisterDevice].contains(endpointProvider.endpoint):
            return TPError(message: message, response: httpResponse, kind: .unauthenticated)
        default:
            return TPError(message: message, response: httpResponse, kind: .http)
        }
    }

    public static func handleError(error: Error, httpResponse: HTTPURLResponse? = nil, completion: @escaping (String?, TPError?) -> Void) {
        let errorDescription = error.localizedDescription
        let kind: TPError.Kind = (error as? URLError)?.isNetworkRelated == true ? .network : .unexpected
        
        let tpError = TPError(message: errorDescription, response: httpResponse, kind: kind)
        
        if tpError.kind == .custom {
            handleCustomError(error: tpError)
        }
        
        tpError.logErrorToSentry()
        completion(nil, tpError)
    }

    private static func handleCustomError(error: TPError) {
        switch error.error_code {
        case Constants.MULTIPLE_LOGIN_RESTRICTION_ERROR_CODE:
            authErrorDelegate?.handleMultipleLoginRestrictionError(error: error)
        case Constants.MAX_LOGIN_LIMIT_EXCEEDED:
            authErrorDelegate?.handleMaxLoginLimitError()
        default:
            break
        }
    }
    
    public static func getUserAgent() -> String {
        // Testpress iOS App/1.17.0.1 iPhone8,4, iOS/12_1_4 CFNetwork
        let device = UIDevice.current
        return "\(Constants.getAppName())/\(Constants.getAppVersion()) \(device.modelName), iOS/\(device.systemVersion.replacingOccurrences(of: ".", with: "_")) CFNetwork"
    }
    

    
    public static func request<T: TestpressModel>(type: T.Type,
                                           endpointProvider: TPEndpointProvider,
                                           parameters: Parameters? = nil,
                                           completion: @escaping(T?, TPError?) -> Void) {
        
        apiCall(endpointProvider: endpointProvider, parameters: parameters, completion: {
            json, error in
            var dataModel: T? = nil
            if let json = json {
                dataModel = TPModelMapper<T>().mapFromJSON(json: json)
                guard dataModel != nil else {
                    completion(nil, TPError(message: json, kind: .unexpected))
                    return
                }
            }
            completion(dataModel, error)
        })
    }
    
    private static func debugLog(response: AFDataResponse<String>) {
        print(NSString(data: response.request?.httpBody ?? Data(), encoding: String.Encoding.utf8.rawValue) ?? "Empty Request Body")
        print(response)
        print(response.response ?? "No HTTP response")
        print(response.metrics ?? "No metrics")
    }
    
    public static func getListItems<T> (type: T.Type,
                                 endpointProvider: TPEndpointProvider,
                                 headers: HTTPHeaders? = nil,
                                 completion: @escaping (ApiResponse<T>?, TPError?) -> Void) {
        
        apiCall(endpointProvider: endpointProvider, headers: headers, completion: {
            json, error in
            
            var testpressResponse: ApiResponse<T>? = nil
            if let json = json {
                testpressResponse = TPModelMapper<ApiResponse<T>>().mapFromJSON(json: json)
                debugPrint(testpressResponse?.results ?? "Error")
                guard testpressResponse != nil else {
                    completion(nil, TPError(message: json, kind: .unexpected))
                    return
                }
            }
            completion(testpressResponse, error)
        })
    }
    
    public static func getListItems<T> (endpointProvider: TPEndpointProvider,
                                 headers: HTTPHeaders? = nil,
                                 completion: @escaping (TPApiResponse<T>?, TPError?) -> Void,
                                 type: T.Type) {
        
        apiCall(endpointProvider: endpointProvider, headers: headers, completion: {
            json, error in
            
            var testpressResponse: TPApiResponse<T>? = nil
            if let json = json {
                testpressResponse = TPModelMapper<TPApiResponse<T>>().mapFromJSON(json: json)
                debugPrint(testpressResponse?.results ?? "Error")
                guard testpressResponse != nil else {
                    completion(nil, TPError(message: json, kind: .unexpected))
                    return
                }
            }
            completion(testpressResponse, error)
        })
    }
    
    public static func uploadImage(imageData: Data, fileName: String,
                            completion: @escaping (FileDetails?, TPError?) -> Void) {
        
        let url =  URL(string: TPEndpointProvider(.uploadImage).getUrl())!
        var headers: HTTPHeaders = ["User-Agent": getUserAgent()]
        if (KeychainTokenItem.isExist()) {
            let token: String = KeychainTokenItem.getToken()
            headers["Authorization"] = "JWT " + token
        }
        
      
        Alamofire.AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "file", fileName: fileName,
                                         mimeType: "image/jpg")
            },
            to: url,
            usingThreshold: .max,
            method: .post,
            headers: headers,
            interceptor: nil,
            fileManager: .default
        ).validate()
            .responseString { response in
                switch response.result {
                case .success(let value):
                    let fileDetails = TPModelMapper<FileDetails>().mapFromJSON(json: value)
                    guard fileDetails != nil else {
                        completion(nil, TPError(message: value,   kind: .unexpected))
                        return
                    }
                    completion(fileDetails, nil)
                case .failure(let error):
                    handleError(error: error, completion: {
                        json, error in
                        completion(nil, error)
                    })
                }
            }

    }
    
    public static func authenticate(username: String, password: String,
                             provider: AuthProvider = .TESTPRESS,
                             completion: @escaping (TPAuthToken?, TPError?) -> Void) {
        
        var parameters: Parameters
        var endpoint: TPEndpoint
        if provider == .TESTPRESS {
            parameters = ["username": username, "password": password]
            endpoint = .authenticateUser
        } else {
            endpoint = .authenticateSocialUser
            parameters = ["user_id": username, "access_token": password,
                          "provider": provider.rawValue]
        }
        apiCall(endpointProvider: TPEndpointProvider(endpoint), parameters: parameters,
                completion: { json, error in
                    
            var testpressAuthToken: TPAuthToken? = nil
            if let json = json {
                testpressAuthToken = TPModelMapper<TPAuthToken>().mapFromJSON(json: json)
                guard testpressAuthToken != nil else {
                    completion(nil, TPError(message: json, kind: .unexpected))
                    return
                }
            }
            completion(testpressAuthToken, error)
        })
    }
    
    public static func resetPassword(email: String,
                              completion: @escaping (TPError?) -> Void) {
        
        let parameters: Parameters = ["email": email]
        apiCall(endpointProvider: TPEndpointProvider(.resetPassword),
                parameters: parameters,
                completion: { json, error in
                    completion(error)
                }
        )
    }
    
    public static func verifyPhoneNumber(username: String, code: String, completion: @escaping (TPError?) -> Void) {
        let parameters: Parameters = ["code": code, "username": username]
        apiCall(endpointProvider: TPEndpointProvider(.verifyPhoneNumber),
                parameters: parameters,
                completion: { json, error in
                    completion(error)
        }
        )
    }
    
    public static func registerNewUser(username: String, email: String, password: String, phone: String, country_code:String, completion: @escaping (TestpressModel?, TPError?) -> Void) {
        
        let parameters: Parameters = ["username": username, "email": email, "password": password, "phone": phone, "country_code":country_code]
        apiCall(endpointProvider: TPEndpointProvider(.registerNewUser), parameters: parameters,
                completion: { json, error in
                    
                    var user: TestpressModel? = nil
                    if let json = json {
                        user = TPModelMapper<User>().mapFromJSON(json: json)
                        guard user != nil else {
                            completion(nil, TPError(message: json, kind: .unexpected))
                            return
                        }
                    }
                    completion(user, error)
        })
    }
    
    public static func generateOtp(phoneNumber: String? = nil,
                                   countryCode: String? = nil,
                                   email: String? = nil,
                                   completion: @escaping (TPError?) -> Void) {
        
        var parameters: Parameters = [:]
        
        if let phone = phoneNumber, let code = countryCode {
            parameters["phone_number"] = phone
            parameters["country_code"] = code
        }
        
        if let email = email {
            parameters["email"] = email
        }
        
        apiCall(endpointProvider: TPEndpointProvider(.generateOtp),
                parameters: parameters,
                completion: { _, error in
                    completion(error)
                })
    }
    
    public static func otpLogin(otp: String,
                               phoneNumber: String? = nil,
                               email: String? = nil,
                               completion: @escaping (TPAuthToken?, TPError?) -> Void) {
        
        var parameters: Parameters = [:]
        parameters["otp"] = otp
        
        if let phone = phoneNumber {
            parameters["phone_number"] = phone
        }
        
        if let email = email {
            parameters["email"] = email
        }
        
        request(type: TPAuthToken.self,
                endpointProvider: TPEndpointProvider(.otpLogin),
                parameters: parameters,
                completion: completion)
    }

    
    public static func getSSOUrl(completion: @escaping(SSOUrl?, TPError?) -> Void) {
        apiCall(endpointProvider: TPEndpointProvider(.getSSOUrl),
                completion: {
                    json, error in
                    var sso_detail: SSOUrl? = nil
                    if let json = json {
                        sso_detail = TPModelMapper<SSOUrl>().mapFromJSON(json: json)
                        debugPrint(sso_detail?.url ?? "Error")
                        guard sso_detail != nil else {
                            completion(nil, TPError(message: json, kind: .unexpected))
                            return
                        }
                    }
                    completion(sso_detail, error)
        }
        )
    }
    
    public static func getProfile(endpointProvider: TPEndpointProvider,
                           completion: @escaping(User?, TPError?) -> Void) {
        
        apiCall(endpointProvider: endpointProvider, completion: {
            json, error in
            var user: User? = nil
            if let json = json {
                user = TPModelMapper<User>().mapFromJSON(json: json)
                debugPrint(user?.url ?? "Error")
                guard user != nil else {
                    completion(nil, TPError(message: json, kind: .unexpected))
                    return
                }
            }
            completion(user, error)
        })
    }
    
    public static func postComment(comment: String,
                            commentsUrl: String,
                            completion: @escaping (Comment?, TPError?) -> Void) {
        
        let parameters: Parameters = ["comment": comment]
        let endpoint = TPEndpointProvider(.post, url: commentsUrl)
        apiCall(endpointProvider: endpoint, parameters: parameters,
                completion: { json, error in
                    
                    var comment: Comment? = nil
                    if let json = json {
                        comment = TPModelMapper<Comment>().mapFromJSON(json: json)
                        guard comment != nil else {
                            completion(nil, TPError(message: json, kind: .unexpected))
                            return
                        }
                    }
                    completion(comment, error)
        })
    }
    
    public static func getExams(endpointProvider: TPEndpointProvider,
                         completion: @escaping (TPApiResponse<Exam>?, TPError?) -> Void) {
        
        apiCall(endpointProvider: endpointProvider, completion: {
            json, error in

            var testpressResponse: TPApiResponse<Exam>? = nil
            if let json = json {
                testpressResponse = TPModelMapper<TPApiResponse<Exam>>().mapFromJSON(json: json)
                debugPrint(testpressResponse?.results ?? "Error")
                guard testpressResponse != nil else {
                    completion(nil, TPError(message: json, kind: .unexpected))
                    return
                }
            }
            completion(testpressResponse, error)
        })
    }
    
    public static func getQuestions(endpointProvider: TPEndpointProvider,
                             completion: @escaping(TPApiResponse<AttemptItem>?, TPError?) -> Void) {
        
        apiCall(endpointProvider: endpointProvider, completion: {
            json, error in
            
            var response: TPApiResponse<AttemptItem>? = nil
            if let json = json {
                response = TPModelMapper<TPApiResponse<AttemptItem>>().mapFromJSON(json: json)
                debugPrint(response?.results.count ?? "Error")
                guard response != nil else {
                    completion(nil, TPError(message: json, kind: .unexpected))
                    return
                }
            }
            completion(response, error)
        })
    }
    
    public static func updateAttemptState(endpointProvider: TPEndpointProvider,
                                   completion: @escaping (Attempt?, TPError?) -> Void) {
        
        apiCall(endpointProvider: endpointProvider, completion: {
            json, error in
            var attempt: Attempt? = nil
            if let json = json {
                attempt = TPModelMapper<Attempt>().mapFromJSON(json: json)
                debugPrint(attempt?.questionsUrl ?? "Error")
                guard attempt != nil else {
                    completion(nil, TPError(message: json, kind: .unexpected))
                    return
                }
            }
            completion(attempt, error)
        })
    }
    
    public static func saveAnswer(selectedAnswer: [Int],
                           review: Bool,
                           shortAnswer: String?,
                           gapFilledResponses: [GapFillResponse]?,
                           endpointProvider: TPEndpointProvider,
                           attemptItem: AttemptItem,
                           completion: @escaping (AttemptItem?, TPError?) -> Void) {
        
        var parameters: Parameters = [ "selected_answers": selectedAnswer, "review": review ]
        if let shortAnswer = shortAnswer {
            parameters["short_text"] = shortAnswer
        }
        
        if attemptItem.question.isEssayType {
            parameters["essay_text"] = attemptItem.localEssayText
        }
        
        if attemptItem.question.isFileType {
            parameters["files"] = Array(attemptItem.localFiles.map {$0.path})
        }
                
        if let gapFilledResponses = gapFilledResponses {
            let vals : [[String: String]] = gapFilledResponses.map{["order": String($0.order), "answer": $0.answer]}
            parameters["gap_fill_responses"] = vals
        }
        apiCall(endpointProvider: endpointProvider, parameters: parameters, completion: {
            json, error in
            var attemptItem: AttemptItem? = nil
            if let json = json {
                attemptItem = TPModelMapper<AttemptItem>().mapFromJSON(json: json)
                debugPrint(attemptItem?.url ?? "Error")
                guard attemptItem != nil else {
                    completion(nil, TPError(message: json, kind: .unexpected))
                    return
                }
            }
            completion(attemptItem, error)
        })
    }
    
    public static func loadAttempts(endpointProvider: TPEndpointProvider,
                             completion: @escaping(TPApiResponse<Attempt>?, TPError?) -> Void) {
        
        apiCall(endpointProvider: endpointProvider, completion: {
            json, error in
            var testpressResponse: TPApiResponse<Attempt>? = nil
            if let json = json {
                testpressResponse =
                    TPModelMapper<TPApiResponse<Attempt>>().mapFromJSON(json: json)
                
                debugPrint(testpressResponse?.results.count ?? "Error")
                guard testpressResponse != nil else {
                    completion(nil, TPError(message: json, kind: .unexpected))
                    return
                }
            }
            completion(testpressResponse, error)
        })
    }
}

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

private extension URLError {
    var isNetworkRelated: Bool {
        return [.notConnectedToInternet, .cannotConnectToHost, .timedOut].contains(self.code)
    }
}
