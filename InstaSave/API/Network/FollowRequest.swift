struct FollowRequest {
    static func follow(userId: String, completionHandler: ((_ succes: Bool) -> Void)?) {
        let url = "https://www.instagram.com/web/friendships/" + userId + "/follow/"
        makeRequest(url: url, completionHandler: completionHandler)
    }
    
    static func unfollow(userId: String, completionHandler: ((_ succes: Bool) -> Void)?) {
        let url = "https://www.instagram.com/web/friendships/" + userId + "/unfollow/"
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
