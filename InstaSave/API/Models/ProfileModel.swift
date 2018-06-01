import Foundation


private enum ProfileKey: String {
    case username, id, profile_pic_url_hd, profile_pic_url, first_name, last_name, full_name, edge_follow, edge_followed_by, followed_by_viewer
}

private enum TwoFactorKey: String {
    case two_factor_info, obfuscated_phone_number, two_factor_identifier, username
}

public var appProfileModel: ProfileModel?

public struct ProfileModel {
    public var id: String
    public var profile_pic_url: String
    public let username: String
    public let fullName: String
    public let follows: Int
    public let followed_by: Int
    public let followed_by_viewer: Bool
}


public struct TwoFactorAuthModel: Decodable {
    public let obfuscated_phone_number: String
    public let two_factor_identifier: String
    public let username: String
}

extension ProfileModel {
    init(dict: [String: Any]) {
        if let followsDict = dict[ProfileKey.edge_follow] as? [String: Any],
            let followsNumber = followsDict["count"] as? NSNumber {
            
            self.follows = followsNumber.intValue
        } else {
            self.follows = 0
        }
        
        if let followsDict = dict[ProfileKey.edge_followed_by] as? [String: Any],
            let followsNumber = followsDict["count"] as? NSNumber {
            
            self.followed_by = followsNumber.intValue
        } else {
            self.followed_by = 0
        }
        
        self.id = dict[ProfileKey.id] as? String ?? ""
        
        if let profilePicUrl = dict[ProfileKey.profile_pic_url_hd] as? String {
            self.profile_pic_url = profilePicUrl
        } else if let profilePicUrl = dict[ProfileKey.profile_pic_url] as? String {
            self.profile_pic_url = profilePicUrl
        } else {
            self.profile_pic_url = ""
        }
        
        self.username = dict[ProfileKey.username] as? String ?? ""
        self.fullName = dict[ProfileKey.full_name] as? String ?? ""
        
        self.followed_by_viewer = (dict[ProfileKey.followed_by_viewer] as? NSNumber)?.boolValue ?? false
    }
}

extension TwoFactorAuthModel {
    init(dict: [String: Any]) {
        if let two_factor_info = dict[TwoFactorKey.two_factor_info] as? [String: Any],
            let obfuscated_phone_number = two_factor_info[TwoFactorKey.obfuscated_phone_number] as? String,
            let username = two_factor_info[TwoFactorKey.username] as? String,
            let two_factor_identifier = two_factor_info[TwoFactorKey.two_factor_identifier] as? String {
            
            self.username = username
            self.two_factor_identifier =  two_factor_identifier
            self.obfuscated_phone_number = obfuscated_phone_number
        } else {
            self.obfuscated_phone_number = ""
            self.username = ""
            self.two_factor_identifier =  ""
        }
    }
}
