import Alamofire


public struct DownloadVideo {
    public static func url(_ url: URL, completionHandler: ((_ progress: Float, _ path: URL?) -> ())?) {
        guard Alamofire.NetworkReachabilityManager(host: "www.apple.com")?.isReachable == true else {
            Alert.show(title: "Error", message: "Please check your internet connection.")
            return
        }
        
        let destination = DownloadRequest.suggestedDownloadDestination()
        
        Alamofire.download(url.absoluteString, to: destination).response{ response in
            DispatchQueue.main.async {
                completionHandler?(1.0, response.destinationURL)
            }
            
            }.downloadProgress { (progress) in
                DispatchQueue.main.async {
                    let progress = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                    completionHandler?(progress, nil)
                }
        }
    }
    
    private init(){}
}
