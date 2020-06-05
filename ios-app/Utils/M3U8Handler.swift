//
//  M3U8Handler.swift
//  ios-app
//
//  Created by Karthik on 05/06/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation

class M3U8Handler {
    func fetch(url: URL, completion: @escaping(Data, URLResponse?) -> Void) {
        let request = URLRequest(url: URLUtils.convertURLSchemeToHttps(url: url))
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { data, response, _ in
            guard let data = data else { return }
            let cleanedData = self.clean(data: data, baseUrl: url)
            completion(cleanedData, response)
        }
        task.resume()
    }
    
    private func clean(data: Data, baseUrl: URL) -> Data {
        var modifiedData = data
        modifiedData = self.fakeEncryptionKeyURL(m3u8Data: modifiedData)
        modifiedData = self.modifyChunkedVideoURLs(url: baseUrl, m3u8Data: modifiedData)
        return modifiedData
    }
    
    private func fakeEncryptionKeyURL(m3u8Data: Data) -> Data {
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
        return m3u8DataString.data(using: .utf8)!
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
        let modifiedData = m3u8DataString.replacingOccurrences(
            of: "(#EXTINF:[0-9]*,\n)", with: String(format: "$1 https://%@%@/", url.host!, relativeVideoUrl), options: .regularExpression
        )
        return modifiedData.data(using: .utf8)!
    }
    
}
