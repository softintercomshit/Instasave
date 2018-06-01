import UIKit
import Alamofire
import AlamofireImage


class ExploreCell: UICollectionViewCell {
    
    static let identifier = "ExploreCell"

    // MARK: - Outlets
    
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    
    // MARK: - Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUpCell(searchmodel: SearchUserModel) {
        setImage(with: searchmodel.thumbnail_src)
    }
    
    private func setImage(with path: String) {
        indicatorView?.startAnimating()
        
        let url = URL(string: path)!
        userImageView.af_setImage(
            withURL: url,
            placeholderImage: #imageLiteral(resourceName: "userImage"),
            imageTransition: .crossDissolve(1),
            completion: {[weak self] response in
                self?.indicatorView.stopAnimating()
            }
        )
    }
}
