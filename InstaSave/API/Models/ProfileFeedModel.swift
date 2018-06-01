import Foundation


private enum ProfileFeedKey: String {
    case display_url, shortcode, is_video, video_url, owner, taken_at_timestamp, viewer_has_liked, id
}

private enum ProfileFeedOwnerKey: String {
    case full_name, id, profile_pic_url, username
}

public struct FeedModel {
    public let shortcode: String
    public let taken_at_timestamp: Double
    public let owner: FeedModelOwner?
    public let profileMedia: [ProfileMediaModel]
}

public struct FeedModelOwner {
    public let full_name: String
    public let id: String
    public let profile_pic_url: String
    public let username: String
}

public struct ProfileMediaModel {
    public let display_url: String
    public let is_video: Bool
    public let video_url: String?
    public let shortcode: String?
    public let id: String
    public let viewer_has_liked: Bool
}


extension FeedModel: CustomStringConvertible {
    init(dict: [String: Any], display_url: String) {
        self.shortcode = dict[ProfileFeedKey.shortcode] as? String ?? ""
        self.owner = FeedModelOwner(dict: dict[ProfileFeedKey.owner] as? [String: Any])
        self.taken_at_timestamp = (dict[ProfileFeedKey.taken_at_timestamp] as? NSNumber)?.doubleValue ?? 0
        
        if let edge_sidecar_to_children = dict["edge_sidecar_to_children"] as? [String: Any], let edges = edge_sidecar_to_children["edges"] as? [[String: Any]] {
            var profileMediaArray = [ProfileMediaModel]()
            
            for item in edges {
                if let node = item["node"] as? [String: Any] {
                    let profileMediaModel = ProfileMediaModel(dict: node)
                    profileMediaArray.append(profileMediaModel)
                }
            }
            
            self.profileMedia = profileMediaArray
        } else {
            let display_url = dict[ProfileFeedKey.display_url] as? String ?? ""
            let is_video = (dict[ProfileFeedKey.is_video] as? NSNumber)?.boolValue ?? false
            let video_url = dict[ProfileFeedKey.video_url] as? String
            let shortcode = dict[ProfileFeedKey.shortcode] as? String ?? ""
            let id = dict[ProfileFeedKey.id] as? String ?? ""
            let viewer_has_liked = (dict[ProfileFeedKey.viewer_has_liked] as? NSNumber)?.boolValue ?? false
            
            self.profileMedia = [ProfileMediaModel(display_url: display_url,
                                                   is_video: is_video,
                                                   video_url: video_url,
                                                   shortcode: shortcode,
                                                   id: id,
                                                   viewer_has_liked: viewer_has_liked)]
        }
    }
    
    public var description: String {
        return "shortcode ---> \(shortcode)\ntaken_at_timestamp ---> \(taken_at_timestamp)"
    }
}

extension FeedModelOwner {
    init(dict: [String: Any]?) {
        self.full_name = dict?[ProfileFeedOwnerKey.full_name] as? String ?? ""
        self.id = dict?[ProfileFeedOwnerKey.id] as? String ?? ""
        self.profile_pic_url = dict?[ProfileFeedOwnerKey.profile_pic_url] as? String ?? ""
        self.username = dict?[ProfileFeedOwnerKey.username] as? String ?? ""
    }
}

extension ProfileMediaModel: CustomStringConvertible {
    init(dict: [String: Any]) {
        self.display_url = dict[ProfileFeedKey.display_url] as? String ?? ""
        self.is_video = (dict[ProfileFeedKey.is_video] as? NSNumber)?.boolValue ?? false
        self.video_url = dict[ProfileFeedKey.video_url] as? String
        self.shortcode = dict[ProfileFeedKey.shortcode] as? String
        self.id = dict[ProfileFeedKey.id] as? String ?? ""
        self.viewer_has_liked = (dict[ProfileFeedKey.viewer_has_liked] as? NSNumber)?.boolValue ?? false
    }
    
    public var description: String {
        return "display_url ---> \(display_url)\nis_video ---> \(is_video)\nvideo_url ---> \(video_url ?? "nil")\nshortcode ---> \(shortcode ?? "nil")"
    }
}
