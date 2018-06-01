import UIKit


final class HomeController: UIViewController, StoryboardInstantiable {

    static var storyboardName: String = HomeController.identifier
    
    // MARK: - Outlets
    @IBOutlet private weak var feedTableView: UITableView!
    @IBOutlet private weak var noFeedlabel: UILabel!
    
    // MARK: - Global vars
    internal var profileFeedArray: [FeedModel]?
    private let refreshControl = UIRefreshControl()
    private var endCursor: String?
    fileprivate var defaultTableViewHeight: CGFloat?
    
    // MARK: - Lyfe cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView(feedTableView)
        addRefreshControl()
        addInfiniteScroll()
        fetchFeed(cursor: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let appProfileModel = appProfileModel {
            navigationController?.navigationBar.topItem?.titleView = nil
            navigationController?.navigationBar.topItem?.title = appProfileModel.fullName
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let feedTableView = feedTableView {
            defaultTableViewHeight = feedTableView.frame.height
        }
    }
    
    private func fetchFeed(cursor: String?, removeObjects: Bool = false) {
        FeedRequest.profileFeed(cursor: cursor) {[weak self] (profileFeedArray, endCursor) in
            self?.endCursor = endCursor
            
            guard profileFeedArray != nil else {
                self?.profileFeedArray = [FeedModel]()
                self?.stopRefresh()
                self?.hideLoaderAnimationAndReloadData()
                self?.feedTableView.backgroundView = self?.noFeedlabel
                return
            }
            
            if let profileFeedArray = profileFeedArray {
                
                guard profileFeedArray.first?.profileMedia.first?.display_url != self?.profileFeedArray?.first?.profileMedia.first?.display_url else {
                    self?.endCursor = nil
                    self?.stopRefresh()
                    return
                }
                
                removeObjects ? self?.profileFeedArray?.removeAll() : ()
                self?.appendDataFromResponse(profileFeedArray)
                self?.hideLoaderAnimationAndReloadData()
            } else {
                
            }
            
            self?.stopRefresh()
        }
    }
    
    private func appendDataFromResponse(_ responseArray: [FeedModel]) {
        if var array = profileFeedArray {
            array.append(contentsOf: responseArray)
            profileFeedArray = array
        } else {
            profileFeedArray = responseArray
        }
    }
    
    private func stopRefresh() {
        refreshControl.endRefreshing()
        feedTableView.finishInfiniteScroll()
    }
    
    private func hideLoaderAnimationAndReloadData() {
        feedTableView.hideLoader()
        feedTableView.reloadData()
        if let defaultTableViewHeight = defaultTableViewHeight {
            setTableViewHeight(feedTableView, height: defaultTableViewHeight)
            self.defaultTableViewHeight = nil
        }
    }
    
    // MARK: - Refresh control
    private func addRefreshControl() {
        refreshControl.addTarget(self, action: #selector(reloadUserFeed), for: .valueChanged)
        feedTableView.addSubview(refreshControl)
    }
    
    @objc private func reloadUserFeed() {
        fetchFeed(cursor: nil, removeObjects: true)
    }
    
    // MARK: - Infinite scroll
    private func addInfiniteScroll() {
        feedTableView.addInfiniteScroll {[weak self] (tableView) in
            guard self?.endCursor != nil else {
                tableView.finishInfiniteScroll()
                return
            }
            
            self?.fetchFeed(cursor: self?.endCursor)
        }
    }
}

// MARK: - PreviewMediaProtocol
extension HomeController: FeedCellDelegate, PreviewMediaProtocol, PhotoPreviewControllerDelegate {
    func previewTapped(cell: FeedCell, mediaModel: ProfileMediaModel) {
        previewMedia(with: mediaModel)
    }
    
    func profileTapped(cell: FeedCell, userFeed: FeedModel) {
        let userFeedController = UserFeedController.instantiate()
        userFeedController.userId = userFeed.owner?.id
        
        if let owner = userFeed.owner {
            userFeedController.userName = owner.full_name.isEmpty ? owner.username : owner.full_name
        }
        
        navigationController?.navigationBar.topItem?.title = "Back"
        navigationController?.pushViewController(userFeedController, animated: true)
    }
    
    func photoPreviewControllerDismissed(controller: PhotoPreviewController) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
