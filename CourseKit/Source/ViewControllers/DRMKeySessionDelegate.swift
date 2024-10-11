import Foundation
import AVKit
import Alamofire
import CourseKit


class DRMKeySessionDelegate: NSObject, AVContentKeySessionDelegate {
    let drmLicenseURL: String?
    let instituteSettings = DBManager<InstituteSettings>().getResultsFromDB()[0]
    
    public required init?(drmLicenseURL: String?) {
        self.drmLicenseURL = drmLicenseURL
    }
    
    @available(iOS 10.3, *)
    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVContentKeyRequest) {
        
        if let contentKeyIdentifier = keyRequest.identifier as? NSURL{
            let contentId = contentKeyIdentifier.host!
            fetchDRMKey(keyRequest, contentId)
        } else if let contentId = keyRequest.identifier as? String{
            fetchDRMKey(keyRequest, contentId)
        }
        
    }
    
    
    func fetchDRMKey(_ keyRequest: AVContentKeyRequest, _ contentId: String) {
        let contentIdData = contentId.data(using: String.Encoding.utf8)

        do {
            let certificateData = try getFairplayCertificateData()
            keyRequest.makeStreamingContentKeyRequestData(forApp: certificateData, contentIdentifier: contentIdData, options: [AVAssetResourceLoadingRequestStreamingContentKeyRequestRequiresPersistentKey: true as AnyObject]) { spcData, spcError in
                
                guard let spcData = spcData else {
                    let error = spcError ?? DRMError.noSPCData
                    keyRequest.processContentKeyResponseError(error)
                    return
                }
                
                self.requestContentKeyFromKeySecurityModule(spcData: spcData, assetID: contentId) {
                    data in
                    
                    let keyResponse = AVContentKeyResponse(fairPlayStreamingKeyResponseData: data!)
                    keyRequest.processContentKeyResponse(keyResponse)
                }
                
            }
            
        } catch {
            return keyRequest.processContentKeyResponseError(DRMError.licenseError)
        }
    }
    
    func getFairplayCertificateData() throws -> Data {
        let certUrl = URL(string: instituteSettings.fairplayCertificateUrl)
        var applicationCertificate: Data? = nil
        do {
            applicationCertificate = try Data(contentsOf:certUrl!)
        } catch {
            throw DRMError.certificateError
        }
        
        return applicationCertificate!
    }
    
    func requestContentKeyFromKeySecurityModule(spcData: Data, assetID: String, completion: @escaping(Data?) -> Void)  {
        let contentKeyIdentifierURL = URL(string: assetID)
        let assetIDString = contentKeyIdentifierURL!.host
        
        self.getLicenseURL() { licenseURL, error in
            if (licenseURL != nil) {
                var data: Data?
                let semaphore = DispatchSemaphore(value: 0)
                let parameters = ["spc": spcData.base64EncodedString(), "assetId" : assetIDString] as [String : Any]
                let request = self.getLicenseKeyRequest(licenseURL: licenseURL!, parameters: parameters)
                let dataTask = URLSession.shared.dataTask(with: request as URLRequest) {
                    data = $0; _ = $1; _ = $2
                    semaphore.signal()
                }
                dataTask.resume()
                _ = semaphore.wait(timeout: .distantFuture)
                completion(data)
            }
        }
    }
    
    func getLicenseURL(completion: @escaping(String?, TPError?) -> Void) {
        let parameters: Parameters = ["drm_type": "fairplay"]
        
        TPApiClient.request(type: DRMLicenseKeyResponse.self, endpointProvider: TPEndpointProvider(.post, url: drmLicenseURL!), parameters: parameters) { response, error in
            completion(response?.licenseURL, error)
        }
    }
    
    func getLicenseKeyRequest(licenseURL: String, parameters: [String: Any]) -> URLRequest {
        var request = URLRequest(url: URL(string: licenseURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            try request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {}
        return request
    }
}


enum DRMError: Error {
    case noContentId
    case noSPCData
    case certificateError
    case licenseError
}
