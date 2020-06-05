//
//  VideoPlayerResourceLoaderDelegate.swift
//  ios-app
//
//  Created by Karthik on 05/06/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation
import AVKit
import SwiftKeychainWrapper

class VideoPlayerResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url else { return false }
        if url.scheme == "fakehttps" {
            handleM3U8Requests(url: url, loadingRequest: loadingRequest)
            return true
        } else if isEncryptionKeyUrl(url: url) {
            handleKeyRequests(url: url, loadingRequest: loadingRequest)
            return true
        }
        
        return false
    }
    
    func isEncryptionKeyUrl(url: URL) -> Bool {
        return url.scheme == "fakekeyhttps" || url.path.contains("encryption_key")
    }
    
    func handleKeyRequests(url: URL, loadingRequest: AVAssetResourceLoadingRequest) {
        var urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )
        urlComponents!.scheme = "https"
        let encryptionKeyUrl = urlComponents!.url!
        
        let key: Data? = KeychainWrapper.standard.data(forKey: encryptionKeyUrl.absoluteString)
        if (key != nil) {
            loadKeyToRequest(loadingRequest: loadingRequest, key: key!)
        } else {
            loadAndStoreEncryptionKey(keyUrl: encryptionKeyUrl, loadingRequest: loadingRequest)
        }
    }
    
    func handleM3U8Requests(url: URL, loadingRequest: AVAssetResourceLoadingRequest) {
        var urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )
        urlComponents!.scheme = "https"
        let m3u8Url =  urlComponents!.url
        loadAndModifyM3U8(url: m3u8Url!, loadingRequest: loadingRequest)
    }
    
    func loadAndModifyM3U8(url: URL, loadingRequest: AVAssetResourceLoadingRequest) {
        let request = URLRequest(url: url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { data, response, _ in
            guard let data = data else { return }
            let m3u8DataString = self.parseAndModifyM3U8Data(m3u8Data: data)
            let modifiedData = self.replaceRelativeVideoChunkUrlsWithAbsoluteUrl(url: url, m3u8Data: m3u8DataString)
            loadingRequest.contentInformationRequest?.contentType = response?.mimeType
            loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
            loadingRequest.contentInformationRequest?.contentLength = response!.expectedContentLength
            loadingRequest.dataRequest?.respond(with: modifiedData)
            loadingRequest.finishLoading()
        }
        task.resume()
    }
    
    func parseAndModifyM3U8Data(m3u8Data: Data) -> String {
        var m3u8DataString = String(data: m3u8Data, encoding: .utf8)!
        
        if m3u8DataString.contains("EXT-X-KEY") {
            m3u8DataString = self.modifyKeyURL(m3u8Data: m3u8DataString)
        }
        return m3u8DataString
    }
    
    func modifyKeyURL(m3u8Data: String) -> String {
        /*
         Since we need to add authorization header to key url, we need to intercept key url.
         So we are changing schema of the key URL so that we can intercept it.
         */
        let start = m3u8Data.range(of: "URI=\"")!.upperBound
        let end = m3u8Data[start...].range(of: "\"")!.lowerBound
        let keyUrl = m3u8Data[start..<end]
        let newKeyUrl = keyUrl.replacingOccurrences(of: "https://", with: "fakekeyhttps://")
        return m3u8Data.replacingOccurrences(
            of: keyUrl,
            with: newKeyUrl
        )
    }
    
    func replaceRelativeVideoChunkUrlsWithAbsoluteUrl(url: URL, m3u8Data: String) -> Data {
        /*
         Since video chunk urls will be relative paths, it will use base url("fakehttps") as its
         host. Urls with scheme "fakehttps" will get intercepted. But we don't need to intercept
         video chunks so we are changing it to correct absolute URL ("https").
         
         Ex: #EXTINF:6, video240p/00000/video240p_00001.ts will be changed to #EXTINF:6 https://video.testpress.in/institute/demo/video240p/00000/video240p_00001.ts
         */
        let baseUrlWithFilenameAndExtension:NSString = url.path as NSString
        let relativeVideoUrl = baseUrlWithFilenameAndExtension.deletingLastPathComponent
        let modifiedData = m3u8Data.replacingOccurrences(
            of: "(#EXTINF:[0-9]*,\n)", with: String(format: "$1 https://%@%@/", url.host!, relativeVideoUrl), options: .regularExpression
        )
        return modifiedData.data(using: .utf8)!
    }
    
    func loadAndStoreEncryptionKey(keyUrl: URL, loadingRequest: AVAssetResourceLoadingRequest) {
        var request = URLRequest(url: keyUrl)
        let token: String = KeychainTokenItem.getToken()
        request.setValue("JWT " + token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { data, response, _ in
            KeychainWrapper.standard.set(data!, forKey: keyUrl.absoluteString)
            self.loadKeyToRequest(loadingRequest: loadingRequest, key: data!)
        }
        task.resume()
    }
    
    func loadKeyToRequest(loadingRequest: AVAssetResourceLoadingRequest, key: Data) {
        loadingRequest.contentInformationRequest?.contentType = AVStreamingKeyDeliveryPersistentContentKeyType
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        loadingRequest.contentInformationRequest?.contentLength = Int64(key.count)
        loadingRequest.dataRequest?.respond(with: key)
        loadingRequest.finishLoading()
    }
}
