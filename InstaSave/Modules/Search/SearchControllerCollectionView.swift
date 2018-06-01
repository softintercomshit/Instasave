extension SearchController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let height = collectionView.bounds.size.width / 2.0
        let emptyCellsNumber = Int(round(collectionView.frame.height / height))
        return exploreArray?.count ?? emptyCellsNumber * 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreCell.identifier, for: indexPath) as! ExploreCell
        
        if let exploreArray = exploreArray {
            collectionView.hideLoader()
            cell.setUpCell(searchmodel: exploreArray[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width / 2.0 - 0.5
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let exploreArray = exploreArray {
            let userFeedController = UserFeedController.instantiate()
            userFeedController.userId = exploreArray[indexPath.row].id
            userFeedController.shortCode = exploreArray[indexPath.row].shortcode
            navigationController?.navigationBar.topItem?.title = "Back"
            navigationController?.pushViewController(userFeedController, animated: true)
        }
    }
    
    internal func setUpCollectionView(_ collectionView: UICollectionView) {
        collectionView.register(ExploreCell.self, forCellWithReuseIdentifier: ExploreCell.identifier)
        collectionView.register(UINib(nibName: ExploreCell.identifier, bundle: nil), forCellWithReuseIdentifier: ExploreCell.identifier)
        
        view.layoutIfNeeded()
        let height = collectionView.bounds.size.width / 2.0
        let newHeight = CGFloat(collectionView.numberOfItems(inSection: 0)) * height / 2.0
        setCollectionViewight(collectionView, height: newHeight)
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        collectionView.showLoader()
    }
    
    internal func setCollectionViewight(_ collectionView: UICollectionView, height: CGFloat) {
        var newFrame = collectionView.frame
        newFrame.size.height = height
        collectionView.frame = newFrame
    }
}
