import Foundation


struct Alert {
    static func show(title: String?, message: String?, okAction: (() -> Void)? = nil, cancelAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let cancelAction = cancelAction {
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (alertAction) in
                cancelAction()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            okAction?()
        }))
        
        presentAlert(alert)
    }
    
    private static func presentAlert(_ alert: UIAlertController) {
        if let window = UIApplication.shared.keyWindow,
            let rootController = window.rootViewController {
            
            if let presentedViewController = rootController.presentedViewController {
                if !(presentedViewController is UIAlertController) {
                    DispatchQueue.main.async {
                        presentedViewController.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    rootController.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private init(){}
}
