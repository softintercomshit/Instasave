import Foundation
import UIKit


protocol PreviewMediaProtocol {}

extension PreviewMediaProtocol where Self: UIViewController {
    func previewMedia(with path: String, button: UIButton?=nil) {
        MediaRequest.new(link: path) {[weak self] (feedModelOwner, mediaUrl, isVideo) in
            button?.isEnabled = true
            
            if let mediaUrl = mediaUrl {
                if isVideo {
                    if let url = URL(string: mediaUrl) {
                        let moviePlayerController = PlayerController.instantiate()
                        moviePlayerController.url = url
                        self?.present(moviePlayerController, animated: true, completion: nil)
                    }
                } else {
                    self?.previewPhoto(imageUrl: mediaUrl)
                }
            }
        }
    }
    
    func previewMedia(with path: String, button: UIButton?=nil, completionHandler: ((_ url: URL,_ isVideo: Bool, _ feedModelOwner: FeedModelOwner?) -> Void)?) {
        MediaRequest.new(link: path) { (feedModelOwner, mediaUrl, isVideo) in
            button?.isEnabled = true
            
            if let mediaUrl = mediaUrl {
                if let url = URL(string: mediaUrl) {
                    completionHandler?(url, isVideo, feedModelOwner)
                }
            }
        }
    }
    
    func previewMedia(with mediaModel: ProfileMediaModel) {
        if mediaModel.is_video {
            if let video_url = mediaModel.video_url {
                if let url = URL(string: video_url) {
                    let moviePlayerController = PlayerController.instantiate()
                    moviePlayerController.url = url
                    present(moviePlayerController, animated: true, completion: nil)
                }
            }
        } else {
            previewPhoto(imageUrl: mediaModel.display_url)
        }
    }
    
    func previewPhoto(imageUrl: String) {
        let photoPreviewController = PhotoPreviewController.instantiate()
        photoPreviewController.delegate = self as? PhotoPreviewControllerDelegate
        photoPreviewController.imageUrl = imageUrl
        photoPreviewController.modalPresentationStyle = .overCurrentContext
        navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        present(photoPreviewController, animated: true, completion: nil)
    }
}
