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
            handleM3U8Requests(videoUrl: url, loadingRequest: loadingRequest)
            return true
        } else if url.scheme == "fakekeyhttps" || url.path.contains("encryption_key") {
            handleKeyRequests(videoUrl: url, loadingRequest: loadingRequest)
            return true
        }
        
        return false
    }
    
    func handleKeyRequests(videoUrl: URL, loadingRequest: AVAssetResourceLoadingRequest) {
        var urlComponents = URLComponents(
            url: videoUrl,
            resolvingAgainstBaseURL: false
        )
        urlComponents!.scheme = "https"
        let newUrl = urlComponents!.url!
        
        let key: Data? = KeychainWrapper.standard.data(forKey: newUrl.absoluteString)
        if (key != nil) {
            loadHLSKey(loadingRequest: loadingRequest, key: key!)
        } else {
            loadAndStoreHLSKey(keyUrl: newUrl, loadingRequest: loadingRequest)
        }
    }
    
    func handleM3U8Requests(videoUrl: URL, loadingRequest: AVAssetResourceLoadingRequest) {
        var urlComponents = URLComponents(
            url: videoUrl,
            resolvingAgainstBaseURL: false
        )
        urlComponents!.scheme = "https"
        let newUrl =  urlComponents!.url
        loadAndModifyM3U8(videoUrl: newUrl!, loadingRequest: loadingRequest)
    }
    
    func loadAndModifyM3U8(videoUrl: URL, loadingRequest: AVAssetResourceLoadingRequest) {
        let request = URLRequest(url: videoUrl)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { data, response, _ in
            guard let data = data else { return }
            let m3u8DataString = self.parseAndModifyM3U8Data(m3u8Data: data)
            let modifiedData = self.modifyVideoChunkURL(videoUrl: videoUrl, m3u8Data: m3u8DataString)
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
    
    func modifyVideoChunkURL(videoUrl: URL, m3u8Data: String) -> Data {
        /*
         Since video chunk urls will be relative paths, it will use base url("fakehttps") as its
         host. Urls with scheme "fakehttps" will get intercepted. But we don't need to intercept
         video chunks so we are changing it to correct absolute URL ("https").
         */
        let path:NSString = videoUrl.path as NSString
        let customPath = path.deletingLastPathComponent
        let newKey = m3u8Data.replacingOccurrences(
            of: "(#EXTINF:[0-9]*,\n)", with: String(format: "$1 https://%@%@/", videoUrl.host!, customPath), options: .regularExpression
        )
        return newKey.data(using: .utf8)!
        
    }
    
    func loadAndStoreHLSKey(keyUrl: URL, loadingRequest: AVAssetResourceLoadingRequest) {
        var request = URLRequest(url: keyUrl)
        let token: String = KeychainTokenItem.getToken()
        request.setValue("JWT " + token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { data, response, _ in
            KeychainWrapper.standard.set(data!, forKey: keyUrl.absoluteString)
            self.loadHLSKey(loadingRequest: loadingRequest, key: data!)
        }
        task.resume()
    }
    
    func loadHLSKey(loadingRequest: AVAssetResourceLoadingRequest, key: Data) {
        loadingRequest.contentInformationRequest?.contentType = AVStreamingKeyDeliveryPersistentContentKeyType
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        loadingRequest.contentInformationRequest?.contentLength = Int64(key.count)
        loadingRequest.dataRequest?.respond(with: key)
        loadingRequest.finishLoading()
    }
}
