import Foundation

struct MediaRequest {
    static func new(link: String, completionHandler: ((_ feedModelOwner: FeedModelOwner?, _ mediaUrl: String?, _ isVideo: Bool) -> Void)?) {
        if let url = URL(string: link) {
            let url = "https://www.instagram.com/p/" + url.lastPathComponent + "/?__a=1"
            
            Request.new(path: url) { (response, error) in
                if let dict = response as? [String: Any],
                    let graphql = dict["graphql"] as? [String: Any],
                    let shortcode_media = graphql["shortcode_media"] as? [String: Any] {
                    
                    let is_video = (shortcode_media["is_video"] as? NSNumber)?.boolValue ?? false
                    var mediaUrl: String?
                    
                    if is_video {
                        mediaUrl = shortcode_media["video_url"] as? String
                    } else {
                        mediaUrl = shortcode_media["display_url"] as? String
                    }
                    
                    if let owner = shortcode_media["owner"] as? [String: Any],
                        let id = owner["id"] as? String,
                        let full_name = owner["full_name"] as? String,
                        let username = owner["username"] as? String,
                        let profile_pic_url = owner["profile_pic_url"] as? String {
                        
                        let feedModelOwner = FeedModelOwner(full_name: full_name, id: id, profile_pic_url: profile_pic_url, username: username)
                        DispatchQueue.main.async {
                            completionHandler?(feedModelOwner, mediaUrl!, is_video)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler?(nil, nil, false)
                    }
                }
            }
        }
    }
    
    private init(){}
}
