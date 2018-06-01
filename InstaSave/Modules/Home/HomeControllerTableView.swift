extension HomeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let profileFeedArray = profileFeedArray {
//            let numberOfAds = profileFeedArray.count / kNativeAdsInterval
//            return profileFeedArray.count + numberOfAds
            return profileFeedArray.count
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

        if let profileFeedArray = profileFeedArray {
//            let displayedAds = indexPath.row / kNativeAdsInterval
            cell.delegate = self
//            let feedModel = profileFeedArray[indexPath.row - displayedAds]
            let feedModel = profileFeedArray[indexPath.row]
            cell.setCell(profileFeed: feedModel)
        }

        return cell
    }
    
    func setUpTableView(_ tableView: UITableView) {
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: FeedCell.identifier, bundle: nil), forCellReuseIdentifier: FeedCell.identifier)
        tableView.register(UINib(nibName: NativeAdsCell.identifier, bundle: nil), forCellReuseIdentifier: NativeAdsCell.identifier)
        
        view.layoutIfNeeded()
        let newTableViewHeight = CGFloat(tableView.numberOfRows(inSection: 0)) * CGFloat(tableView.rowHeight)
        setTableViewHeight(tableView, height: newTableViewHeight)
        
        tableView.reloadData()
        tableView.showLoader()
    }
    
    func setTableViewHeight(_ tableView: UITableView, height: CGFloat) {
        var newFrame = tableView.frame
        newFrame.size.height = height
        tableView.frame = newFrame
    }
}
