import Foundation


public struct SuggestionRequest {
    static private let baseUrl = "https://www.instagram.com/graphql/query/"
    
    public static func get(completionHandler: ((_ suggestedUsersArray: [SuggestedUserModel]?) -> Void)?) {
        let params = [
            "query_id": "17889687760069101",
            "variables": "{\"fetch_media_count\":\"0\",\"fetch_suggested_count\":\"50\"}"
        ]
        
        Request.new(path: baseUrl, params: params) { (result, error) in
            let edgesArray = self.edgesArray(result: result)
            let suggestedUsersArray = createSuggestedUsersArray(edgesArray: edgesArray)
            
            DispatchQueue.main.async {
                completionHandler?(suggestedUsersArray)
            }
        }
    }
    
    static private func edgesArray(result: Any?) -> [[String: Any]]? {
        if let dict = result as? [String: Any],
            let data = dict["data"] as? [String: Any],
            let user = data["user"] as? [String: Any],
            let edge_suggested_user = user["edge_suggested_user"] as? [String: Any],
            let edges = edge_suggested_user["edges"] as? [[String: Any]] {
            
            return edges
        }
        
        return nil
    }
    
    static private func createSuggestedUsersArray(edgesArray: [[String: Any]]?) -> [SuggestedUserModel]? {
        
        if let edgesArray = edgesArray {
            var suggestedUsersArray = [SuggestedUserModel]()
            
            edgesArray.forEach { (dict) in
                if let node = dict["node"] as? [String: Any] {
                    let suggestedUser = SuggestedUserModel(dict: node)
                    suggestedUsersArray.append(suggestedUser)
                }
            }
            
            return suggestedUsersArray
        }
        
        return nil
    }
    
    private init(){}
}
