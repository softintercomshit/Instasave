import Foundation


private enum UserKey: String {
    case is_video, thumbnail_src, full_name, username, pk, profile_pic_url, shortcode, following
}

public struct SearchUserModel {
    public let id: String
    public let thumbnail_src: String
    public let is_video: Bool
    public let username: String?
    public let full_name: String?
    public let shortcode: String?
    public let following: Bool
}

extension SearchUserModel: CustomStringConvertible {
    init(exploreDict: [String: Any], id: String) {
        self.id = id
        self.is_video = (exploreDict[UserKey.is_video] as? NSNumber)?.boolValue ?? false
        self.thumbnail_src = exploreDict[UserKey.thumbnail_src] as? String ?? ""
        self.shortcode = exploreDict[UserKey.shortcode] as? String
        self.username = nil
        self.full_name = nil
        self.following = false
    }
    
    init(searchDict: [String: Any]) {
        self.id = searchDict[UserKey.pk] as? String ?? ""
        self.is_video = false
        self.thumbnail_src = searchDict[UserKey.profile_pic_url] as? String ?? ""
        self.username = searchDict[UserKey.username] as? String
        self.full_name = searchDict[UserKey.full_name] as? String
        self.shortcode = nil
        self.following = (searchDict[UserKey.following] as? NSNumber)?.boolValue ?? false
    }
    
    public var description: String {
        guard full_name != nil else {
            return "id ---> \(id)\nis_video ---> \(is_video)\nthumbnail_src ---> \(thumbnail_src)\nshortcode ---> \(shortcode ?? "nil")"
        }
        
        return "id ---> \(id)\nis_video ---> \(is_video)\nthumbnail_src ---> \(thumbnail_src)\nusername ---> \(username ?? "nil")\nfull_name ---> \(full_name ?? "nil")"
    }
}
