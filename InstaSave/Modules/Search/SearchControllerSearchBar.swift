extension SearchController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        
        UIView.animate(withDuration: 0.5) {
            self.searchResultsTableView.alpha = 0.9
        }
        
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let text = searchBar.text, !text.isEmpty {
            searchBy(searchText: text)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        
        UIView.animate(withDuration: 0.5) {
            self.searchResultsTableView.alpha = 0
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            searchResultsArray.removeAll()
            searchResultsTableView.reloadData()
            return
        }
        
        searchBy(searchText: searchText)
    }
    
    private func searchBy(searchText: String) {
        SearchRequest.search(key: searchText) {[weak self] searchModelArray in
            if let searchModelArray = searchModelArray {
                self?.searchResultsArray = searchModelArray
                self?.searchResultsTableView.reloadData()
            }
        }
    }
}
