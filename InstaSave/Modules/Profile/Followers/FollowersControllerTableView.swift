extension FollowersController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let emtyCellsNumber = Int(round(tableView.frame.height / tableView.rowHeight))
        return followersArray?.count ?? emtyCellsNumber
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FollowerCell.identifier, for: indexPath) as! FollowerCell
        
        if let followersArray = followersArray {
            cell.setUpCell(profileModel: followersArray[indexPath.row])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let followersArray = followersArray {
            let profileModel = followersArray[indexPath.row]
            let userFeedController = UserFeedController.instantiate()
            userFeedController.userId = profileModel.id
            userFeedController.userName = profileModel.fullName
            navigationController?.navigationBar.topItem?.title = "Back"
            navigationController?.pushViewController(userFeedController, animated: true)
        }
    }
    
    internal func setUpTableView(_ tableView: UITableView) {
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
