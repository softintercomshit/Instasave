import Foundation


public struct SearchRequest {
    static private let baseUrl = "https://www.instagram.com/graphql/query/"
    
    public static func search(key: String, completionHandler: ((_ searchModelArray: [SearchUserModel]?) -> Void)?) {
        
        let url = "https://www.instagram.com/web/search/topsearch/"
        let params = [
            "context": "blended",
            "query": formatedKey(key)
        ]
        
        Request.new(path: url, params: params) { (result, error) in
            let usersArray = self.usersArray(result: result)
            let searchModelArray = createSearchUsersArray(usersArray: usersArray)

            DispatchQueue.main.async {
                completionHandler?(searchModelArray)
            }
        }
    }
    
    public static func explore(cursor: String?, completionHandler: ((_ searchModelArray: [SearchUserModel]?, _ endCursor: String?) -> Void)?) {
        
        let params = [
            "query_id": "17863787143139595",
            "variables": "{\"first\":24,\"after\":\"" + (cursor ?? "0") + "\"}"
        ]
        
        Request.new(path: baseUrl, params: params) { (result, error) in
            let parsedResult = RequestParser.searchParsedResult(result: result)
            
            DispatchQueue.main.async {
                completionHandler?(parsedResult.exploreUsersArray, parsedResult.endCursor)
            }
        }
    }
    
    private init(){}
}

extension SearchRequest {
    static private func usersArray(result: Any?) -> [[String: Any]]? {
        if let dict = result as? [String: Any],
            let users = dict["users"] as? [[String: Any]] {
            
            var resultArray = [[String: Any]]()
            
            for item in users {
                if let user = item["user"] as? [String: Any] {
                    let is_private = (user["is_private"] as? NSNumber)?.boolValue ?? true
                    let following = (user["following"] as? NSNumber)?.boolValue ?? false
                    
                    if is_private && !following {
                        continue
                    }
                    resultArray.append(user)
                }
            }
            
            return resultArray
        }
        
        return nil
    }
    
    static fileprivate func createSearchUsersArray(usersArray: [[String: Any]]?) -> [SearchUserModel]? {
        if let usersArray = usersArray {
            var searchUsersArray = [SearchUserModel]()
            
            usersArray.forEach { (dict) in
                let searchUserModel = SearchUserModel(searchDict: dict)
                searchUsersArray.append(searchUserModel)
            }
            
            return searchUsersArray
        }
        
        return nil
    }
    
    static fileprivate func formatedKey(_ key: String) -> String {
        let key = key.trimmingCharacters(in: .whitespaces)
        return key.replacingOccurrences(of: " ", with: "+")
    }
}
