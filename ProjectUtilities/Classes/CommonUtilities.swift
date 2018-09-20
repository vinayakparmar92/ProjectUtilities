import UIKit

// MARK: Type Alias
typealias OnCompletionHandler = ((Bool) -> ())
typealias JSONDictionary = [String : Any]
typealias JSONDictionaryWithOptionalValues = [String : Any?]

// MARK: Constants
let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height
let kStatusBarHeight = UIApplication.shared.statusBarFrame.size.height
let kAnimationTime = 0.35
let kSomethingWrongError = "Something went wrong! Please try again later."
let kOops = "Oops!"
let kSuccess = "Success!"

// MARK: Native class extensions
extension UITableView {
    func registerCellsWith(identifiers : [String]) {
        for identifier in identifiers {
            register(UINib.init(nibName: identifier,
                                bundle: Bundle.main),
                     forCellReuseIdentifier: identifier)
        }
    }
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
    
    func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        if self.hasRowAtIndexPath(indexPath: indexPath) {
            self.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
    
    var queryParams : JSONDictionary? {
        get {
            guard let url = URLComponents(string: self.absoluteString) else { return nil }
            
            var queryItems : JSONDictionary? = [:]
            
            url.queryItems?.forEach({ (queryItem) in
                if let queryItemValue = queryItem.value {
                    queryItems?.updateValue(queryItemValue,
                                            forKey: queryItem.name)
                }
            })
            
            return queryItems
        }
    }
    
    func appending(newQueryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(string: absoluteString),
            !newQueryItems.isEmpty else {
                return URL.init(string: absoluteString)
        }
        
        urlComponents.queryItems?.append(contentsOf: newQueryItems)
        
        if let strNewURL = urlComponents.string {
            return URL.init(string: strNewURL)
        } else  {
            return URL.init(string: absoluteString)
        }
    }
}

extension Data {
    func getString() -> String? {
        return String.init(data: self, encoding: .utf8)
    }
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension Optional where Wrapped == String {
    var url: URL? {
        if let _ = self {
            return URL.init(string: self!)
        }
        
        return nil
    }
    
    var isOptionalStringNilOrEmpty : Bool {
        return ((self) ?? "").isEmpty
    }
    
    func toBool() -> Bool {
        if let weakSelf = self {
            return weakSelf.toBool()
        }
        
        return false
    }
}

extension UITableView {
    
    func scrollToLastRow(animated : Bool) {
        let section = self.numberOfSections
        if section > 0 {
            let row = self.numberOfRows(inSection: section - 1)
            if row > 0 {
                scrollToRow(at: IndexPath.init(row: row - 1, section: section - 1), at: .bottom, animated: true)
            }
        }
    }
}

extension UIScrollView {
    
    func scrollToBottom(animated : Bool) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        setContentOffset(bottomOffset, animated: animated)
    }
}

extension UIImage {
    static func iconWithName(_ name: String,
                             textColor: UIColor,
                             fontSize: CGFloat,
                             font: UIFont,
                             offset: CGSize = CGSize.zero) -> UIImage {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        
        let attributes = [
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.foregroundColor: textColor,
            NSAttributedStringKey.paragraphStyle: paragraph
        ]
        let attributedString = NSAttributedString(string: name as String, attributes: attributes)
        let stringSize = sizeOfAttributeString(attributedString)
        let size = CGSize(width: stringSize.width + offset.width, height: stringSize.height + offset.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        attributedString.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

private func sizeOfAttributeString(_ str: NSAttributedString) -> CGSize {
    return str.boundingRect(with: CGSize(width: 10000, height: 10000),
                            options:(NSStringDrawingOptions.usesLineFragmentOrigin),
                            context:nil).size
}

extension UIButton {
    func loadingIndicator(_ show: Bool, color: UIColor = UIColor.gray) {
        let indicatorTag = 808404
        
        if show {
            isEnabled = false
            alpha = 0
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            indicator.center = center
            indicator.tag = indicatorTag
            indicator.color = color
            superview?.addSubview(indicator)
            indicator.startAnimating()
            
        } else {
            isEnabled = true
            alpha = 1.0
            if let indicator = superview?.viewWithTag(indicatorTag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
    
    func setTitleWithOutAnimation(title: String?) {
        UIView.setAnimationsEnabled(false)
        
        setTitle(title, for: .normal)
        
        layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
    }
    
    func showSuccessStateWith(title: String = "Success!", color: UIColor = UIColor.green) {
        animateExpandBumpEffect() { [weak self] in
            if let weakSelf = self {
                weakSelf.setTitleColor(UIColor.white, for: .normal)
                weakSelf.setTitle(title, for: .normal)
                weakSelf.backgroundColor = color
            }
        }
    }
    
    func updateTitleIfRequired(title: String?) {
        if let btnTitle = currentTitle,
            let title = title,
            btnTitle != title {
            setTitle(title, for: .normal)
        }
    }
}

extension Array {
    func peekObjectAt(index : Int) -> Element? {
        if index < count {
            return self[index]
        }
        return nil
    }
}

extension Optional where Wrapped: Collection {
    var isArrayNilOrEmpty: Bool {
        switch self {
        case .some(let collection):
            return collection.isEmpty
        case .none:
            return true
        }
    }
}

extension Bundle {
    public var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var releaseVersionNumberPretty: String {
        return "v\(releaseVersionNumber ?? "1.0.0")"
    }
}

extension CAShapeLayer {
    func drawRoundedRect(rect: CGRect, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        path = UIBezierPath(roundedRect: rect, cornerRadius: 7).cgPath
    }
}

private var handle: UInt8 = 0;

extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func setBadge(text: String?,
                  withOffsetFromTopRight offset: CGPoint = CGPoint.zero,
                  andColor color:UIColor = UIColor.red,
                  andFilled filled: Bool = true,
                  andFontSize fontSize: CGFloat = 11) {
        badgeLayer?.removeFromSuperlayer()
        
        if (text == nil || text == "") {
            return
        }
        
        addBadge(text: text!, withOffset: offset, andColor: color, andFilled: filled)
    }
    
    private func addBadge(text: String,
                          withOffset offset: CGPoint = CGPoint.zero,
                          andColor color: UIColor = UIColor.red,
                          andFilled filled: Bool = true,
                          andFontSize fontSize: CGFloat = 11) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        var font = UIFont.systemFont(ofSize: fontSize)
        
        if #available(iOS 9.0, *) {
            font = UIFont.monospacedDigitSystemFont(ofSize: fontSize,
                                                    weight: UIFont.Weight.regular)
        }
        
        let badgeSize = text.size(withAttributes: [NSAttributedStringKey.font: font])
        
        // Initialize Badge
        let badge = CAShapeLayer()
        
        let height = badgeSize.height;
        var width = badgeSize.width + 2 /* padding */
        
        //make sure we have at least a circle
        if (width < height) {
            width = height
        }
        
        //x position is offset from right-hand side
        let x = view.frame.width - width + offset.x
        
        let badgeFrame = CGRect(origin: CGPoint(x: x, y: offset.y), size: CGSize(width: width, height: height))
        
        badge.drawRoundedRect(rect: badgeFrame, andColor: color, filled: filled)
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = text
        label.alignmentMode = kCAAlignmentCenter
        label.font = font
        label.fontSize = font.pointSize
        
        label.frame = badgeFrame
        label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}

extension UIView {
    class func fromNib<T : UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func fadeIn() {
        if alpha == 1 {
            return
        }
        isHidden = false
        UIView.animate(withDuration: kAnimationTime) { [weak self] in
            if let weakSelf = self {
                weakSelf.alpha = 1
            }
        }
    }
    
    func fadeOut(shouldRemove: Bool) {
        if alpha == 0 {
            return
        }
        
        UIView.animate(withDuration: 0.2,
                       animations: { [weak self] in
                        if let weakSelf = self {
                            weakSelf.alpha = 0
                        }
        }) {[weak self] (isFinish) in
            if let weakSelf = self {
                if isFinish {
                    weakSelf.isHidden = true
                    if shouldRemove {
                        weakSelf.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.7
        animation.values = [-8.0, 8.0, -7.0, 7.0, -5.0, 5.0, -2.0, 2.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
    
    func animateBumpEffect() {
        UIView.animate(withDuration: kAnimationTime,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: [.curveEaseOut, .allowUserInteraction],
                       animations: {
                        self.transform = CGAffineTransform.init(scaleX: 0.97, y: 0.97)
        },
                       completion: { (isComplete) in
                        if isComplete {
                            UIView.animate(withDuration: kAnimationTime,
                                           delay: 0,
                                           usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 0,
                                           options: [.curveEaseIn, .allowUserInteraction],
                                           animations: {
                                            self.transform = CGAffineTransform.identity
                            },
                                           completion: nil)
                        }
        })
    }
    
    func animateExpandBumpEffect(otherAnimations: (()->())? = nil, completionHandler: (()->())? = nil) {
        UIView.animate(withDuration: kAnimationTime,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: [.curveEaseOut, .allowUserInteraction],
                       animations: { [weak self] in
                        if let weakSelf = self {
                            weakSelf.transform = CGAffineTransform.init(scaleX: 1.01, y: 1.01)
                            otherAnimations?()
                        }
            },
                       completion: { (isComplete) in
                        if isComplete {
                            UIView.animate(withDuration: kAnimationTime,
                                           delay: 0,
                                           usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 0,
                                           options: [.curveEaseIn, .allowUserInteraction],
                                           animations: {[weak self] in
                                            if let weakSelf = self {
                                                weakSelf.transform = CGAffineTransform.identity
                                            }
                                },
                                           completion: { (isComplete) in
                                            if isComplete {
                                                completionHandler?()
                                            }
                            })
                        }
        })
    }
    
    func dropShadow(color: UIColor = UIColor.lightGray,
                    opacity: Float = 0.75,
                    offSet: CGSize = CGSize.zero,
                    radius: CGFloat = 2,
                    scale: Bool = true,
                    cornerRadius: CGFloat = 0) {
        
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    enum GradientDirection {
        case leftToRight
        case rightToLeft
        case topToBottom
        case bottomToTop
    }
    
    func gradientBackground(from color1: UIColor, to color2: UIColor, direction: GradientDirection) {
        let kShadowLayer = "ShadowLayer"
        
        var shouldRecreateShadowLayer = true
        
        layer.sublayers?.forEach({ (layer) in
            if let name = layer.name,
                name == kShadowLayer {
                layer.frame = self.bounds
                shouldRecreateShadowLayer = false
            }
        })
        
        if !shouldRecreateShadowLayer {
            return
        }
        
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [color1.cgColor, color2.cgColor]
        gradient.name = kShadowLayer
        
        switch direction {
        case .leftToRight:
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        case .rightToLeft:
            gradient.startPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 0.0, y: 0.5)
        case .bottomToTop:
            gradient.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 0.0)
        default:
            break
        }
        
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func applyCornerRadiusOf(radii: CGFloat) {
        layer.cornerRadius = radii
        clipsToBounds = true
    }
    
    func removeRoundedCorners() {
        layer.cornerRadius = 0
        clipsToBounds = false
    }
    
    func applyBorderOf(size: CGFloat, color: UIColor) {
        layer.borderColor = color.cgColor
        layer.borderWidth = size
    }
    
    func removeBorder() {
        layer.borderWidth = 0
    }
    
    func startShimmering() {
        let light = UIColor.white.withAlphaComponent(0.1).cgColor
        let dark = UIColor.black.cgColor
        
        let gradient = CAGradientLayer()
        gradient.colors = [dark, light, dark]
        gradient.frame = CGRect(x: -self.bounds.size.width, y: 0,
                                width: 3 * self.bounds.size.width, height: self.bounds.size.height)
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.525)
        gradient.locations = [0.4, 0.5, 0.6]
        self.layer.mask = gradient
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1.5
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        gradient.add(animation, forKey:
            "shimmer")
    }
    
    func stopShimmering() {
        self.layer.mask = nil
    }
    
    var width : CGFloat {
        return self.frame.size.width
    }
    
    var height : CGFloat {
        return self.frame.size.height
    }
    
    func putCraterAt(frame: CGRect,
                     cornerRadius: CGFloat) {
        let path = CGMutablePath()
        path.addRoundedRect(in: frame,
                            cornerWidth: cornerRadius,
                            cornerHeight: cornerRadius)
        path.addRect(bounds)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd
        layer.mask = maskLayer
    }
}

extension CALayer {
    class func performWithoutAnimation(_ actionsWithoutAnimation: () -> Void){
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        actionsWithoutAnimation()
        CATransaction.commit()
    }
}

extension UITextView {
    var currentWordTuple : (currentWord: String?, currentWordRange: UITextRange?, curentWordNSRange: NSRange?) {
        let beginning = beginningOfDocument
        
        if let start = position(from: beginning, offset: selectedRange.location),
            let end = position(from: start, offset: selectedRange.length) {
            
            let textRange = tokenizer.rangeEnclosingPosition(end, with: .word, inDirection: 1)
            
            if let textRange = textRange {
                let nsRange = nsRangeFromTextRange(textRange: textRange)
                return (text(in: textRange), textRange, nsRange)
            }
        }
        return (nil, nil, nil)
    }
    
    func nsRangeFromTextRange(textRange: UITextRange) -> NSRange {
        let location:Int = offset(from: beginningOfDocument, to: textRange.start)
        let length:Int = offset(from: textRange.start, to: textRange.end)
        return NSMakeRange(location, length)
    }
    
    func cursorFrame() -> CGRect? {
        if let cursorStart = selectedTextRange?.start {
            return caretRect(for: cursorStart)
        }
        return nil
    }
    
    var isTruncated: Bool {
        guard let textViewText = text else {
            return false
        }
        
        if let font = self.font {
            let textViewSize = textViewText.size(for: self.frame.size.width, font: font)
            return textViewSize.height > bounds.size.height
        }
        return false
    }
}

extension UIViewController {
    var navigationBarHeight : CGFloat {
        return self.navigationController?.navigationBar.frame.height ?? 0
    }
    
    var topInset : CGFloat {
        if let _navigationController = self.navigationController,
            _navigationController.navigationBar.isHidden {
            return kStatusBarHeight
        } else {
            return (self.navigationController?.navigationBar.frame.height ?? 0) + kStatusBarHeight
        }
    }
    
    var isModal: Bool {
        if let index = navigationController?.viewControllers.index(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController  {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
    
    var tabbarHeight : CGFloat {
        if let isTabbarHidden = tabBarController?.tabBar.isHidden,
            !isTabbarHidden,
            !hidesBottomBarWhenPushed {
            return tabBarController?.tabBar.frame.size.height ?? 0
        }
        return 0
    }
    
    var viewWidth : CGFloat {
        return view.frame.size.width
    }
    
    var viewHeight : CGFloat {
        return view.frame.size.height
    }
    
    func showDismissButtonIfPresentedModally(color: UIColor = UIColor.black,
                                             title: String = "X") {
        // Configure navbar buttons
        let btnLeft = UIButton(type: .system)
        btnLeft.setTitle(title, for: .normal)
        btnLeft.setTitleColor(color, for: .normal)
        btnLeft.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btnLeft.sizeToFit()
        btnLeft.addTarget(self,
                          action: #selector(self.didTapDismiss),
                          for: .touchUpInside)
        let leftBarBtnItem = UIBarButtonItem(customView: btnLeft)
        self.navigationItem.setLeftBarButton(leftBarBtnItem, animated: false)
    }
    
    @objc private func didTapDismiss() {
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                weakSelf.dismiss(animated: true, completion: nil)
            }
        }
    }

    func isPresentedModally() -> Bool {
        if self.presentingViewController != nil {
            return true
        } else if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        } else if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
    
    func showErrorWith(title : String? = nil, message : String?) {
        DispatchQueue.main.async { [weak self] in

            let errorAlert = UIAlertController.init(title: title ?? kOops,
                                                    message: message ?? kSomethingWrongError,
                                                    preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction.init(title: "Ok", style: .cancel, handler: nil))

            if let weakSelf = self {
                weakSelf.present(errorAlert,
                                 animated: true,
                                 completion: nil)
            }
        }
    }
    
    func showSuccessAlertWith(title : String? = nil,
                              message : String) {
        DispatchQueue.main.async {[weak self] in
            let errorAlert = UIAlertController.init(title: title ?? kSuccess,
                                                    message: message,
                                                    preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction.init(title: "Ok", style: .cancel, handler: nil))
            
            if let weakSelf = self {
                weakSelf.present(errorAlert,
                                 animated: true,
                                 completion: nil)
            }
        }
    }    
}

class Dynamic<T> {
    typealias Listener = (T) -> ()
    var listener: Listener?
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ v: T) {
        value = v
    }
}

extension String {
    func getUIColor() -> UIColor {
        var cString : String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count == 8 {
            var hex8: UInt32 = 0
            
            if Scanner(string: cString).scanHexInt32(&hex8) {
                let divisor = CGFloat(255)
                let alpha = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
                let red = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
                let green = CGFloat((hex8 & 0x0000FF00) >>  8) / divisor
                let blue = CGFloat(hex8 & 0x000000FF) / divisor
                return UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
            }
        } else {
            var rgbValue: UInt32 = 0
            Scanner(string: cString).scanHexInt32(&rgbValue)
            
            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        }
        return UIColor.gray
    }
    
    // Get Item id separated by colon
    func getColonSeparatedID() -> String {
        let components = self.components(separatedBy: ":")
        
        if components.count >= 2 {
            return components[1]
        } else {
            return components[0]
        }
    }
    
    func htmlStringWith(font: UIFont,
                        textColor: UIColor = UIColor.black) -> NSMutableAttributedString? {
        guard let data = self.data(using: String.Encoding.unicode,
                                   allowLossyConversion: true) else {
                                    return nil
        }
        
        let attributedString = try? NSMutableAttributedString(data: data,
                                                              options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html],
                                                              documentAttributes: nil)
        if let _attributedString = attributedString {
            attributedString!.addAttributes([NSAttributedStringKey.font : font,
                                             NSAttributedStringKey.foregroundColor : textColor],
                                            range: _attributedString.string.getRange())
        }
        
        return attributedString
    }
    
    var trimmedString: String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func getRange() -> NSRange {
        return NSMakeRange(0, (self as NSString).length)
    }
    
    var url: URL? {
        return URL.init(string: self)
    }
    
    var nonOptionalURL: URL? {
        if let url = URL.init(string: self) {
            return url
        }
        return URL.init(fileURLWithPath: self)
    }
    
    var imageURL: URL? {
        return URL.init(fileURLWithPath: self)
    }
    
    func toBool() -> Bool {
        switch self {
        case "True", "true", "yes", "YES", "Yes", "1":
            return true
            
        case "False", "false", "no", "NO", "No", "0":
            return false
            
        default:
            return false
        }
    }
    
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
    
    func size(for width: CGFloat, font: UIFont) -> CGRect {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize,
                                           options: [.usesLineFragmentOrigin],
                                           attributes: [NSAttributedStringKey.font: font],
                                           context: nil)
        return actualSize
    }
    
    var doubleValue: Double? {
        return Double(self)
    }
    var floatValue: Float? {
        return Float(self)
    }
    var integerValue: Int? {
        return Int(self)
    }
    
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    func capturedGroups(withRegex pattern: String) -> [String]? {
        var results : [String]? = []
        
        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return results
        }
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count))
        
        guard let match = matches.first else { return results }
        
        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return results }
        
        for i in 1...lastRangeIndex {
            let capturedGroupIndex = match.range(at: i)
            let matchedString = (self as NSString).substring(with: capturedGroupIndex)
            results?.append(matchedString)
        }
        
        return results
    }
}

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}

extension UILabel {
    func textHeight(for width: CGFloat) -> CGFloat {
        return textRect(forBounds: CGRect.init(x: 0, y: 0, width: width, height: 5),
                        limitedToNumberOfLines: numberOfLines).height
    }
    
    func attributedTextHeight(for width: CGFloat) -> CGFloat {
        guard let attributedText = attributedText else {
            return 0
        }
        return attributedText.height(for: width)
    }
    func underLine() {
        if let textUnwrapped = self.text {
            let underlineAttribute = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
            let underlineAttributedString = NSAttributedString(string: textUnwrapped, attributes: underlineAttribute)
            self.attributedText = underlineAttributedString
        }
    }
    func strikeThrough() {
        if let textUnwrapped = self.text {
            let strikeTextAttributes: [NSAttributedStringKey : Any] = [
                NSAttributedStringKey.strikethroughStyle : 1.0,
                ]
            let strikedText = NSAttributedString(string: textUnwrapped, attributes: strikeTextAttributes)
            self.attributedText = strikedText
        }
    }
}

extension NSAttributedString {
    func height(for width: CGFloat) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = boundingRect(with: maxSize,
                                      options: [.usesLineFragmentOrigin],
                                      context: nil)
        return actualSize.height
    }
}

extension Int {
    var stringValue : String {
        return "\(self)"
    }
}

extension UIEdgeInsets {
    var horizontal: CGFloat {
        return self.left + self.right
    }
    
    var vertical: CGFloat {
        return self.top + self.bottom
    }
}

extension Optional where Wrapped == Int {
    var nonOptionalStringValue : String {
        if self != nil {
            return "\(self!)"
        }
        return "0"
    }
    
    var optionalStringValue : String? {
        if self != nil {
            return "\(self!)"
        }
        return nil
    }
    
    var isIntegerNilOrZero : Bool {
        if self != nil {
            return self! == 0
        }
        return true
    }
}

extension Optional where Wrapped == Double {
    var nonOptionalStringValue : String {
        if self != nil {
            return "\(self!)"
        }
        return "0"
    }
    
    var optionalStringValue : String? {
        if self != nil {
            return "\(self!)"
        }
        return nil
    }
    
    var isDoubleNilOrZero : Bool {
        if self != nil {
            return self! == 0
        }
        return true
    }
}

extension Optional where Wrapped == Double {
    var isCGFloatNilOrZero : Bool {
        if self != nil {
            return self!.isZero
        }
        return true
    }
}
extension Dictionary {
    mutating func merge(with dict: Dictionary, onlyNonNilValues: Bool) {
        dict.forEach { (newDictKey, newDictValue) in
            updateValue(newDictValue, forKey: newDictKey)
        }
    }
}

extension Optional where Wrapped: Collection {
    func nilOrEmptyCollection() -> Bool {
        guard let value = self else { return true }
        return value.isEmpty
    }
    
    func hasElements() -> Bool {
        return !nilOrEmptyCollection()
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_IN")
        formatter.timeZone = TimeZone(identifier:"GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
}

extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

class CommonUtilities: NSObject {
    
    static let shared = CommonUtilities()
    
    class func timeAgoSinceDate(_ date: Date, currentDate: Date, numericDates: Bool) -> String {
        
        let calendar = Calendar.current
        let now = currentDate
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
    }
    
    func fadeIn(view : UIView) {
        UIView.animate(withDuration: kAnimationTime) {
            view.alpha = 1
        }
    }
    
    func fadeOut(view : UIView) {
        UIView.animate(withDuration: 0.2,
                       animations: {
                        view.alpha = 0
        }) { (isFinish) in
            if isFinish {
                view.removeFromSuperview()
            }
        }
    }
    
    class func shake(view : UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.7
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.0, 2.0, 0.0]
        view.layer.add(animation, forKey: "shake")
    }
    
    class func topViewController() -> UIViewController? {
        var top = UIApplication.shared.keyWindow?.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
    
    class func concat(str1: String?, str2: String?, separator: String) -> String? {
        if !str1.isOptionalStringNilOrEmpty && !str2.isOptionalStringNilOrEmpty {
            return "\(str1!)\(separator)\(str2!)"
        }
        
        if !str1.isOptionalStringNilOrEmpty {
            return str1!
        }
        
        if !str2.isOptionalStringNilOrEmpty {
            return str2!
        }
        return nil
    }
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    class func getCacheDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    class func RangeIntToRangeStringIndex(str: String, range: Range<Int>) -> Range<String.Index>? {
        guard range.lowerBound <= str.count && range.upperBound <= str.count else {
            return nil
        }
        return (str.index(str.startIndex,
                          offsetBy: range.lowerBound)..<str.index(str.startIndex,offsetBy: range.upperBound))
    }
    
    class func fixOrientation(img: UIImage?) -> UIImage? {
        if let img = img {
            if (img.imageOrientation == .up) {
                return img
            }
            
            UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
            let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
            img.draw(in: rect)
            
            let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            return normalizedImage
        }
        return nil
    }
    
    class func getEncodedString(from str: String) -> String {
        let numberOfSafeDigits : Int = str.count / 4
        
        if numberOfSafeDigits == 0 {
            return str
        }
        
        let startLocation = str.index(str.startIndex, offsetBy: numberOfSafeDigits)
        let endLocation = str.index(str.endIndex, offsetBy: -(numberOfSafeDigits + 1))
        let rangeToBeReplaced = startLocation...endLocation
        
        return str.replacingCharacters(in: rangeToBeReplaced,
                                       with: String(repeating: "X",
                                                    count: str.distance(from: startLocation, to: endLocation) + 1))
    }
    
    class func abbreviateNumber(intNumber: Int) -> String {
        // Less than 1000, no abbreviation
        if intNumber < 1000 {
            return "\(intNumber)"
        }
        
        // Less than 1 million, abbreviate to thousands
        if intNumber < 1000000 {
            var n = Double(intNumber);
            n = floor(n/100) / 10
            
            let numberWithoutRemainder = n.truncatingRemainder(dividingBy: 1)
            
            if numberWithoutRemainder == 0 {
                return "\(Int(n))k"
            } else {
                return "\(n.description)k"
            }
        }
        
        // More than 1 million, abbreviate to millions
        var n = Double(intNumber)
        n = floor(n/100000) / 10
        
        let numberWithoutRemainder = n.truncatingRemainder(dividingBy: 1)
        
        if numberWithoutRemainder == 0 {
            return "\(Int(n))m"
        } else {
            return "\(n.description)m"
        }
    }
    
    class func getButtonForNavbarWith(image: UIImage) -> UIButton {
        let btn = UIButton.init(type: .system)
        btn.setImage(image, for: .normal)
        btn.frame = CGRect.init(x: 0, y: 0, width: 35, height: 30)
        return btn
    }
    
    class func shareOnWhatsApp(text: String) -> Bool {
        let urlString = "whatsapp://send?text=\(text)"
        
        if let strEncodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL.init(string: strEncodedURL),
            UIApplication.shared.canOpenURL(url) {
            
            // Open whatsappp
            UIApplication.shared.openURL(url)
            return true
        } else {
            return false
        }
    }
    
    class func canShareOnWhatsApp() -> Bool {
        let urlString = "whatsapp://send"
        
        if let strEncodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL.init(string: strEncodedURL) {
            
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    class func isValid(strEmail: String?) -> Bool {
        guard let strEmail = strEmail else { return false}
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: strEmail)
    }
    
    class func isValid(strNumber: String?) -> Bool {
        guard let strNumber = strNumber else {
            return false
        }
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: strNumber)
        return result
    }
    
    class func isValid(password: String?) -> Bool {
        guard let strPassword = password else {
            return false
        }
        let pwdRegex = "^(?=.*[a-z])(?=.*[$@$#!%{}*?&])[A-Za-z\\d$@$#!%*?&]{6,}"
        let pwdTest = NSPredicate(format: "SELF MATCHES %@", pwdRegex)
        let result =  pwdTest.evaluate(with: strPassword)
        return result
    }
 }
