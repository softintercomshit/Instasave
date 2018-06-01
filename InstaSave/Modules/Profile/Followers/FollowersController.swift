import UIKit


final class FollowersController: UITableViewController, StoryboardInstantiable {
    
    static var storyboardName: String = FollowersController.identifier
    
    // MARK: - Outlets

    
    // MARK: - Global vars
    internal var followersArray: [ProfileModel]?
    var displayType: DisplayType?
    private let tableRefreshControl = UIRefreshControl()
    private var endCursor: String?
    internal var defaultTableViewHeight: CGFloat?

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView(tableView)
        addRefreshControl()
        addInfiniteScroll()
        fetchFeed(cursor: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        defaultTableViewHeight = tableView.frame.height
    }

    private func fetchFeed(cursor: String?, removeObjects: Bool = false) {
        func handleResponse(endCursor: String?, profilesArray: [ProfileModel]?) {
            self.endCursor = endCursor
            
            if let profilesArray = profilesArray {
                
                removeObjects ? followersArray?.removeAll() : ()
                appendDataFromResponse(profilesArray)
                hideLoaderAnimationAndReloadData()
            }
            
            stopRefresh()
        }
        
        if let displayType = displayType {
            switch displayType {
            case .followers:
                ProfileRequest.followers(cursor: cursor, completionHandler: {(profilesArray, endCursor) in
                    handleResponse(endCursor: endCursor, profilesArray: profilesArray)
                })
            case .following:
                ProfileRequest.following(cursor: cursor, completionHandler: {(profilesArray, endCursor) in
                    handleResponse(endCursor: endCursor, profilesArray: profilesArray)
                })
            }
        }
    }
    
    private func appendDataFromResponse(_ responseArray: [ProfileModel]) {
        if var array = followersArray {
            array.append(contentsOf: responseArray)
            followersArray = array
        } else {
            followersArray = responseArray
        }
    }
    
    private func stopRefresh() {
        tableRefreshControl.endRefreshing()
        tableView.finishInfiniteScroll()
    }
    
    private func hideLoaderAnimationAndReloadData() {
        tableView.hideLoader()
        tableView.reloadData()
        if let defaultTableViewHeight = defaultTableViewHeight {
            setTableViewHeight(tableView, height: defaultTableViewHeight)
            self.defaultTableViewHeight = nil
        }
    }
    
    // MARK: - Refresh control
    private func addRefreshControl() {
        tableRefreshControl.addTarget(self, action: #selector(reloadUserFeed), for: .valueChanged)
        tableView.addSubview(tableRefreshControl)
    }
    
    @objc private func reloadUserFeed() {
        fetchFeed(cursor: nil, removeObjects: true)
    }
    
    // MARK: - Infinite scroll
    private func addInfiniteScroll() {
        tableView.addInfiniteScroll {[weak self] (tableView) in
            guard self?.endCursor != nil else {
                tableView.finishInfiniteScroll()
                return
            }
            
            self?.fetchFeed(cursor: self?.endCursor)
        }
    }
    
    enum DisplayType: Int {
        case followers, following
    }
}
