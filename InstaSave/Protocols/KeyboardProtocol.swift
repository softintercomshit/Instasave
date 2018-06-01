import Foundation
import UIKit

/**
 need to set TextField or TextView frame in textFieldShouldBeginEditing delegate
 example:
     func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let frame = textField.convert(textField.bounds, to: view)
        textFieldFrame = frame
        return true
     }
 */

protocol KeyboardHandlerProtocol {
    var textFieldFrame: CGRect{get set}
}

private var keyboardHandlerClass = KeyboardHandlerClass()
private var keyboardFrame: CGRect?


extension KeyboardHandlerProtocol where Self: UIViewController {
    func startObservingKeyboardChanges() {
        // NotificationCenter observers
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { [weak self] (notification) in
            self?.keyboardWillShow(sender: notification as NSNotification)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { [weak self] (notification) in
            self?.keyboardWillHide(sender: notification as NSNotification)
        }
        
        keyboardHandlerClass.monitorKeyboardHide(view: view)
    }
    
    func stopObservingKeyboardChanges() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func keyboardWillShow(sender: NSNotification) {
        if textFieldFrame == CGRect.zero {return}
        
        let info  = sender.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]! as AnyObject
        
        let rawFrame = value.cgRectValue
        keyboardFrame = view.convert(rawFrame!, from: nil)
        
        adjustView()
    }
    
    func forceAdjustView() {
        if textFieldFrame == CGRect.zero {return}
        adjustView()
    }
    
    private func adjustView() {
        if let keyboardFrame = keyboardFrame {
            if keyboardFrame.intersects(textFieldFrame) {
                let keyboardHeight = keyboardFrame.size.height
                
                var newFrame = view.frame
                newFrame.origin.y = self.view.bounds.height - keyboardHeight - textFieldFrame.origin.y - textFieldFrame.height
                view.frame = newFrame
            }else{
                var newFrame = view.frame
                let newOriginY = textFieldFrame.origin.y + newFrame.origin.y
                
                if textFieldFrame.origin.y + newFrame.origin.y < 0 {
                    newFrame.origin.y -= newOriginY
                    view.frame = newFrame
                }
            }
        }
    }
    
    private func keyboardWillHide(sender: NSNotification) {
        if textFieldFrame == CGRect.zero {return}
        
        var newFrame = view.frame
        newFrame.origin.y = 0
        view.frame = newFrame
    }
}

private class KeyboardHandlerClass: NSObject, UIGestureRecognizerDelegate {
    private var controllerView: UIView?
    
    func monitorKeyboardHide(view: UIView){
        controllerView = view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func hideKeyboard() {
        controllerView?.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Don't handle button taps
        return !(touch.view is UIButton)
    }
}
