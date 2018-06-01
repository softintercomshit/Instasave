import UIKit


final class FavoritesController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName: String = FavoritesController.identifier

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let profileModel = appProfileModel {
            navigationController?.navigationBar.topItem?.titleView = nil
            navigationController?.navigationBar.topItem?.title = profileModel.fullName
        }
    }
}
