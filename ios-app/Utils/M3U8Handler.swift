//
//  M3U8Handler.swift
//  ios-app
//
//  Created by Karthik on 05/06/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation
import CourseKit

class M3U8Handler {
    func fetch(url: URL, onSuccess: @escaping(Data, URLResponse?) -> Void) {
        let request = URLRequest(url: URLUtils.convertURLSchemeToHttps(url: url))
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { data, response, _ in
            guard let data = data else { return }
            let cleanedData = self.clean(data: data, baseUrl: url)
            onSuccess(cleanedData, response)
        }
        task.resume()
    }
    
    private func clean(data: Data, baseUrl: URL) -> Data {
        var modifiedData = data
        modifiedData = self.fakeEncryptionKeyURL(baseURL:baseUrl, m3u8Data: modifiedData)
        modifiedData = self.modifyChunkedVideoURLs(url: baseUrl, m3u8Data: modifiedData)
        return modifiedData
    }
    
    private func fakeEncryptionKeyURL(baseURL: URL, m3u8Data: Data) -> Data {
        /*
         We are changing schema of the key URL so that we can intercept it.
         */
        var m3u8DataString = String(data: m3u8Data, encoding: .utf8)!
        
        if m3u8DataString.contains("EXT-X-KEY:METHOD=AES-128") {
            let keyUrl = self.getKeyURL(m3u8DataString: m3u8DataString)
            let modifiedKeyURL = self.constructAbsoluteURL(parentURL: baseURL, keyURL: keyUrl).replacingOccurrences(of: "https://", with: "fakekeyhttps://")
            m3u8DataString = m3u8DataString.replacingOccurrences(
                of: keyUrl,
                with: modifiedKeyURL
            )
        }
        return m3u8DataString.data(using: .utf8)!
    }
    
    private func getKeyURL(m3u8DataString: String) -> String{
        let keyURLStartIndex = m3u8DataString.range(of: "URI=\"")!.upperBound
        let keyURLEndIndex = m3u8DataString[keyURLStartIndex...].range(of: "\"")!.lowerBound
        return String(m3u8DataString[keyURLStartIndex..<keyURLEndIndex])
    }
    
    private func constructAbsoluteURL(parentURL: URL, keyURL: String)-> String{
        if keyURL.starts(with: "https://"){
            return keyURL
        }
        
        let relativePath = parentURL.deletingLastPathComponent().relativePath
        let path = relativePath + "/" + keyURL
        return "https://" + parentURL.host! + path
    }
    
    private func modifyChunkedVideoURLs(url: URL, m3u8Data: Data) -> Data {
        /*
         Since video chunk urls will be relative paths, it will use base url("fakehttps") as its
         host. Urls with scheme "fakehttps" will get intercepted. But we don't need to intercept
         video chunks so we are changing it to correct absolute URL ("https").
         
         Ex: #EXTINF:6, video240p/00000/video240p_00001.ts will be changed to #EXTINF:6 https://video.testpress.in/institute/demo/video240p/00000/video240p_00001.ts
         */
        let m3u8DataString = String(data: m3u8Data, encoding: .utf8)!
        let baseUrlWithFilenameAndExtension:NSString = url.path as NSString
        let relativeVideoUrl = baseUrlWithFilenameAndExtension.deletingLastPathComponent
        var modifiedData = m3u8DataString.replacingOccurrences(
            of: "(#EXTINF:[0-9.]*,\n)", with: String(format: "$1 https://%@%@/", url.host!, relativeVideoUrl), options: .regularExpression
        )
        modifiedData = modifiedData.replacingOccurrences(
            of: "#EXT-X-MAP:URI=\"(.*?)\"", with: String(format: "#EXT-X-MAP:URI=\"https://%@%@/%@\"", url.host!, relativeVideoUrl, "$1"), options: .regularExpression
        )
        return modifiedData.data(using: .utf8)!
    }
    
}
