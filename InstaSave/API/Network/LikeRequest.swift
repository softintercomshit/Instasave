struct LikeRequest {
    static func like(mediaId: String, completionHandler: ((_ succes: Bool) -> Void)?) {
        let url = "https://www.instagram.com/web/likes/" + mediaId + "/like/"
        makeRequest(url: url, completionHandler: completionHandler)
    }
    
    static func unlike(mediaId: String, completionHandler: ((_ succes: Bool) -> Void)?) {
        let url = "https://www.instagram.com/web/likes/" + mediaId + "/unlike/"
        makeRequest(url: url, completionHandler: completionHandler)
    }
    
    static private func makeRequest(url: String, completionHandler: ((_ succes: Bool) -> Void)?) {
        Request.new(path: url, params: nil, method: .post) { (response, error) in
            guard error == nil else {
                completionHandler?(false)
                return
            }
            
            if let dict = response as? [String: Any] {
                if let status = dict["status"] as? String, status.lowercased() == "ok" {
                    completionHandler?(true)
                } else {
                    completionHandler?(false)
                }
            }
        }
    }
    
    private init(){}
}
