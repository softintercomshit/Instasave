import Alamofire

public enum RequestError: Error {
    case unknown
    case networkConection
}

public struct Request {
    public static func new(path: String,
                    params: [String: String]? = nil,
                    method: HTTPMethod = .get,
                    completionHandler: ((_ resposeObject: Any? ,_ error: Error?) -> Void)?) {
        
        guard Alamofire.NetworkReachabilityManager(host: "www.apple.com")?.isReachable == true else {
            Alert.show(title: "Error", message: "Please check your internet connection.")
            completionHandler?(nil, RequestError.networkConection)
            return
        }
        
        let url = URL(string: path)!
        
        switch method {
        case .get:
            RequestUtils.getRequest(url: url, requestParameters: params, completionHandler: completionHandler)
        case .post:
            RequestUtils.postRequest(url: url, requestParameters: params, completionHandler: completionHandler)
        default:
            break
        }
    }
    
    private init(){}
}


final private class RequestUtils {
    
    class func getRequest(url: URL, requestParameters: [String: String]?, completionHandler: ((_ resposeObject: Any? ,_ error: Error?) -> Void)?) {
        
        var requestUrl = url
        if let requestParameters = requestParameters {
            let strUrl = requestUrl.absoluteString + buildQueryString(fromDictionary: requestParameters)
            requestUrl = URL(string: strUrl)!
        }
        
        var request : URLRequest = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        executeRequest(request: request, completionHandler: completionHandler)
    }
    
    class func postRequest(url: URL, requestParameters: [String: String]?, completionHandler: ((_ resposeObject: Any? ,_ error: Error?) -> Void)?) {
        
        var request : URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let requestParameters = requestParameters {
            let postString = String(buildQueryString(fromDictionary: requestParameters).characters.dropFirst())
            request.httpBody = postString.data(using: .utf8)
        }
        
        executeRequest(request: request, completionHandler: completionHandler)
    }
    
    private class func executeRequest(request: URLRequest, completionHandler: ((_ resposeObject: Any? ,_ error: Error?) -> Void)?) {
        var request = request
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        for header in instaHeaders(url: request.url!) {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            
            saveToken(response: response)
            
            if let error = error {
                completionHandler?(nil, error)
            } else {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options: [])
                    completionHandler?(jsonResult, nil)
                } catch let error {
                    if let html = String(data: data!, encoding: String.Encoding.utf8) {
                        if let rhx_gis = html.slice(from: "\"rhx_gis\":\"", to: "\"") {
                            UserDefaults.instaGisToken = rhx_gis
                        }
                        completionHandler?(html, nil)
                    } else {
                        completionHandler?(nil, error)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    private class func buildQueryString(fromDictionary parameters: [String:String]) -> String {
        var urlVars:[String] = []
        
        for (key, value) in parameters {
            if let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                urlVars.append(key + "=" + encodedValue)
            }
        }
        
        return urlVars.isEmpty ? "" : "?" + urlVars.joined(separator: "&")
    }
    
    private class func saveToken(response: URLResponse?) {
        if let httpResponse = response as? HTTPURLResponse, let allHeaderFields = httpResponse.allHeaderFields as? [String : String] {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: (response?.url)!)
            for cookie in cookies {
                if cookie.name == "csrftoken" {
                    UserDefaults.instaCsrftoken = cookie.value
                }
            }
        }
    }
    
    private class func instaHeaders(url: URL!) -> [String: String] {
        var headers = ["Accept-Encoding": "gzip, deflate",
                       "Accept-Language": "en-US;q=0.6,en;q=0.4",
                       "Connection": "keep-alive",
                       "Content-Length": "0",
                       "Host": "www.instagram.com",
                       "Origin": "https://www.instagram.com",
                       "Referer": "https://www.instagram.com/",
                       "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:54.0) Gecko/20100101 Firefox/54.0",
                       "X-Instagram-AJAX": "1",
                       "X-Requested-With": "XMLHttpRequest",
                       "Content-Type": "application/x-www-form-urlencoded",
                       ]
        
        if let csrftoken = UserDefaults.instaCsrftoken {
            headers["X-CSRFToken"] = csrftoken
        }
        
        if let gisToken = UserDefaults.instaGisToken {
            let path = url.path.appending("/")
            headers["X-Instagram-GIS"] = "\(gisToken):\(path)".md5
        }
        
        return headers
    }
}


extension String {
    var md5: String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(lengthOfBytes(using: .utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate()
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
