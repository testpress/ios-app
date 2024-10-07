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
    public static var authErrorDelegate: AuthErrorHandlingDelegate?

    static func apiCall(endpointProvider: TPEndpointProvider,
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
    
    static func request(dataRequest: DataRequest,
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
    
    private static func debugLog(response: AFDataResponse<String>) {
        print(NSString(data: response.request?.httpBody ?? Data(), encoding: String.Encoding.utf8.rawValue) ?? "Empty Request Body")
        print(response)
        print(response.response ?? "No HTTP response")
        print(response.metrics ?? "No metrics")
    }
}

private extension URLError {
    var isNetworkRelated: Bool {
        return [.notConnectedToInternet, .cannotConnectToHost, .timedOut].contains(self.code)
    }
}


class AuthErrorHandler: AuthErrorHandlingDelegate {
    func handleUnauthenticatedError() {
        UIUtils.logout()
        presentLoginViewController()
    }

    func handleMaxLoginLimitError() {
        let instituteSettings = DBManager<InstituteSettings>().getResultsFromDB().first
        var message = Strings.MAX_LOGIN_EXCEEDED_ERROR_MESSAGE

        if let coolOffTime = instituteSettings?.cooloffTime, !coolOffTime.isEmpty {
            message += Strings.ACCOUNT_UNLOCK_INFO + "\(coolOffTime) hours"
        }

        UIUtils.showSimpleAlert(
            title: Strings.ACCOUNT_LOCKED,
            message: message,
            viewController: getRootViewController()!,
            cancelable: true
        )
    }

    func handleMultipleLoginRestrictionError(error: TPError) {
        guard let rootViewController = getRootViewController() else { return }
        
        let alert = UIAlertController(
            title: Strings.LOADING_FAILED,
            message: error.error_detail,
            preferredStyle: UIUtils.getActionSheetStyle()
        )
        
        alert.addAction(UIAlertAction(title: Strings.OK, style: .destructive) { _ in
            self.presentLoginViewController(from: rootViewController)
        })
        
        alert.addAction(UIAlertAction(title: Strings.CANCEL, style: .cancel, handler: nil))
        
        rootViewController.present(alert, animated: true, completion: nil)
    }
    
    private func presentLoginViewController(from viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier:
                                        Constants.LOGIN_VIEW_CONTROLLER) as! LoginViewController
            
            topController.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        guard var rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first!
        } else if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController!
        }
        
        return rootViewController
    }
}
