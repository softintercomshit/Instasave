import UIKit


class NativeAdsCell: UITableViewCell, GADNativeExpressAdViewDelegate, GADVideoControllerDelegate {
    
    static let identifier = "NativeAdsCell"
    
    @IBOutlet private weak var nativeExpressAdView: GADNativeExpressAdView!
    
    var rootViewController: UIViewController? {
        didSet {
            nativeExpressAdView.adUnitID = kNativeUnitId
            nativeExpressAdView.rootViewController = rootViewController
            nativeExpressAdView.delegate = self
            
            let videoOptions = GADVideoOptions()
            videoOptions.startMuted = true
            nativeExpressAdView.setAdOptions([videoOptions])
            
            nativeExpressAdView.videoController.delegate = self
            
            nativeExpressAdView.load(GADRequest())
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    // MARK: - GADNativeExpressAdViewDelegate
    func nativeExpressAdViewDidReceiveAd(_ nativeExpressAdView: GADNativeExpressAdView) {
        if nativeExpressAdView.videoController.hasVideoContent() {
            print("Received an ad with a video asset.")
        } else {
            print("Received an ad without a video asset.")
        }
    }
    
    // MARK: - GADVideoControllerDelegate
    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
        print("The video asset has completed playback.")
    }
}
