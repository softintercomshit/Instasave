extension UserFeedController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let userFeedArray = userFeedArray {
//            let numberOfAds = userFeedArray.count / kNativeAdsInterval
//            return userFeedArray.count + numberOfAds
            return userFeedArray.count
        }
        
        let emtyCellsNumber = Int(round(tableView.frame.height / tableView.rowHeight))
        return emtyCellsNumber
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // native ads cell
//        if indexPath.row % kNativeAdsInterval == 0 && indexPath.row != 0{
//            let cell = tableView.dequeueReusableCell(withIdentifier: NativeAdsCell.identifier, for: indexPath) as! NativeAdsCell
//            cell.rootViewController = self
//            return cell
//        }
        
        // feed cell
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedCell.identifier, for: indexPath) as! FeedCell
        
        if let userFeedArray = userFeedArray {
            cell.delegate = self
//            let displayedAds = indexPath.row / kNativeAdsInterval
//            let feedModel = userFeedArray[indexPath.row - displayedAds]
            let feedModel = userFeedArray[indexPath.row]
            cell.setCell(profileFeed: feedModel)
        }
        
        return cell
    }
    
    internal func setUpTableView(_ tableView: UITableView) {
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: FeedCell.identifier, bundle: nil), forCellReuseIdentifier: FeedCell.identifier)
        tableView.register(UINib(nibName: NativeAdsCell.identifier, bundle: nil), forCellReuseIdentifier: NativeAdsCell.identifier)
        
        view.layoutIfNeeded()
        let newTableViewHeight = CGFloat(tableView.numberOfRows(inSection: 0)) * CGFloat(tableView.rowHeight)
        setTableViewHeight(tableView, height: newTableViewHeight)
        
        tableView.reloadData()
        tableView.showLoader()
    }
    
    internal func setTableViewHeight(_ tableView: UITableView, height: CGFloat) {
        var newFrame = tableView.frame
        newFrame.size.height = height
        tableView.frame = newFrame
    }
}

// MARK: - PreviewMediaProtocol
extension UserFeedController: FeedCellDelegate, PreviewMediaProtocol, PhotoPreviewControllerDelegate {
    func previewTapped(cell: FeedCell, mediaModel: ProfileMediaModel) {
        previewMedia(with: mediaModel)
    }
    
    func photoPreviewControllerDismissed(controller: PhotoPreviewController) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
