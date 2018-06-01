import UIKit
import MediaPlayer


final class AuthenticationController: UIViewController, StoryboardInstantiable, TextFieldProtocol, KeyboardHandlerProtocol, PreviewMediaProtocol, AlertProtocol {
    
    
    static var storyboardName: String = AuthenticationController.identifier
    var textFieldFrame: CGRect = CGRect.zero
    
    // MARK: - Outlets
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet private weak var visualEfect: UIVisualEffectView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private var userTextFields: [UITextField]! {
        didSet {
            handleTextfieldsKeyboard(textFields: userTextFields)
            _ = userTextFields.map{textFieldSetWhitePlaceholder($0)}
        }
    }
    @IBOutlet private weak var signinButton: UIButton! {
        didSet {
            signinButton?.layer.shadowColor = UIColor.black.alpha(0.5).cgColor
            signinButton?.layer.shadowOffset = CGSize(width: 0, height: 2)
            signinButton?.layer.shadowOpacity = 0.5
            signinButton?.layer.shadowRadius = 5
            signinButton?.layer.masksToBounds = false
        }
    }
    
    @IBOutlet weak var urlTextField: UITextField! {
        didSet {
            urlTextField.attributedPlaceholder = NSAttributedString(string: urlTextField.placeholder ?? "",
                                                                    attributes: [NSAttributedStringKey.foregroundColor: UIColor.appViolet.alpha(0.5)])
            urlTextField.changeClearButton()
        }
    }
    @IBOutlet private weak var userNameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    // MARK: - Global vars
    var downloadController: DownloadController?
    var infoImageViews = [UIImageView]()
    private lazy var scrollViewDispatchOnce: Void = {
        setUpScrollView()
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startObservingKeyboardChanges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = scrollViewDispatchOnce
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopObservingKeyboardChanges()
    }
    
    // MARK: - Buttons action
    @IBAction private func loginButtonAction(_ sender: Any) {
        logIn()
    }
    
    @IBAction func showInfoController(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.visualEfect.alpha = 1
        }) { (finish) in
            self.addAnimation(page: self.pageControl.currentPage)
        }
    }
    
    @IBAction func hideInfoView(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.visualEfect.alpha = 0
        }) { (finish) in
            self.clearInitialAnimation()
        }
    }
    
    func logIn() {
        guard let username = userNameTextField.text, !username.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
                showAlert(title: nil, message: "Please enter credentials.")
                
                return
        }
        
        Authorization.username(username, password: password, completionHandler: { [weak self] profileModel in
            if let profileModel = profileModel {
                appProfileModel = profileModel
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.showTabBarController()
                }
            } else {
                self?.showAlert(title: nil, message: "Wrong credentials.")
            }
        }, twoFactorCompletion: { [weak self] twoFactorAuthModel in
            let twoFactorAuthController = TwoFactorAuthController.instantiate()
            twoFactorAuthController.twoFactorAuthModel = twoFactorAuthModel
            self?.present(twoFactorAuthController, animated: true, completion: nil)
        })
    }
    
    private func textFieldSetWhitePlaceholder(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.white.alpha(0.9).cgColor
        textField.layer.cornerRadius = 6
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "",
                                                             attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.alpha(0.5)])
    }
}
