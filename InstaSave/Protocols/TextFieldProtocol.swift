import Foundation
import UIKit


protocol TextFieldProtocol {}

extension TextFieldProtocol {
    func handleTextfieldsKeyboard<T>(textFields: Array<T>) {
        let accessoryView = Bundle.main.loadNibNamed("KeyboardAccessoryView", owner: self, options: nil)?.first as? KeyboardAccessoryView
        accessoryView?.textfields = textFields
    }
}
