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
import CourseKit

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
        if let headers = headers?.dictionary {
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
        
        let dataRequest = Alamofire.AF.request(request)
        self.request(dataRequest: dataRequest, endpointProvider: endpointProvider, completion: completion)
    }
    
    static func request(dataRequest: DataRequest,
                        endpointProvider: TPEndpointProvider,
                        completion: @escaping (String?, TPError?) -> Void) {
        
        dataRequest.responseString(queue: .main, encoding: String.Encoding.utf8) { response in
            #if DEBUG
                print(NSString(data: response.request?.httpBody ?? Data(),
                               encoding: String.Encoding.utf8.rawValue) ?? "Empty Request Body")
                print(response)
                print(response.response ?? "No HTTP response")
                print(response.metrics)
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
                    } else if (statusCode == 401 && ![TPEndpoint.logout, TPEndpoint.unRegisterDevice].contains(endpointProvider.endpoint)){
                        error = TPError(message: json, response: httpResponse, kind: .unauthenticated)
                        UIUtils.logout()

                        if var topController = UIApplication.shared.keyWindow?.rootViewController {
                            while let presentedViewController = topController.presentedViewController {
                                topController = presentedViewController
                            }
                            let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
                            let loginViewController = storyboard.instantiateViewController(withIdentifier:
                                                        Constants.LOGIN_VIEW_CONTROLLER) as! LoginViewController
                            
                            topController.present(loginViewController, animated: true, completion: nil)
                            
                        }
                        
                    } else {
                        error = TPError(message: json, response: httpResponse, kind: .http)
                        error.logErrorToSentry()
                    }

                    if (error.kind == TPError.Kind.custom) {
                        handleCustomError(error: error)
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
            
            error.logErrorToSentry()
            completion(nil, error)
        } else {
            let error = TPError(message: description, response: httpResponse,
                                kind: .unexpected)
            
            if (error.kind == TPError.Kind.custom) {
                handleCustomError(error: error)
            }
            
            error.logErrorToSentry()
            completion(nil, error)
        }
    }
    
    static func handleCustomError(error: TPError) {
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }

        if error.error_code == Constants.MULTIPLE_LOGIN_RESTRICTION_ERROR_CODE {
            let alert = UIAlertController(title: Strings.LOADING_FAILED,
                                          message: error.error_detail,
                                          preferredStyle: UIUtils.getActionSheetStyle())
            alert.addAction(UIAlertAction(
                title: Strings.OK,
                style: UIAlertAction.Style.destructive,
                handler: { action in
                    let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
                    let tabViewController = storyboard.instantiateViewController(
                        withIdentifier: Constants.LOGIN_ACTIVITY_VIEW_CONTROLLER)
                    rootViewController!.present(tabViewController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: Strings.CANCEL, style: UIAlertAction.Style.cancel))
            rootViewController!.present(alert, animated: true)

        } else if error.error_code == Constants.MAX_LOGIN_LIMIT_EXCEEDED {
            var message = Strings.MAX_LOGIN_EXCEEDED_ERROR_MESSAGE
            let instituteSettings = DBManager<InstituteSettings>().getResultsFromDB()[0]
            
            if !instituteSettings.cooloffTime.isEmpty {
                message += Strings.ACCOUNT_UNLOCK_INFO + "\(instituteSettings.cooloffTime) hours"
            }

            UIUtils.showSimpleAlert(
                title: Strings.ACCOUNT_LOCKED,
                message: message,
                viewController: rootViewController!,
                cancelable: true
            )
        }
    }
    
    static func getUserAgent() -> String {
        // Testpress iOS App/1.17.0.1 iPhone8,4, iOS/12_1_4 CFNetwork
        let device = UIDevice.current
        return "\(Constants.getAppName())/\(Constants.getAppVersion()) \(device.modelName), iOS/\(device.systemVersion.replacingOccurrences(of: ".", with: "_")) CFNetwork"
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
}
