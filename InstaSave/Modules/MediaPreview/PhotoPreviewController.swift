import UIKit
import Alamofire
import AlamofireImage

protocol PhotoPreviewControllerDelegate: class {
    func photoPreviewControllerDismissed(controller: PhotoPreviewController)
}

final class PhotoPreviewController: UIViewController, StoryboardInstantiable, UIScrollViewDelegate {
    
    static var storyboardName: String = PhotoPreviewController.identifier
    
    var imageUrl: String?
    
    // MARK: - Outlets
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    
    // MARK: - Global vars
    
    private var initialTouchPoint = CGPoint.zero
    weak var delegate: PhotoPreviewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        setImage()
        addDismissGestureRecognizer()
    }
    
    // MARK: - setup controller
    
    private func setImage() {
        if let imageUrl = imageUrl {
            let url = URL(string: imageUrl)!
            
            imageView.af_setImage(
                withURL: url,
                placeholderImage: #imageLiteral(resourceName: "userImage"),
                imageTransition: .crossDissolve(0.5),
                completion: {[weak self] response in
                    self?.indicatorView.stopAnimating()
            })
        }
    }
    
    private func setupScrollView() {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
    }
    
    private func addDismissGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Buttons actions
    
    @IBAction func doneButtonAction(_ sender: Any) {
        dismissController()
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        SaveMediaContent.saveImage(imageView.image)
    }
    
    @objc private func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: view.window)

        if sender.state == .began {
            initialTouchPoint = touchPoint
        } else if sender.state == .changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: view.frame.size.width, height: view.frame.size.height)
            }
        } else if sender.state == .ended || sender.state == .cancelled {
            if touchPoint.y - initialTouchPoint.y > 200 {
                dismissController()
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        imageView.clipsToBounds = false
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.zoomScale = 1.0
        }) { (finished) in
            self.imageView.clipsToBounds = true
        }
    }
    
    private func dismissController() {
        delegate?.photoPreviewControllerDismissed(controller: self)
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        dismiss(animated: true, completion: nil)
    }
}
