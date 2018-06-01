import Foundation


struct RequestParser {
    static func feedParsedData(result: Any?, key: String) -> (edges: [[String: Any]]?, endCursor: String?) {
        if let data = result as? [String: Any],
            let userDict = self.userDict(dict: data),
            let timeline_media = userDict[key] as? [String: Any],
            let page_info = timeline_media["page_info"] as? [String: Any],
            let edges = timeline_media["edges"] as? [[String: Any]] {
            
            updateAppUserModel(userDict: userDict)
            let endCursor = self.endCursor(pageInfo: page_info)
            
            return (edges, endCursor)
        }
        
        return (nil, nil)
    }
    
    static func searchParsedResult(result: Any?) -> (endCursor: String?, exploreUsersArray: [SearchUserModel]?) {
        if let data = result as? [String: Any],
            let userDict = self.userDict(dict: data),
            let edge_web_discover_media = userDict["edge_web_discover_media"] as? [String: Any],
            let page_info = edge_web_discover_media["page_info"] as? [String: Any],
            let edges = edge_web_discover_media["edges"] as? [[String: Any]] {
            
            let endCursor = RequestParser.endCursor(pageInfo: page_info)
            let exploreUsersArray = self.createExploreUsersArray(edgesArray: edges)
            
            return (endCursor, exploreUsersArray)
        }
        
        return (nil, nil)
    }
    
    static func profileParsedResult(result: Any?, followKey: String) -> (endCursor: String?, profilesArray: [ProfileModel]?) {
        if let data = result as? [String: Any],
            let userDict = self.userDict(dict: data),
            let edge_follow = userDict[followKey] as? [String: Any],
            let page_info = edge_follow["page_info"] as? [String: Any],
            let edges = edge_follow["edges"] as? [[String: Any]] {
            
            let endCursor = self.endCursor(pageInfo: page_info)
            let profilesArray = self.profilesArray(edges: edges)
            
            return (endCursor, profilesArray)
        }
        
        return(nil, nil)
    }
    
    private init(){}
}

extension RequestParser {
    static private func userDict(dict: [String: Any]?) -> [String: Any]? {
        if let dict = dict as NSDictionary?,
            let userDict = dict.value(forKeyPath: "data.user") as? [String: Any] {
            
            return userDict
        }
        
        return nil
    }
    
    static private func profilesArray(edges: [[String: Any]]) -> [ProfileModel]? {
        var profilesArray = [ProfileModel]()
        
        for item in edges {
            if let node = item["node"] as? [String: Any] {
                let profileModel = ProfileModel(dict: node)
                profilesArray.append(profileModel)
            }
        }
        
        return profilesArray.isEmpty ? nil : profilesArray
    }
    
    static private func createExploreUsersArray(edgesArray: [[String: Any]]?) -> [SearchUserModel]? {
        if let edgesArray = edgesArray {
            var searchUsersArray = [SearchUserModel]()
            
            edgesArray.forEach { (dict) in
                if let node = dict["node"] as? [String: Any], let owner = node["owner"] as? [String: Any], let id = owner["id"] as? String {
                    let exploreUserModel = SearchUserModel(exploreDict: node, id: id)
                    searchUsersArray.append(exploreUserModel)
                }
            }
            
            return searchUsersArray
        }
        
        return nil
    }
    
    static private func endCursor(pageInfo: [String: Any]?) -> String? {
        if let pageInfo = pageInfo {
            let has_next_page = (pageInfo["has_next_page"] as? NSNumber)?.boolValue ?? false
            if has_next_page {
                if let end_cursor = pageInfo["end_cursor"] as? String {
                    return end_cursor
                }
            }
        }
        
        return nil
    }
    
    static private func updateAppUserModel(userDict: [String: Any]) {
        if let id = userDict["id"] as? String,
            let profile_pic_url = userDict["profile_pic_url"] as? String {
            appProfileModel?.id = id
            appProfileModel?.profile_pic_url = profile_pic_url
        }
    }
}

