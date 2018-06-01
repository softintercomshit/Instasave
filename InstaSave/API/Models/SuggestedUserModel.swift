private enum SuggestedUserKey: String {
    case full_name, id, profile_pic_url, username
}

public struct SuggestedUserModel {
    public let full_name: String
    public let id: String
    public let profile_pic_url: String
    public let username: String
}

extension SuggestedUserModel: CustomStringConvertible {
    init(dict: [String: Any]) {
        full_name = dict[SuggestedUserKey.full_name] as? String ?? ""
        id = dict[SuggestedUserKey.id] as? String ?? ""
        profile_pic_url = dict[SuggestedUserKey.profile_pic_url] as? String ?? ""
        username = dict[SuggestedUserKey.username] as? String ?? ""
    }
    
    public var description: String {
        return "full_name ---> \(full_name)\nid ---> \(id)\nprofile_pic_url ---> \(profile_pic_url)\nusername ---> \(username)\n"
    }
}
