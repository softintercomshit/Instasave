import Foundation


extension UIViewController {
    var identifier: String {
        return String(describing: type(of: self))
    }
}
