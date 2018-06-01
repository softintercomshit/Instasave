import UIKit
import Alamofire
import AlamofireImage


protocol UserMediaCellDelegate: class {
    func previewTapped(cell: UserMediaCell, mediaModel: ProfileMediaModel)
}


class UserMediaCell: UICollectionViewCell, UIGestureRecognizerDelegate {

    static let identifier = "UserMediaCell"
    
    // MARK: - outlets
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    
    // MARK: Global vars
    
    var profileMedia: ProfileMediaModel?
    weak var delegate: UserMediaCellDelegate?
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let pinchZoom = UIPinchGestureRecognizer.init(target: self, action: #selector(pinch(_:)))
        pinchZoom.delegate = self
        self.addGestureRecognizer(pinchZoom)
    }
    
    @objc private func pinch(_ sender: UIPinchGestureRecognizer) {
        TMImageZoom.shared().gestureStateChanged(sender, withZoom: userImageView)
    }

    func setCell (profileMedia: ProfileMediaModel) {
        self.profileMedia = profileMedia

        setImage(with: profileMedia.display_url)
        
        playButton?.isHidden = !profileMedia.is_video
    }
    
    private func setImage(with path: String) {
        indicatorView?.startAnimating()
        
        if let url = URL(string: path) {
            userImageView.af_setImage(
                withURL: url,
                placeholderImage: #imageLiteral(resourceName: "userImage"),
                imageTransition: .crossDissolve(0.5),
                completion: {[weak self] response in
                    self?.indicatorView?.stopAnimating()
                }
            )
        }
    }
}
