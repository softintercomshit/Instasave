import Foundation
import Photos


struct SaveMediaContent {
    static func saveImage(_ image: UIImage?) {
        checkPermisions {
            if let image = image {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }, completionHandler: { (saved, error) in
                    if saved {
                        Alert.show(title: nil, message: "Photo was successfully saved.")
                    }
                })
            }
        }
    }
    
    static func saveVideo(_ path: URL) {
        checkPermisions {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: path)
            }) { saved, error in
                if saved {
                    try? FileManager.default.removeItem(at: path)
                    Alert.show(title: nil, message: "Video was successfully saved.")
                }
            }
        }
    }
    
    static private func checkPermisions(completionHandler: (() -> Void)?) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            completionHandler?()
        } else if status == .denied {
            Alert.show(title: nil, message: "Please allow access.", okAction: {
                UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
            }, cancelAction: {
                
            })
        } else {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    completionHandler?()
                }
            })
        }
    }
    
    private init(){}
}
