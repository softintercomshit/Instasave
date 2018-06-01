import Foundation


extension AuthenticationController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var frame = textField.convert(textField.bounds, to: view)
        frame.origin.y += 50
        textFieldFrame = frame
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == urlTextField {
            if let text = textField.text, !text.isEmpty {
                downloadController = DownloadController.instantiate()
                downloadController?.initialUrl = textField.text
                let navController = UINavigationController(rootViewController: downloadController!)
                navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
                navController.navigationBar.shadowImage = UIImage()
                
                navController.navigationBar.tintColor = .appViolet
                let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissDownloadController))
                navController.navigationBar.topItem?.leftBarButtonItem = doneButton
                
                present(navController, animated: true, completion: nil)
            }
        } else {
            logIn()
        }
        
        return true
    }
    
    @objc private func dismissDownloadController() {
        downloadController?.dismiss(animated: true, completion: nil)
    }
}
