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
            M3U8Handler().fetchAndModifyResponse(url: url) { data, response in
                self.handleM3U8Response(loadingRequest: loadingRequest, data: data, response: response)
            }
            return true
        } else if isEncryptionKeyUrl(url: url) {
            EncryptionKeyHandler().getOrFetch(url: url) { data in
                self.handleEncryptionKeyResponse(loadingRequest: loadingRequest, data: data)
            }
            return true
        }
        
        return false
    }
    
    func isEncryptionKeyUrl(url: URL) -> Bool {
        return url.scheme == "fakekeyhttps" || url.path.contains("encryption_key")
    }
    
    func handleM3U8Response(loadingRequest: AVAssetResourceLoadingRequest, data: Data, response:URLResponse?) {
        loadingRequest.contentInformationRequest?.contentType = response?.mimeType
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        loadingRequest.contentInformationRequest?.contentLength = response!.expectedContentLength
        loadingRequest.dataRequest?.respond(with: data)
        loadingRequest.finishLoading()
    }
    
    func handleEncryptionKeyResponse(loadingRequest: AVAssetResourceLoadingRequest, data: Data) {
        loadingRequest.contentInformationRequest?.contentType = AVStreamingKeyDeliveryPersistentContentKeyType
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        loadingRequest.contentInformationRequest?.contentLength = Int64(data.count)
        loadingRequest.dataRequest?.respond(with: data)
        loadingRequest.finishLoading()
    }
}


class M3U8Handler {
    func fetchAndModifyResponse(url: URL, completion: @escaping(Data, URLResponse?) -> Void) {
        let request = URLRequest(url: URLUtils.convertURLSchemeToHttps(url: url))
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { data, response, _ in
            guard let data = data else { return }
            let m3u8DataString = self.modifyKeyURLToFakeHttps(m3u8Data: data)
            let modifiedData = self.replaceRelativeVideoChunkUrlsWithAbsoluteUrl(url: url, m3u8Data: m3u8DataString)
            completion(modifiedData, response)
        }
        task.resume()
    }
    
    
    private func modifyKeyURLToFakeHttps(m3u8Data: Data) -> String {
        /*
         We are changing schema of the key URL so that we can intercept it.
         */
        var m3u8DataString = String(data: m3u8Data, encoding: .utf8)!
        
        if m3u8DataString.contains("EXT-X-KEY") {
            let keyURLStartIndex = m3u8DataString.range(of: "URI=\"")!.upperBound
            let keyURLEndIndex = m3u8DataString[keyURLStartIndex...].range(of: "\"")!.lowerBound
            let keyUrl = m3u8DataString[keyURLStartIndex..<keyURLEndIndex]
            let modifiedKeyURL = keyUrl.replacingOccurrences(of: "https://", with: "fakekeyhttps://")
            m3u8DataString = m3u8DataString.replacingOccurrences(
                of: keyUrl,
                with: modifiedKeyURL
            )
        }
        return m3u8DataString
    }
    
    private func replaceRelativeVideoChunkUrlsWithAbsoluteUrl(url: URL, m3u8Data: String) -> Data {
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
    
}


class EncryptionKeyHandler {
    func getOrFetch(url: URL, onSuccess: @escaping(Data) -> Void) {
        let encryptionKeyUrl = URLUtils.convertURLSchemeToHttps(url: url)
        let key: Data? = getKeyFromCache(url: encryptionKeyUrl.absoluteString)
        
        if (key != nil) {
            onSuccess(key!)
        } else {
            fetch(url: encryptionKeyUrl) { _ in
                onSuccess(self.getKeyFromCache(url: encryptionKeyUrl.absoluteString)!)
            }
        }
    }
    
    private func getKeyFromCache(url: String) -> Data? {
        return KeychainWrapper.standard.data(forKey: url)
    }
    
    private func storeKeyToCache(url: String, key: Data) {
        KeychainWrapper.standard.set(key, forKey: url)
    }
    
    private func fetch(url: URL, onSuccess: @escaping(Data) -> Void) {
        var request = URLRequest(url: url)
        request.setValue("JWT " + KeychainTokenItem.getToken(), forHTTPHeaderField: "Authorization")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { data, response, _ in
            guard let key = data else { return }
            self.storeKeyToCache(url: url.absoluteString, key: key)
            onSuccess(key)
        }
        task.resume()
    }
}
