import Foundation


extension AuthenticationController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let page = Int(targetContentOffset.pointee.x / scrollView.frame.width)
        
        if pageControl.currentPage != page {
            pageControl.currentPage = page
            
            clearAnimation(page: page)
            addAnimation(page: page)
        }
    }
    
    func clearInitialAnimation() {
        for imageView in infoImageViews {
            for (idx, layer) in imageView.layer.sublayers!.enumerated() {
                if idx == 0 {continue}
                
                layer.isHidden = true
                var frame = scrollView.bounds
                frame.origin.x = frame.width
                layer.frame = frame
            }
        }
    }
    
    func clearAnimation(page: Int) {
        let indexesArray = [Int](0...infoImageViews.count-1)
        if let index = indexesArray.index(of: page) {
            var tmpArray = infoImageViews
            tmpArray.remove(at: index)
            
            for imageView in tmpArray {
                for (idx, layer) in imageView.layer.sublayers!.enumerated() {
                    if idx == 0 {continue}
                    
                    layer.isHidden = true
                    var frame = scrollView.bounds
                    frame.origin.x = frame.width
                    layer.frame = frame
                }
            }
        }
    }
    
    func addAnimation(page: Int) {
        let imageView = infoImageViews[page]
        imageView.contentMode = .scaleAspectFit
        for (idx, layer) in imageView.layer.sublayers!.enumerated() {
            if idx == 0 {continue}
            
            var frame = scrollView.bounds
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(idx*500), execute: {
                layer.isHidden = false
                frame.origin.x = 0
                layer.frame = frame
            })
        }
    }
    
    func setUpScrollView() {
        let imagesArray = [
            [UIImage(named: "tip1")!, UIImage(named: "tip1_2")!, UIImage(named: "tip1_3")!],
            [UIImage(named: "tip2")!, UIImage(named: "tip2_2")!]
        ]
        
        let frame = scrollView.frame
        pageControl.numberOfPages = imagesArray.count
        
        for (idx, images) in imagesArray.enumerated() {
            let xOrigin = CGFloat(idx) * frame.width
            let imageView = UIImageView(frame: CGRect(x: xOrigin, y: 0, width: frame.width, height: frame.height))
            imageView.isUserInteractionEnabled = true
            let tapGesturerecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesturerecognizer))
            imageView.addGestureRecognizer(tapGesturerecognizer)
            infoImageViews.append(imageView)
            imageView.contentMode = .scaleAspectFit
            for image in images {
                let tmpImageView = UIImageView(frame: imageView.bounds)
                tmpImageView.image = image
                imageView.layer.addSublayer(tmpImageView.layer)
            }
            
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSize(width: frame.width * CGFloat(imagesArray.count), height: frame.height)
        clearInitialAnimation()
    }
    
    @objc private func handleTapGesturerecognizer() {
        var nextPage = pageControl.currentPage + 1
        if nextPage > infoImageViews.count - 1 {
            nextPage = 0
        }
        
        let originX = CGFloat(nextPage) * scrollView.frame.width
        scrollView.scrollRectToVisible(CGRect(x: originX, y: 0, width: scrollView.frame.width, height: scrollView.frame.height), animated: true)
        clearAnimation(page: pageControl.currentPage)
        pageControl.currentPage = nextPage
        addAnimation(page: nextPage)
    }
}
