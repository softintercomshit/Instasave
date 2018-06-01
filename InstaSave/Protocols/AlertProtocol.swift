import Foundation

protocol AlertProtocol: class {
    func showAlert(title: String?, message: String?)
    func showDevelopmentAlert()
}

extension AlertProtocol where Self: UIViewController {
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String?, message: String?, okAction: (() -> Void)?, cancelAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let cancelAction = cancelAction {
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (alertAction) in
                cancelAction()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            okAction?()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showDevelopmentAlert() {
        let alert = UIAlertController(title: "Warning", message: "This feature is not implemented yet 😕", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
