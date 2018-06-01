extension UIColor{
    class func RGBA(R: CGFloat, G: CGFloat, B: CGFloat, A: CGFloat) -> UIColor {
        let color = UIColor(red: R/255.0, green: G/255.0, blue: B/255.0, alpha: A)

        return color
    }
    
    open class var appViolet: UIColor { get {return UIColor(red: 101/255.0, green: 71/255.0, blue: 145/255.0, alpha: 1)}}
    
    func alpha(_ alpha: CGFloat) -> UIColor {
        return withAlphaComponent(alpha)
    }
}
