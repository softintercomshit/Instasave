import UIKit


final class TwoFactorAuthController: UIViewController, StoryboardInstantiable, AlertProtocol {

    static var storyboardName: String = TwoFactorAuthController.identifier
    
    // MARK: - Outlets
    @IBOutlet private weak var confirmButton: UIButton! {
        didSet {
            confirmButton.layer.cornerRadius = 6.0
        }
    }
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    @IBOutlet private weak var securityCodeTextField: UITextField!
    
    
    // MARK: - Global vars
    var twoFactorAuthModel: TwoFactorAuthModel?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        phoneNumberLabel?.text = "\(phoneNumberLabel?.text ?? "") \(twoFactorAuthModel?.obfuscated_phone_number ?? "")."
    }
    
    // MARK: - Buttons actions
    @IBAction func login(_ sender: Any) {
        guard let securityCode = securityCodeTextField.text, !securityCode.isEmpty else {
            showAlert(title: nil, message: "Please enter the security code.")
            return
        }
        
        if let twoFactorAuthModel = twoFactorAuthModel {
            Authorization.twoFactorAuth(twoFactorAuthModel: twoFactorAuthModel, verificationCode: securityCode, completionHandler: { [weak self] profileModel in
                appProfileModel = profileModel
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.showTabBarController()
                    self?.securityCodeTextField.resignFirstResponder()
                }
            })
        }
    }
    
    @IBAction func resendSecurityCode(_ sender: Any) {
        if let twoFactorAuthModel = twoFactorAuthModel {
            Authorization.resendSMS(twoFactorAuthModel: twoFactorAuthModel, completionHandler: { [weak self] (succes, twoFactorAuthModel) in
                self?.twoFactorAuthModel = twoFactorAuthModel
                
                let allertMessage = succes ? "Sms was sent to your phone number." : "Something went wrong, please try again later."
                self?.showAlert(title: nil, message: allertMessage)
            })
        }
    }
}
