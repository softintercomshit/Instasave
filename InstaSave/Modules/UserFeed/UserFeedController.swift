import UIKit


final class UserFeedController: UIViewController, StoryboardInstantiable {

    static var storyboardName: String = UserFeedController.identifier
    
    // MARK: Outlets
    @IBOutlet private weak var feedTableView: UITableView!
    @IBOutlet private weak var noFeedlabel: UILabel!
    
    // MARK: Global vars
    var userId: String?
    var userName: String?
    var shortCode: String?
    
    internal var userFeedArray: [FeedModel]?
    private let refreshControl = UIRefreshControl()
    private var endCursor: String?
    internal var defaultTableViewHeight: CGFloat?
    
    // Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userName = userName {
            title = userName
        } else if let shortCode = shortCode {
            UserNameRequest.new(shortCode: shortCode, completionHandler: { [weak self] userName in
                self?.title = userName
            })
        }
        
        setUpTableView(feedTableView)
        addRefreshControl()
        addInfiniteScroll()
        fetchFeed(cursor: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let feedTableView = feedTableView {
            defaultTableViewHeight = feedTableView.frame.height
        }
    }
    
    private func fetchFeed(cursor: String?, removeObjects: Bool = false) {
        guard let userId = userId, userId.count > 0 else {
            print("it can't be !!!!  wtf???")
            return
        }
        
        FeedRequest.userFeed(userId: userId, cursor: cursor) {[weak self] (userFeedArray, endCursor) in
            self?.endCursor = endCursor
            
            guard userFeedArray != nil else {
                self?.userFeedArray = [FeedModel]()
                self?.stopRefresh()
                self?.hideLoaderAnimationAndReloadData()
                self?.feedTableView.backgroundView = self?.noFeedlabel
                return
            }
            
            if let userFeedArray = userFeedArray {
                guard userFeedArray.first?.profileMedia.first?.display_url != self?.userFeedArray?.first?.profileMedia.first?.display_url else {
                    self?.endCursor = nil
                    self?.stopRefresh()
                    return
                }
                
                removeObjects ? self?.userFeedArray?.removeAll() : ()
                self?.appendDataFromResponse(userFeedArray)
                self?.hideLoaderAnimationAndReloadData()
            }
            
            self?.stopRefresh()
        }
    }
    
    private func appendDataFromResponse(_ responseArray: [FeedModel]) {
        if var array = userFeedArray {
            array.append(contentsOf: responseArray)
            userFeedArray = array
        } else {
            userFeedArray = responseArray
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
