import Foundation


public struct UserNameRequest {
    public static func new(shortCode: String, completionHandler: ((_ userName: String) -> Void)?) {
        let url = "https://www.instagram.com/p/" + shortCode + "/?__a=1"
        
        Request.new(path: url) { (response, error) in
            if let dict = response as? [String: Any],let graphql = dict["graphql"] as? [String: Any], let shortcode_media = graphql["shortcode_media"] as? [String: Any], let owner = shortcode_media["owner"] as? [String: Any] {
                
                var name = ""
                if let full_name = owner["full_name"] as? String {
                    name = full_name
                } else if let username = owner["username"] as? String{
                    name = username
                }
                
                DispatchQueue.main.async {
                    completionHandler?(name)
                }
            }
        }
    }
    
    private init(){}
}
