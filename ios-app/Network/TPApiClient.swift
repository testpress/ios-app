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
import Device
import UIKit

enum AuthProvider: String {
    case TESTPRESS
    case FACEBOOK
}

class TPApiClient {

    static func apiCall(endpointProvider: TPEndpointProvider,
                        parameters: Parameters? = nil,
                        headers: HTTPHeaders? = nil,
                        completion: @escaping (String?, TPError?) -> Void) -> Void {
        
        let url =  URL(string: endpointProvider.getUrl())
        var request = URLRequest(url: url!)
        request.httpMethod = endpointProvider.endpoint.method.rawValue
        
        // Add given headers
        if headers != nil {
            request.allHTTPHeaderFields = headers
        }
        
        // Add common headers
        request.setValue(getUserAgent(), forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if (KeychainTokenItem.isExist()) {
            let token: String = KeychainTokenItem.getToken()
            request.setValue("JWT " + token, forHTTPHeaderField: "Authorization")
        }
        
        // Add post parameters
        if parameters != nil {
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameters!, options:
                JSONSerialization.WritingOptions.prettyPrinted)
        }
        
        let dataRequest = Alamofire.request(request)
        self.request(dataRequest: dataRequest, completion: completion)
    }
    
    static func request(dataRequest: DataRequest,
                        completion: @escaping (String?, TPError?) -> Void) {
        
        dataRequest.responseString() { response in
            #if DEBUG
                print(NSString(data: response.request?.httpBody ?? Data(),
                               encoding: String.Encoding.utf8.rawValue) ?? "Empty Request Body")
                print(response)
                print(response.response ?? "No HTTP response")
                print("requestDuration-", response.timeline.requestDuration)
                print("totalDuration-", response.timeline.totalDuration)
            #endif
            
            let httpResponse: HTTPURLResponse? = response.response
            switch(response.result){
            
            case .success(let json):
                let statusCode = httpResponse!.statusCode
                if (statusCode >= 200 && statusCode < 300) {
                    completion(json, nil)
                } else {
                    var error: TPError
                    if (statusCode == 403) {
                        error = TPError(message: json, response: httpResponse,
                                        kind: .unauthenticated)
                    } else {
                        error = TPError(message: json, response: httpResponse, kind: .http)
                    }
                    completion(nil, error)
                }
            
            case .failure(let error):
                handleError(error: error, completion: completion)
            }
        }
    }
    
    static func handleError(error: Error, httpResponse: HTTPURLResponse? = nil,
                            completion: @escaping (String?, TPError?) -> Void) {
        
        let description = error.localizedDescription
        if let error = error as? URLError,
            (error.code  == URLError.Code.notConnectedToInternet ||
                error.code  == URLError.Code.cannotConnectToHost ||
                error.code  == URLError.Code.timedOut) {
            
            let error = TPError(message: description, response: httpResponse,
                                kind: .network)
            
            completion(nil, error)
        } else {
            let error = TPError(message: description, response: httpResponse,
                                kind: .unexpected)
            
            completion(nil, error)
        }
    }
    
    static func uploadImage(imageData: Data, fileName: String,
                            completion: @escaping (FileDetails?, TPError?) -> Void) {
        
        let url =  URL(string: TPEndpointProvider(.uploadImage).getUrl())!
        var headers: HTTPHeaders = ["User-Agent": getUserAgent()]
        if (KeychainTokenItem.isExist()) {
            let token: String = KeychainTokenItem.getToken()
            headers["Authorization"] = "JWT " + token
        }
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "file", fileName: fileName,
                                         mimeType: "image/jpg")
        },
            to: url,
            headers: headers
        ) { (result) in
            switch result {
            case .success(let upload, _, _):
                request(dataRequest: upload, completion: {
                    json, error in
                    var fileDetails: FileDetails? = nil
                    if let json = json {
                        fileDetails = TPModelMapper<FileDetails>().mapFromJSON(json: json)
                        guard fileDetails != nil else {
                            completion(nil, TPError(message: json, kind: .unexpected))
                            return
                        }
                    }
                    completion(fileDetails, error)
                })
            case .failure(let error):
                handleError(error: error, completion: {
                    json, error in
                    completion(nil, error)
                })
            }
        }
    }
    
    static func getUserAgent() -> String {
        let device = UIDevice.current
        // Testpress iOS App/1.0.1 (iPhone; iPhoneSE OS 10_3_1)
        return "\(UIUtils.getAppName())/\(Constants.getAppVersion()) (iPhone; \(device.deviceType) "
            + "OS \(device.systemVersion.replacingOccurrences(of: ".", with: "_")))"
    }
    
    static func getListItems<T> (endpointProvider: TPEndpointProvider,
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
    
    static func request<T: TestpressModel>(type: T.Type,
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
    
    static func getListItems<T> (type: T.Type,
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
    
    static func authenticate(username: String, password: String,
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
    
    static func registerNewUser(username: String, email: String, password: String, phone: String,
                                completion: @escaping (TestpressModel?, TPError?) -> Void) {
        
        let parameters: Parameters = ["username": username, "email": email, "password": password, "phone": phone]
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
    
    static func resetPassword(email: String,
                              completion: @escaping (TPError?) -> Void) {
        
        let parameters: Parameters = ["email": email]
        apiCall(endpointProvider: TPEndpointProvider(.resetPassword),
                parameters: parameters,
                completion: { json, error in
                    completion(error)
                }
        )
    }
    
    static func verifyPhoneNumber(username: String, code: String, completion: @escaping (TPError?) -> Void) {
        let parameters: Parameters = ["code": code, "username": username]
        apiCall(endpointProvider: TPEndpointProvider(.verifyPhoneNumber),
                parameters: parameters,
                completion: { json, error in
                    completion(error)
        }
        )
    }
    
    static func getExams(endpointProvider: TPEndpointProvider,
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
    
    static func getQuestions(endpointProvider: TPEndpointProvider,
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
    
    static func updateAttemptState(endpointProvider: TPEndpointProvider,
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
    
    static func saveAnswer(selectedAnswer: [Int],
                           review: Bool,
                           shortAnswer: String?,
                           endpointProvider: TPEndpointProvider,
                           completion: @escaping (AttemptItem?, TPError?) -> Void) {
        
        var parameters: Parameters = [ "selected_answers": selectedAnswer, "review": review ]
        if let shortAnswer = shortAnswer {
            parameters["short_text"] = shortAnswer
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
    
    static func loadAttempts(endpointProvider: TPEndpointProvider,
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
    
    static func getProfile(endpointProvider: TPEndpointProvider,
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
    
    static func postComment(comment: String,
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
    
}

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
