import Foundation


public struct Authorization {
    static private let baseUrl = "https://www.instagram.com/"
    static private let loginUrl = "https://www.instagram.com/accounts/login/ajax/"
    static private let profileInfoUrl = "https://www.instagram.com/accounts/edit/?__a=1"
    
    public static func username(_ username: String, password: String,
                                completionHandler: ((_ userModel: ProfileModel?) -> Void)?,
                                twoFactorCompletion: ((_ twoFactorAuthModel: TwoFactorAuthModel?) -> Void)? ) {
        
        Request.new(path: baseUrl) { (result, error) in
            let requestParams = ["username": username, "password": password]
            Request.new(path: loginUrl, params: requestParams, method: .post, completionHandler: { (result, error) in
                print(result)
                if let dict = result as? [String: Any],
                    let status = dict["status"] as? String {
                    
                    switch status.lowercased() {
                    case "fail":
                        if let two_factor_required = (dict["two_factor_required"] as? NSNumber)?.boolValue {
                            if two_factor_required {
                                let twoFactorAuthModel = TwoFactorAuthModel(dict: dict)
                                DispatchQueue.main.async {
                                    twoFactorCompletion?(twoFactorAuthModel)
                                }
                            }
                        }
                    case "ok":
                        let isAuthenticated = (dict["authenticated"] as? NSNumber)?.boolValue ?? false
                        if isAuthenticated {
                            Request.new(path: profileInfoUrl) { (result, error) in
                                if let dict = result as? [String: Any],
                                    let form_data = dict["form_data"] as? [String: Any],
                                    let username = form_data["username"] as? String {
                                    
                                    UserDefaults.instaUserName = username
                                    isLoggedIn(completionHandler: completionHandler)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                completionHandler?(nil)
                            }
                        }
                    default:
                        DispatchQueue.main.async {
                            completionHandler?(nil)
                        }
                    }
                }
            })
        }
    }
    
    public static func logout(completionHandler: (() -> Void)?) {
        if let cookies = HTTPCookieStorage.shared.cookies(for: URL(string: baseUrl)!) {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        UserDefaults.instaUserName = nil
        UserDefaults.instaCsrftoken = nil
        appProfileModel = nil
        
        DispatchQueue.main.async {
            completionHandler?()
        }
    }
    
    public static func isLoggedIn(completionHandler: ((_ userModel: ProfileModel?) -> Void)?) {
        func sendCallbackWith(userModel: ProfileModel?) {
            DispatchQueue.main.async {
                completionHandler?(userModel)
            }
        }
        
        if let username = UserDefaults.instaUserName {
            let url = "https://www.instagram.com/" + username + "/?__a=1"
            
            Request.new(path: url) { (result, error) in
                if let dict = result as? [String: Any],
                let graphql = dict["graphql"] as? [String: Any],
                    let userDict = graphql["user"] as? [String: Any] {
                    let profileModel = ProfileModel(dict: userDict)
                    UserDefaults.instaUserName = profileModel.username
                    sendCallbackWith(userModel: profileModel)
                } else {
                    sendCallbackWith(userModel: nil)
                }
            }
        } else {
            sendCallbackWith(userModel: nil)
        }
    }
    
    public static func resendSMS(twoFactorAuthModel: TwoFactorAuthModel, completionHandler: ((_ succes: Bool, _ twoFactorAuthModel: TwoFactorAuthModel?) -> Void)?) {
        let url = "https://www.instagram.com/accounts/send_two_factor_login_sms/"
        let params = ["username": twoFactorAuthModel.username, "identifier": twoFactorAuthModel.two_factor_identifier]
        
        Request.new(path: url, params: params, method: .post) { (response, error) in
            func sendCallback(succes: Bool, twoFactorAuthModel: TwoFactorAuthModel?) {
                DispatchQueue.main.async {
                    completionHandler?(false, nil)
                }
            }
            
            guard error == nil else {
                sendCallback(succes: false, twoFactorAuthModel: twoFactorAuthModel)
                return
            }
            
            if let dict = response as? [String: Any] {
                if let two_factor_required = (dict["two_factor_required"] as? NSNumber)?.boolValue {
                    if two_factor_required {
                        let twoFactorAuthModel = TwoFactorAuthModel(dict: dict)
                        sendCallback(succes: true, twoFactorAuthModel: twoFactorAuthModel)
                    } else {
                        sendCallback(succes: false, twoFactorAuthModel: twoFactorAuthModel)
                    }
                } else {
                    sendCallback(succes: false, twoFactorAuthModel: twoFactorAuthModel)
                }
            } else {
                sendCallback(succes: false, twoFactorAuthModel: twoFactorAuthModel)
            }
        }
    }
    
    public static func twoFactorAuth(twoFactorAuthModel: TwoFactorAuthModel, verificationCode: String, completionHandler: ((_ userModel: ProfileModel?) -> Void)?) {
        let url = "https://www.instagram.com/accounts/login/ajax/two_factor/"
        let params = ["username": twoFactorAuthModel.username, "identifier": twoFactorAuthModel.two_factor_identifier, "verificationCode": verificationCode]
        
        Request.new(path: url, params: params, method: .post) { (response, error) in
            func sendCallbackWith(userModel: ProfileModel?) {
                DispatchQueue.main.async {
                    completionHandler?(userModel)
                }
            }
            
            guard error == nil else {
                sendCallbackWith(userModel: nil)
                return
            }
            
            if let dict = response as? [String: Any], let status = dict["status"] as? String {
                switch status.lowercased() {
                case "fail":
                    Alert.show(title: nil, message: dict["message"] as? String)
                    sendCallbackWith(userModel: nil)
                case "ok":
                    let isAuthenticated = (dict["authenticated"] as? NSNumber)?.boolValue ?? false
                    
                    if isAuthenticated {
                        Request.new(path: profileInfoUrl) { (result, error) in
                            if let dict = result as? [String: Any],
                                let form_data = dict["form_data"] as? [String: Any],
                                let username = form_data["username"] as? String {
                                
                                UserDefaults.instaUserName = username
                                isLoggedIn(completionHandler: completionHandler)
                            }
                        }
                    } else {
                        sendCallbackWith(userModel: nil)
                    }
                default:
                    Alert.show(title: nil, message: dict["message"] as? String)
                    sendCallbackWith(userModel: nil)
                }
            } else {
                sendCallbackWith(userModel: nil)
            }
        }
    }
    
    private init(){}
}
