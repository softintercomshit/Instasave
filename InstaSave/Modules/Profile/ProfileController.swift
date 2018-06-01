import UIKit
import Alamofire
import AlamofireImage


final class ProfileController: UIViewController, StoryboardInstantiable, AlertProtocol {
    
    static var storyboardName: String = ProfileController.identifier

    // MARK: - Outlets
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var followersLabel: UILabel!
    @IBOutlet private weak var followingLabel: UILabel!
    @IBOutlet private weak var feedTableView: UITableView!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var noFeedlabel: UILabel!
    
    // MARK: - Global vars
    internal var userFeedArray: [FeedModel]?
    private let refreshControl = UIRefreshControl()
    private var endCursor: String?
    internal var defaultTableViewHeight: CGFloat?
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setHeaderInfo()
        setUpTableView(feedTableView)
        addRefreshControl()
        addInfiniteScroll()
        fetchFeed(cursor: nil)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logOut))
        navigationController?.navigationBar.topItem?.rightBarButtonItem = logoutButton
        
        if let profileModel = appProfileModel {
            navigationController?.navigationBar.topItem?.titleView = nil
            navigationController?.navigationBar.topItem?.title = profileModel.fullName
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let feedTableView = feedTableView {
            defaultTableViewHeight = feedTableView.frame.height
        }
    }
    
    // MARK: Buttons actions
    @objc private func logOut() {
        showAlert(title: "Logout", message: "Are you sure you want to log out?", okAction: {
            Authorization.logout {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.showAuthenticationController()
            }
        }, cancelAction: {
            
        })
    }
    
    @IBAction func openFollowers(_ sender: UIButton) {
        let followersController = FollowersController.instantiate()
        followersController.displayType = .followers
        navigationController?.pushViewController(followersController, animated: true)
    }
    
    @IBAction func openFollowing(_ sender: UIButton) {
        let followersController = FollowersController.instantiate()
        followersController.displayType = .following
        navigationController?.pushViewController(followersController, animated: true)
    }
    
    private func fetchFeed(cursor: String?, removeObjects: Bool = false) {
        if let appProfileModel = appProfileModel {
            FeedRequest.userFeed(userId: appProfileModel.id, cursor: cursor) {[weak self] (userFeedArray, endCursor) in
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
    
    private func setHeaderInfo() {
        if let appProfileModel = appProfileModel {
            followingLabel.attributedText = attributedFollowersString(followers: appProfileModel.follows, followKey: "following")
            followersLabel.attributedText = attributedFollowersString(followers: appProfileModel.followed_by, followKey: "followers")
            
            let url = URL(string: appProfileModel.profile_pic_url)!
            userImageView?.af_setImage(
                withURL: url,
                imageTransition: .crossDissolve(1),
                completion: {[weak self] response in
                    self?.indicatorView.stopAnimating()
                }
            )
        }
    }
    
    private func formatedFolowers(number: Int) -> String {
        if number < 1000 {
            return "\(number)"
        }
        
        let exp = Int(log10(Double(number)) / 3)
        let units = ["K","M","G","T","P","E"]
        
        let roundedNum = round(10.0 * Double(number) / pow(1000.0,Double(exp))) / 10
        let abbreviatedNum = Decimal(roundedNum) - Decimal(Int(roundedNum))
        
        if abbreviatedNum > 0 {
            return "\(roundedNum)\(units[exp-1])"
        }
        
        return "\(Int(roundedNum))\(units[exp-1])"
    }
    
    private func attributedFollowersString(followers: Int, followKey: String) -> NSAttributedString {
        let followingNumber = formatedFolowers(number: followers)
        let followingNumberAttribute = [NSAttributedStringKey.foregroundColor: UIColor.appViolet, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)]
        
        let numberAttribute = [NSAttributedStringKey.foregroundColor: UIColor.appViolet.alpha(0.5), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
        let numberAttrString = NSAttributedString(string: "\n\(followKey)", attributes: numberAttribute)
        
        let followingAttrString = NSMutableAttributedString(string: followingNumber, attributes: followingNumberAttribute)
        followingAttrString.append(numberAttrString)
        
        return followingAttrString
    }
}
