import UIKit
import Alamofire
import AlamofireImage


class FollowerCell: UITableViewCell {
    
    static let identifier = "FollowerCell"
    
    // MARK: - Outlets
    @IBOutlet private weak var followerImageView: UIImageView!
    @IBOutlet private weak var followerNameLabel: UILabel!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUpCell(profileModel: ProfileModel) {
        followerNameLabel?.text = profileModel.fullName
        
        let size = followerImageView?.frame.size ?? CGSize.zero
        let url = URL(string: profileModel.profile_pic_url)!
        followerImageView?.af_setImage(
            withURL: url,
            placeholderImage: #imageLiteral(resourceName: "userImage"),
            filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: size.width / 2),
            imageTransition: .crossDissolve(1),
            completion: {[weak self] response in
                self?.indicatorView?.stopAnimating()
            }
        )
    }
}
