import Foundation
import UIKit


protocol FeedCellDelegate: class {
    func previewTapped(cell: FeedCell, mediaModel: ProfileMediaModel)
    func profileTapped(cell: FeedCell, userFeed: FeedModel)
}

extension FeedCellDelegate {
    func profileTapped(cell: FeedCell, userFeed: FeedModel){}
}


final class FeedCell: UITableViewCell {
    
    static let identifier = "FeedCell"
    
    // MARK: - Outlets
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet private weak var userNameButton: UIButton!
    @IBOutlet private weak var mediaCollectionView: UICollectionView!
    @IBOutlet fileprivate weak var mediaFeedPageControl: UIPageControl!
    @IBOutlet private weak var progressView: UIProgressView!
    
    // MARK: - GlobalVars
    
    weak var delegate: FeedCellDelegate?
    fileprivate var profileFeed: FeedModel?
    
    // MARK: Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpCollectionView()
    }
    
    func setCell (profileFeed: FeedModel) {
        self.profileFeed = profileFeed
        mediaCollectionView.reloadData()
        
        mediaFeedPageControl.numberOfPages = profileFeed.profileMedia.count
        
        guard let owner = profileFeed.owner else {
            return
        }
        
        let userName = owner.full_name.count > 0 ? owner.full_name : owner.username
        userNameButton?.setTitle(userName, for: .normal)
        
        if let owner = profileFeed.owner {
            setImage(with: owner.profile_pic_url)
            profileImageView?.layer.cornerRadius = 10
        }
    }
    
    private func setImage(with path: String) {
        if let url = URL(string: path) {
            profileImageView?.af_setImage(
                withURL: url,
                placeholderImage: #imageLiteral(resourceName: "userImage"),
                imageTransition: .crossDissolve(0.5)
            )
        }
    }
    
    private func setUpCollectionView() {
        mediaCollectionView.register(UserMediaCell.self, forCellWithReuseIdentifier: UserMediaCell.identifier)
        mediaCollectionView.register(UINib(nibName: UserMediaCell.identifier, bundle: nil), forCellWithReuseIdentifier: UserMediaCell.identifier)
    }
    
    // MARK: Buttons actions
    
    @IBAction func openOwnerFeed(_ sender: UIButton) {
        if let profileFeed = profileFeed {
            delegate?.profileTapped(cell: self, userFeed: profileFeed)
        }
    }
    
    @IBAction func saveMedia(_ sender: UIButton) {
        if let cell = mediaCollectionView.visibleCells.first as? UserMediaCell {
            if let profileMedia = cell.profileMedia {
                if profileMedia.is_video {
                    sender.isEnabled = false
                    progressView.progress = 0
                    
                    DownloadVideo.url(URL(string: profileMedia.video_url!)!) { [weak self] (progress, path) in
//                        let stringProgress = String(format: "%.2f", progress * 100)
                        self?.progressView.progress = progress
                        
                        if let path = path {
                            SaveMediaContent.saveVideo(path)
                            sender.isEnabled = true
                            self?.progressView.progress = 0
                        }
                    }
                } else {
                    SaveMediaContent.saveImage(cell.userImageView.image)
                }
            }
        }
    }
}

extension FeedCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profileFeed?.profileMedia.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserMediaCell.identifier, for: indexPath) as! UserMediaCell
        
        if let profileFeed = profileFeed {
            let profileMedia = profileFeed.profileMedia[indexPath.row]
            cell.setCell(profileMedia: profileMedia)
            cell.delegate = self
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let profileFeed = profileFeed {
            let profileMedia = profileFeed.profileMedia[indexPath.row]
            delegate?.previewTapped(cell: self, mediaModel: profileMedia)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let visibleCell = collectionView.visibleCells[0] as? UserMediaCell {
            if let indexPath = collectionView.indexPath(for: visibleCell) {
                mediaFeedPageControl.currentPage = indexPath.row
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension FeedCell: UserMediaCellDelegate {
    func previewTapped(cell: UserMediaCell, mediaModel: ProfileMediaModel) {
        delegate?.previewTapped(cell: self, mediaModel: mediaModel)
    }
}
