import UIKit
import Alamofire
import AlamofireImage


class SearchCell: UITableViewCell {
    
    static let identifier = "SearchCell"

    // MARK: - Outlets
    
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    
    // MARK: - Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUpCell(searchModel: SearchUserModel) {
        if let fullName = searchModel.full_name, !fullName.isEmpty {
            userNameLabel?.text = fullName
        } else {
            userNameLabel?.text = searchModel.username
        }
        
        let size = userImageView?.frame.size ?? CGSize.zero
        indicatorView?.startAnimating()
        
        let url = URL(string: searchModel.thumbnail_src)!
        userImageView?.af_setImage(
            withURL: url,
            placeholderImage: #imageLiteral(resourceName: "userImage"),
            filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: size.width / 2),
            imageTransition: .crossDissolve(1),
            completion: {[weak self] response in
                self?.indicatorView.stopAnimating()
            }
        )
    }
}
