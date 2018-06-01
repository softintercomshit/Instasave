import UIKit


final class SearchController: UIViewController, StoryboardInstantiable {

    static var storyboardName: String = SearchController.identifier
    
    // MARK: - Outlets
    @IBOutlet private weak var exploreCollectionView: UICollectionView!
    @IBOutlet internal weak var searchResultsTableView: UITableView!
    
    // MARK: - Global vars
    internal lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.costumize(placeholder: "Search")
        
        return searchBar
    }()
    
    internal var exploreArray: [SearchUserModel]?
    internal var searchResultsArray = [SearchUserModel]()
    private var endCursor: String?
    private let refreshControl = UIRefreshControl()
    fileprivate var defaultCollectionViewHeight: CGFloat?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionView(exploreCollectionView)
        setUpTableView()
        
        addRefreshControl()
        addInfiniteScroll()
        fetchFeed(cursor: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { [weak self] (notification) in
            self?.keyboardWillShow(sender: notification as NSNotification)
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { [weak self] (notification) in
            self?.keyboardWillHide(sender: notification as NSNotification)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let exploreCollectionView = exploreCollectionView {
            defaultCollectionViewHeight = exploreCollectionView.frame.height
        }
    }
    
    private func keyboardWillShow(sender: NSNotification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            var insets = searchResultsTableView.contentInset
            insets.bottom = keyboardHeight - (navigationController?.navigationBar.frame.height)! - UIApplication.shared.statusBarFrame.height
            searchResultsTableView.contentInset = insets
        }
    }
    
    private func keyboardWillHide(sender: NSNotification) {
        searchResultsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func fetchFeed(cursor: String?, removeObjects: Bool = false) {
        SearchRequest.explore(cursor: nil) {[weak self] (searchModelArray, endCursor) in
            self?.endCursor = endCursor
            
            if let searchModelArray = searchModelArray {
                removeObjects ? self?.exploreArray?.removeAll() : ()
                self?.appendDataFromResponse(searchModelArray)
                self?.exploreCollectionView.reloadSections(IndexSet(integersIn: 0...0))
                self?.hideLoaderAnimationAndReloadData()
            }
            
            self?.stopRefresh()
        }
    }
    
    private func appendDataFromResponse(_ responseArray: [SearchUserModel]) {
        if var array = exploreArray {
            array.append(contentsOf: responseArray)
            exploreArray = array
        } else {
            exploreArray = responseArray
        }
    }
    
    private func stopRefresh() {
        refreshControl.endRefreshing()
        exploreCollectionView.finishInfiniteScroll()
    }
    
    private func hideLoaderAnimationAndReloadData() {
        if let defaultCollectionViewHeight = defaultCollectionViewHeight {
            setCollectionViewight(exploreCollectionView, height: defaultCollectionViewHeight)
            self.defaultCollectionViewHeight = nil
        }
        exploreCollectionView.hideLoader()
        exploreCollectionView.reloadData()
    }
    
    // MARK: - Refresh control
    private func addRefreshControl() {
        refreshControl.addTarget(self, action: #selector(reloadUserFeed), for: .valueChanged)
        exploreCollectionView.addSubview(refreshControl)
    }
    
    @objc private func reloadUserFeed() {
        fetchFeed(cursor: nil, removeObjects: true)
    }
    
    // MARK: - Infinite scroll
    private func addInfiniteScroll() {
        exploreCollectionView.addInfiniteScroll {[weak self] (collectionView) in
            guard self?.endCursor != nil else {
                collectionView.finishInfiniteScroll()
                return
            }
            
            self?.fetchFeed(cursor: self?.endCursor)
        }
    }
}
