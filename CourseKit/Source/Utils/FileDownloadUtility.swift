import UIKit


public class FileDownloadUtility: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    public static let shared = FileDownloadUtility()
    
    private var session: URLSession!
    private var downloadTask: URLSessionDownloadTask?
    private var downloadCompletionHandler: ((URL?, Error?) -> Void)?
    private var alertController: UIAlertController?
    private weak var presentingViewController: UIViewController?
    private var fileName: String?
    
    private override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        alertController = UIUtils.initProgressDialog(message: "Downloading..." + "\n\n")
    }
    
    public func downloadFile(
        viewController: UIViewController,
        from url: URL,
        fileName: String? = nil,
        completion: @escaping (URL?, Error?) -> Void
    ) {
        let request = URLRequest(url: url)
        downloadFile(viewController: viewController, from: request, fileName: fileName, completion: completion)
    }

    public func downloadFile(
        viewController: UIViewController,
        from urlRequest: URLRequest,
        fileName: String? = nil,
        completion: @escaping (URL?, Error?) -> Void
    ) {
        self.fileName = fileName
        presentingViewController = viewController
        presentingViewController?.present(alertController!, animated: true, completion: nil)
        
        downloadTask?.cancel()
        startDownloadTask(from: urlRequest, completion: completion)
    }
        
    private func startDownloadTask(from urlRequest: URLRequest, completion: @escaping (URL?, Error?) -> Void) {
        self.downloadCompletionHandler = completion
        downloadTask = session.downloadTask(with: urlRequest)
        downloadTask?.resume()
    }
    
    // MARK: - URLSessionDownloadDelegate methods
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let downloadedUrl = downloadTask.originalRequest?.url else {
            handleDownloadCompletion(nil, NSError(domain: "FileDownloadUtility", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to determine destination URL"]), completion: downloadCompletionHandler)
            return
        }
                
        let destinationPath = generateUniqueDestinationPath(downloadedUrl: downloadedUrl)
        
        do {
            try FileManager.default.moveItem(at: location, to: destinationPath)
            handleDownloadCompletion(destinationPath, nil, completion: downloadCompletionHandler)
        } catch {
            handleDownloadCompletion(nil, error, completion: downloadCompletionHandler)
        }
    }
    
    func generateUniqueDestinationPath(downloadedUrl: URL) -> URL {
        let filename = fileName ?? downloadedUrl.lastPathComponent
        let downloadsPath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        var uniqueFilename = filename
        var filePath = downloadsPath.appendingPathComponent(uniqueFilename)
        var counter = 1
        
        while FileManager.default.fileExists(atPath: filePath.path) {
            let fileExtension = (filename as NSString).pathExtension
            let fileNameWithoutExtension = (filename as NSString).deletingPathExtension
            uniqueFilename = "\(fileNameWithoutExtension)_\(counter).\(fileExtension)"
            filePath = downloadsPath.appendingPathComponent(uniqueFilename)
            counter += 1
        }
        
        return filePath
    }
    
    func presentActivityViewController(with fileURL: URL) {
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = presentingViewController?.view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(
            x: presentingViewController!.view.bounds.maxX,
            y: presentingViewController!.view.bounds.minY,
            width: 0, height: 0)
        activityViewController.popoverPresentationController?.permittedArrowDirections = [.up, .right]

        presentingViewController!.present(activityViewController, animated: true, completion: nil)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.dismissProgressDialog() {
                    let errorMessage: String
                    switch error {
                    case URLError.notConnectedToInternet:
                        errorMessage = "No internet connection."
                    case URLError.networkConnectionLost:
                        errorMessage = "Network connection lost."
                    case URLError.cannotFindHost, URLError.cannotConnectToHost:
                        errorMessage = "Cannot connect to the server."
                    default:
                        errorMessage = "An error occurred: \(error.localizedDescription)"
                    }
                    self.downloadCompletionHandler?(nil, NSError(domain: "FileDownloadUtility", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let percentage = Int(progress * 100)
        
        DispatchQueue.main.async {
            self.dismissProgressDialog(){
                self.alertController!.message = "Downloaded: \(percentage)%\n\n"
            }
        }
    }
    
    private func handleDownloadCompletion(_ url: URL?, _ error: Error?, completion: ((URL?, Error?) -> Void)?) {
        DispatchQueue.main.async {
            self.dismissProgressDialog(){
                self.fileName = nil    
                if let url = url {
                    self.presentActivityViewController(with: url)
                }
                completion?(url, error)
            }
        }
    }
    
    private func dismissProgressDialog(completion: (() -> Void)? = nil) {
        self.alertController?.dismiss(animated: true, completion: completion)
    }
}
