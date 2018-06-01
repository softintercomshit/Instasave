import Foundation

extension UserDefaults {
    class var instaUserName: String? {
        get {
            return self.standard.object(forKey: #function) as? String
        }
        
        set {
            if let username = newValue {
                self.standard.set(username, forKey: #function)
            } else {
                self.standard.removeObject(forKey: #function)
            }
            self.standard.synchronize()
        }
    }
    
    class var instaCsrftoken: String? {
        get {
            return self.standard.object(forKey: #function) as? String
        }
        
        set {
            if let csrftoken = newValue {
                self.standard.set(csrftoken, forKey: #function)
            } else {
                self.standard.removeObject(forKey: #function)
            }
            self.standard.synchronize()
        }
    }
    
    class var instaGisToken: String? {
        get {
            return self.standard.object(forKey: #function) as? String
        }
        
        set {
            if let gisToken = newValue {
                self.standard.set(gisToken, forKey: #function)
            } else {
                self.standard.removeObject(forKey: #function)
            }
            self.standard.synchronize()
        }
    }
}
