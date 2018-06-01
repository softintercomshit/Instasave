import UIKit
import AVKit
import AVFoundation


final class DownloadController: UIViewController, StoryboardInstantiable, KeyboardHandlerProtocol, PreviewMediaProtocol, PhotoPreviewControllerDelegate {
    
    static var storyboardName: String = DownloadController.identifier
    var textFieldFrame: CGRect = CGRect.zero
    
    // MARK: - Outlets
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var urlTextField: UITextField! {
        didSet {
            urlTextField.attributedPlaceholder = NSAttributedString(string: urlTextField.placeholder ?? "",
                                                                    attributes: [NSAttributedStringKey.foregroundColor: UIColor.appViolet.alpha(0.5)])
        }
    }
    
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var playerView: UIView!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var userPhotoImageView: UIImageView! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleImageTapGestureRecognizer))
            userPhotoImageView?.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    @IBOutlet private weak var textInfoLabel: UILabel!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var userProfileButton: UIButton!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var controlsView: UIView! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleControlsTapGestureRecognizer))
            controlsView?.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    @IBOutlet private weak var muteButton: UIButton! {
        didSet {
            muteButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            muteButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            muteButton.layer.shadowOpacity = 1.0
            muteButton.layer.shadowRadius = 0.0
            muteButton.layer.masksToBounds = false
            muteButton.layer.cornerRadius = 4.0
        }
    }
    
    // MARK: - Global vars
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var isVideo = false
    private var feedModelOwner: FeedModelOwner?
    private var currentUrl: URL?
    
    var initialUrl: String? {
        didSet {
            if let initialUrl = initialUrl {
                self.previewMedia(text: initialUrl)
            }
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        urlTextField.changeClearButton()
        
        if let initialUrl = initialUrl {
            urlTextField?.text = initialUrl
            userProfileButton.isUserInteractionEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startObservingKeyboardChanges()
        player?.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.topItem?.titleView = logoImageView
        navigationController?.navigationBar.topItem?.titleView?.contentMode = .scaleAspectFit
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopObservingKeyboardChanges()
        player?.pause()
    }
    
    // MARK: - Buttons actions
    @IBAction func downloadMedia(_ sender: UIButton) {
        if let url = currentUrl {
            if isVideo {
                sender.isEnabled = false
                progressView.progress = 0
                
                DownloadVideo.url(url) { [weak self] (progress, path) in
                    self?.progressView.progress = progress
//                    let stringProgress = String(format: "%.2f", progress * 100)
                    
                    if let path = path {
                        SaveMediaContent.saveVideo(path)
                        self?.progressView.progress = 0
                        sender.isEnabled = true
                    }
                }
            } else {
                SaveMediaContent.saveImage(userPhotoImageView.image)
            }
        }
    }
    
    @IBAction func openUserAccount(_ sender: UIButton) {
        if let feedModelOwner = feedModelOwner {
            let userFeedController = UserFeedController.instantiate()
            userFeedController.userId = feedModelOwner.id
            userFeedController.userName = userProfileButton.title(for: .normal)
            
            navigationController?.navigationBar.topItem?.title = "Back"
            navigationController?.pushViewController(userFeedController, animated: true)
        }
    }
    
    @IBAction func playPauseVideo(_ sender: UIButton) {
//        sender.isSelected ? player?.pause() : player?.play()
//        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func muteUnmuteVideo(_ sender: UIButton) {
        player?.isMuted = sender.isSelected
        sender.isSelected = !sender.isSelected
    }
    
    @objc private func handleImageTapGestureRecognizer() {
        if let url = currentUrl , isVideo == false {
            previewPhoto(imageUrl: url.absoluteString)
        }
    }
    
    @objc private func handleControlsTapGestureRecognizer() {
        playButton.isSelected ? player?.pause() : player?.play()
        playButton.isSelected = !playButton.isSelected
        
        UIView.animate(withDuration: 0.3, animations: {
            self.playButton.alpha = CGFloat(fabsf(Float(self.playButton.alpha - 1.0)))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if self.playButton.alpha == 1 {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.playButton.alpha = 0
                    })
                }
            }
        })
    }
    
    func photoPreviewControllerDismissed(controller: PhotoPreviewController) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    fileprivate func setUpPlayer(url: URL) {
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = playerView.bounds
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.addSublayer(playerLayer!)
        player?.play()
        player?.isMuted = true
        playerView.bringSubview(toFront: controlsView)
        controlsView.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.playButton.alpha == 1 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.playButton.alpha = 0
                })
            }
        }
    }
    
    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        if let item = notification.object as? AVPlayerItem {
            item.seek(to: kCMTimeZero)
            player?.play()
        }
    }
}

// MARK: - UITextViewDelegate
extension DownloadController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var frame = textField.convert(textField.bounds, to: view)
        frame.size.height += 10
        textFieldFrame = frame
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        previewMedia(text: textField.text!)
        
        return true
    }
    
    private func previewMedia(text: String) {
        previewMedia(with: text) {[weak self] (url, isVideo, feedModelOwner) in
            self?.currentUrl = url
            self?.isVideo = isVideo
            self?.feedModelOwner = feedModelOwner
            
            if isVideo {
                self?.setUpPlayer(url: url)
            } else {
                self?.playerView.sendSubview(toBack: (self?.controlsView)!)
                self?.playerLayer?.removeFromSuperlayer()
                self?.setImage(with: url.absoluteString, imageView: self?.userPhotoImageView)
            }
            
            if self?.headerView.alpha == 0 {
                UIView.animate(withDuration: 0.3, animations: {
                    self?.headerView.alpha = 1
                })
            }
            
            if let feedModelOwner = feedModelOwner {
                self?.setImage(with: feedModelOwner.profile_pic_url, imageView: self?.profileImageView)
                self?.userProfileButton.setTitle(feedModelOwner.full_name.isEmpty ? feedModelOwner.username : feedModelOwner.full_name, for: .normal)
            }
        }
    }
    
    private func setImage(with path: String, imageView: UIImageView?) {
        if let url = URL(string: path) {
            imageView?.af_setImage(
                withURL: url,
                imageTransition: .crossDissolve(0.5),
                completion: { response in
                    imageView?.contentMode = .scaleAspectFill
                }
            )
        }
    }
}
