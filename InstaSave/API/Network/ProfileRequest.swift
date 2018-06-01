import Foundation


public struct ProfileRequest {
    static private let baseUrl = "https://www.instagram.com/graphql/query/"
    
    public static func following(cursor: String?, completionHandler: ((_ profilesArray: [ProfileModel]?, _ endCursor: String?) -> Void)?) {
        if let appProfileModel = appProfileModel {
            let params = [
                "query_id": "17874545323001329",
                "variables": "{\"id\":\"" + appProfileModel.id + "\",\"first\":\"20\",\"after\":\"" + (cursor ?? "") + "\"}"
            ]
            
            Request.new(path: baseUrl, params: params) { (result, error) in
                let parsedResult = RequestParser.profileParsedResult(result: result, followKey: "edge_follow")
                
                DispatchQueue.main.async {
                    completionHandler?(parsedResult.profilesArray, parsedResult.endCursor)
                }
            }
        } else {
            print("it can't be!!!!!  where is the profile id???")
        }
    }
    
    public static func followers(cursor: String?, completionHandler: ((_ profilesArray: [ProfileModel]?, _ endCursor: String?) -> Void)?) {
        if let appProfileModel = appProfileModel {
            let params = [
                "query_id": "17851374694183129",
                "variables": "{\"id\":\"" + appProfileModel.id + "\",\"first\":\"20\",\"after\":\"" + (cursor ?? "") + "\"}"
            ]
            
            Request.new(path: baseUrl, params: params) { (result, error) in
                let parsedResult = RequestParser.profileParsedResult(result: result, followKey: "edge_followed_by")
                
                DispatchQueue.main.async {
                    completionHandler?(parsedResult.profilesArray, parsedResult.endCursor)
                }
            }
        } else {
            print("it can't be!!!!!  where is the profile id???")
        }
    }
    
    private init(){}
}
