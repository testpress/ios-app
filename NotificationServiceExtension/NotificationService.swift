//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Testpress on 18/11/26.
//  Copyright © 2026 Testpress. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        let userInfo = request.content.userInfo
        let imageUrlString = (userInfo["image_url"] as? String) ?? (userInfo["gcm.notification.image_url"] as? String)

        guard let validImageUrlString = imageUrlString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !validImageUrlString.isEmpty,
              let imageUrl = URL(string: validImageUrlString) else {
            contentHandler(bestAttemptContent)
            return
        }

        downloadAttachment(from: imageUrl) { [weak self] attachment in
            if let attachment = attachment {
                bestAttemptContent.attachments = [attachment]
            }
            self?.contentHandler?(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    func downloadAttachment(from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { temporaryFileUrl, response, error in
            guard let temporaryFileUrl = temporaryFileUrl, error == nil else {
                completion(nil)
                return
            }

            var fileExtension = url.pathExtension.trimmingCharacters(in: .whitespacesAndNewlines)
            if fileExtension.isEmpty {
                if let mimeType = response?.mimeType?.lowercased() {
                    switch mimeType {
                    case "image/jpeg", "image/jpg":
                        fileExtension = "jpg"
                    case "image/png":
                        fileExtension = "png"
                    case "image/gif":
                        fileExtension = "gif"
                    case "image/webp":
                        fileExtension = "webp"
                    default:
                        fileExtension = "jpg"
                    }
                } else {
                    fileExtension = "jpg"
                }
            }

            let destinationFileName = UUID().uuidString + "." + fileExtension
            let destinationUrl = FileManager.default.temporaryDirectory.appendingPathComponent(destinationFileName)

            do {
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    try? FileManager.default.removeItem(at: destinationUrl)
                }
                try FileManager.default.moveItem(at: temporaryFileUrl, to: destinationUrl)
                let attachment = try UNNotificationAttachment(identifier: "campaign_image", url: destinationUrl, options: nil)
                completion(attachment)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
}
