extension SearchController: UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.identifier, for: indexPath) as! SearchCell
        
        cell.setUpCell(searchModel: searchResultsArray[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        
        let userFeedController = UserFeedController.instantiate()
        let searchModel = searchResultsArray[indexPath.row]
        userFeedController.userId = searchModel.id
        userFeedController.userName = searchModel.full_name ?? searchModel.username
        navigationController?.navigationBar.topItem?.title = "Back"
        navigationController?.pushViewController(userFeedController, animated: true)
    }
    
    internal func setUpTableView() {
        searchResultsTableView.tableFooterView = UIView()
        searchResultsTableView.register(UINib(nibName: SearchCell.identifier, bundle: nil), forCellReuseIdentifier: SearchCell.identifier)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer))
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.delegate = self
        searchResultsTableView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func handleTapGestureRecognizer() {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        UIView.animate(withDuration: 0.5) {
            self.searchResultsTableView.alpha = 0
        }
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let cells = searchResultsTableView.visibleCells
        
        return cells.isEmpty
    }
}
