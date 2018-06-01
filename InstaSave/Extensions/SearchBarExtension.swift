import Foundation


extension UISearchBar {
    func costumize(placeholder: String) {
        self.searchBarStyle = .minimal
        self.tintColor = .appViolet
        self.setImage(#imageLiteral(resourceName: "clear_icon"), for: .clear, state: .normal)
        self.setImage(#imageLiteral(resourceName: "pressed_clear_icon"), for: .clear, state: .highlighted)
        
        if let searchTextField = self.value(forKey: "searchField") as? UITextField {
            if searchTextField.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
                let attributeDict = [NSAttributedStringKey.foregroundColor: UIColor.appViolet.alpha(0.5)]
                searchTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributeDict)
                searchTextField.textColor = UIColor.appViolet
            }
            
            if let imageView = searchTextField.leftView as? UIImageView {
                imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = UIColor.appViolet.alpha(0.5)
            }
            
            searchTextField.layer.borderWidth = 1.0
            searchTextField.layer.borderColor = UIColor.appViolet.alpha(0.5).cgColor
            searchTextField.layer.cornerRadius = 8.0
            
            searchTextField.borderStyle = .none
        }
    }
}
