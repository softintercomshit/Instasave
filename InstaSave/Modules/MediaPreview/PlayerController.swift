import UIKit
import AVFoundation
import AVKit


final class PlayerController: AVPlayerViewController, StoryboardInstantiable, UIGestureRecognizerDelegate {
    
    static var storyboardName: String = PlayerController.identifier
    
    // MARK: - Global vars
    var url: URL?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = url {
            player = AVPlayer(url: url)
            player?.actionAtItemEnd = .none
            player?.play()
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        }
    }
    
    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        if let item = notification.object as? AVPlayerItem {
            item.seek(to: kCMTimeZero)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
}
