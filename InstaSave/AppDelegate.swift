import UIKit
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

//        setupFabric()
        setupWindow()
        setupRootController()
        
        return true
    }
    
    private func setupFabric() {
        Fabric.with([Crashlytics.self])
    }
    
    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
    }
    
    private func setupRootController() {
        window?.rootViewController = SplashScreenController.instantiate()
        
        Authorization.isLoggedIn { [weak self] profileModel in
            if let profileModel = profileModel {
                appProfileModel = profileModel
                let navigation = UINavigationController(rootViewController: TabBarController.instantiate())
                self?.window?.rootViewController = navigation
            } else {
                self?.window?.rootViewController = AuthenticationController.instantiate()
            }
        }
    }
    
    func showTabBarController() {
        let navigation = UINavigationController(rootViewController: TabBarController.instantiate())
        self.window?.rootViewController = navigation
    }
    
    func showAuthenticationController() {
        window?.rootViewController = AuthenticationController.instantiate()
    }
}
