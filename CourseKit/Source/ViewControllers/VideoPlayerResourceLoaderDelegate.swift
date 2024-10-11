//
//  VideoPlayerResourceLoaderDelegate.swift
//  ios-app
//
//  Created by Karthik on 05/06/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation
import AVKit
import CourseKit


class VideoPlayerResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    var contentKeySession: AVContentKeySession?

    func setContentKeySession(contentKeySession: AVContentKeySession) {
        self.contentKeySession = contentKeySession
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url else { return false }
        if url.scheme == "fakehttps" {
            M3U8Handler().fetch(url: url) { data, response in
                self.setM3U8Response(loadingRequest: loadingRequest, data: data, response: response)
            }
            return true
        } else if url.scheme == "skd" {
            if #available(iOS 11, *) {
                contentKeySession?.processContentKeyRequest(withIdentifier: url, initializationData: nil, options: nil)
            }
        } else if isEncryptionKeyUrl(url: url) {
            EncryptionKeyRepository().load(url: url) { data in
                self.setEncryptionKeyResponse(loadingRequest: loadingRequest, data: data)
            }
            return true
        }
        
        return false
    }
    
    func isEncryptionKeyUrl(url: URL) -> Bool {
        return url.scheme == "fakekeyhttps" || url.path.contains("encryption_key")
    }
    
    func setM3U8Response(loadingRequest: AVAssetResourceLoadingRequest, data: Data, response:URLResponse?) {
        loadingRequest.contentInformationRequest?.contentType = response?.mimeType
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        loadingRequest.contentInformationRequest?.contentLength = response!.expectedContentLength
        loadingRequest.dataRequest?.respond(with: data)
        loadingRequest.finishLoading()
    }
    
    func setEncryptionKeyResponse(loadingRequest: AVAssetResourceLoadingRequest, data: Data) {
        loadingRequest.contentInformationRequest?.contentType = getContentType(contentInformationRequest: loadingRequest.contentInformationRequest)
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        loadingRequest.contentInformationRequest?.contentLength = Int64(data.count)
        loadingRequest.dataRequest?.respond(with: data)
        loadingRequest.finishLoading()
    }
    
    func getContentType(contentInformationRequest: AVAssetResourceLoadingContentInformationRequest?) -> String{
        var contentType = AVStreamingKeyDeliveryPersistentContentKeyType
                 
        if #available(iOS 11.2, *) {
            if let allowedContentType = contentInformationRequest?.allowedContentTypes?.first{
                if allowedContentType == AVStreamingKeyDeliveryContentKeyType{
                    contentType = AVStreamingKeyDeliveryContentKeyType
                }
            }
        }
        
        return contentType
    }
}
