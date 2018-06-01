import Foundation


public struct FeedRequest {
    static private let baseUrl = "https://www.instagram.com/graphql/query/"
    
    public static func profileFeed(cursor: String?, completionHandler: ((_ feedModelArray: [FeedModel]?, _ endCursor: String?) -> Void)?) {
        
        let params = [
            "query_id": "17883061807121903",
            "variables": "{\"fetch_media_item_count\":12,\"fetch_media_item_cursor\":\"" + (cursor ?? "") + "\",\"fetch_comment_count\":4,\"fetch_like\":10}"
            ]
        
        Request.new(path: baseUrl, params: params) { (result, error) in
            let parsedData = RequestParser.feedParsedData(result: result, key: "edge_web_feed_timeline")
            let userFeedModelArray = createProfileFeedModel(edges: parsedData.edges)
            
            DispatchQueue.main.async {
                completionHandler?(userFeedModelArray, parsedData.endCursor)
            }
        }
    }
    
    public static func userFeed(userId: String, cursor: String?, completionHandler: ((_ feedModelArray: [FeedModel]?, _ endCursor: String?) -> Void)?) {
        
        let params = [
            "query_id": "17888483320059182",
            "variables": "{\"id\":" + userId + ",\"first\":\"12\",\"after\":\"" + (cursor ?? "") + "\"}"
        ]
        
        Request.new(path: baseUrl, params: params) { (result, error) in
            let parsedData = RequestParser.feedParsedData(result: result, key: "edge_owner_to_timeline_media")
            
            createUserFeedModel(edges: parsedData.edges, completionHandler: { (feedModelArray) in
                DispatchQueue.main.async {
                    let feedModelArray = feedModelArray?.sorted(by: {$0.taken_at_timestamp > $1.taken_at_timestamp})
                    completionHandler?(feedModelArray, parsedData.endCursor)
                }
            })
        }
    }
    
    private init(){}
}

extension FeedRequest {    
    static fileprivate func createProfileFeedModel(edges: [[String: Any]]?) -> [FeedModel]? {
        guard edges != nil  else {
            return nil
        }
        
        var userFeedArray = [FeedModel]()
        for edge in edges! {
            if let node = edge["node"] as? [String: Any], let display_url = node["display_url"] as? String {
                let profileFeed = FeedModel(dict: node, display_url: display_url)
                userFeedArray.append(profileFeed)
            }
        }
        
        return userFeedArray
    }
    
    static fileprivate func createUserFeedModel(edges: [[String: Any]]?, completionHandler: ((_ feedModel: [FeedModel]?) -> Void)?) {
        if let edges = edges {
            var userFeedArray = [FeedModel]()
            
            guard !edges.isEmpty else {
                completionHandler?(nil)
                return
            }
            
            for edge in edges {
                if let node = edge["node"] as? [String: Any], let display_url = node["display_url"] as? String {
                    if let typename = node["__typename"] as? String, typename == "GraphSidecar",
                        let shortcode = node["shortcode"] as? String {
                        let strUrl = "https://www.instagram.com/p/" + shortcode + "/?__a=1"
                        
                        graphSidecarFeed(url: strUrl, display_url: display_url, completionHandler: { (feedModel) in
                            userFeedArray.append(feedModel)
                            
                            if userFeedArray.count == edges.count {
                                completionHandler?(userFeedArray)
                            }
                        })
                    } else {
                        if let shortcode = node["shortcode"] as? String {
                            let url = "https://www.instagram.com/p/" + shortcode + "/?__a=1"
                            
                            graphSidecarFeed(url: url, display_url: display_url, completionHandler: { (feedModel) in
                                userFeedArray.append(feedModel)
                                
                                if userFeedArray.count == edges.count {
                                    completionHandler?(userFeedArray)
                                }
                            })
                        }
                    }
                }
            }
        } else {
            completionHandler?(nil)
        }
    }
    
    static private func graphSidecarFeed(url: String, display_url: String, completionHandler: ((_ feedModel: FeedModel) -> Void)?) {
        Request.new(path: url, completionHandler: { (result, error) in
            if let dict = result as? [String: Any],
                let graphql = dict["graphql"] as? [String: Any],
                let shortcode_media = graphql["shortcode_media"] as? [String: Any] {
                
                let userFeedModel = FeedModel(dict: shortcode_media, display_url: display_url)
                completionHandler?(userFeedModel)
            }
        })
    }
}
