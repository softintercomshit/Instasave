import Foundation


extension UITextField {
    func changeClearButton() {
        if let clearButton = self.value(forKey: "_clearButton") as? UIButton {
            clearButton.setImage(#imageLiteral(resourceName: "clear_icon"), for: .normal)
            clearButton.setImage(#imageLiteral(resourceName: "pressed_clear_icon"), for: .highlighted)
        }
    }
}
