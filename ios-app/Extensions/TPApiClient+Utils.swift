//
//  TPApiClient.swift
//  CourseKit
//
//  Created by Testpress on 04/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import CourseKit
import Alamofire


extension TPApiClient {
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
    
    static func uploadImage(imageData: Data, fileName: String,
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
    
    static func registerNewUser(username: String, email: String, password: String, phone: String, country_code:String, completion: @escaping (TestpressModel?, TPError?) -> Void) {
        
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
    
    static func getSSOUrl(completion: @escaping(SSOUrl?, TPError?) -> Void) {
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
}

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
