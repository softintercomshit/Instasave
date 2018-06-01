import UIKit


final class TabBarController: UITabBarController, StoryboardInstantiable {

    static var storyboardName: String = TabBarController.identifier
    
    private struct TabBarItem {
        let title: String?
        let image: UIImage?
        let selectedImage: UIImage?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controllers = [HomeController.instantiate(), SearchController.instantiate(), DownloadController.instantiate(), ProfileController.instantiate()]
        
        let tabBarItems = [TabBarItem(title: "Home".localized, image: #imageLiteral(resourceName: "home_icon"), selectedImage: #imageLiteral(resourceName: "pressed_home_icon")),
                           TabBarItem(title: "Search".localized, image: #imageLiteral(resourceName: "search_icon"), selectedImage: #imageLiteral(resourceName: "pressed_search_icon")),
                           TabBarItem(title: "Download".localized, image: #imageLiteral(resourceName: "download_icon"), selectedImage: #imageLiteral(resourceName: "pressed_download_icon")),
                           TabBarItem(title: "Profile".localized, image: #imageLiteral(resourceName: "profile_icon"), selectedImage: #imageLiteral(resourceName: "pressed_profile_icon"))
                           ]
        
        for (idx, controller) in controllers.enumerated() {
            controller.tabBarItem = UITabBarItem(title: tabBarItems[idx].title, image: tabBarItems[idx].image?.original, selectedImage: tabBarItems[idx].selectedImage?.original)
        }
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.appViolet.alpha(0.5)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.appViolet], for: .selected)
        
        viewControllers = controllers
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.appViolet]
        navigationController?.navigationBar.tintColor = .appViolet
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.isTranslucent = false
        
        setNavigationBarShadow()
    }
    
    private func setNavigationBarShadow() {
        navigationController?.navigationBar.layer.masksToBounds = false
        navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.5
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 10.0)
        navigationController?.navigationBar.layer.shadowRadius = 20
    }
}
