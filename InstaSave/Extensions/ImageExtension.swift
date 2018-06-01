import Foundation


extension UIImage {
    var original: UIImage {
        return self.withRenderingMode(.alwaysOriginal)
    }
    
    var template: UIImage {
        return self.withRenderingMode(.alwaysTemplate)
    }
}
