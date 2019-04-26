

public protocol AddButtonExpandDelegate: AnyObject {
    func buttonWillExpand()
    func buttonWillShrink()
}

open
class AdddButtonExpand: UIButton {
    // MARK: Button properties
    
    open weak var addButtonDelegate: AddButtonExpandDelegate?

    /// plus sign
    open lazy var plusSign: PlusSign = {
        oldBound = bounds
        return PlusSign(frame: bounds)
    }()

    /// determine whether the button is expanded or shrinked
    open private(set) var expanded: Bool = false
    
    /// animate duration
    open var animateDuration: TimeInterval = 1

    /// color object of button
    open var color: UIColor = UIColor.gray {
        didSet {
            layer.backgroundColor = color.cgColor
        }
    }

    /// shrink button back to original form
    open func shrink() {
        animateLayer()
        UIView.animate(withDuration: animateDuration, animations: {
            self.plusSign.frame = self.oldBound
            self.frame = self.oldFrame
        })
    }
    
    open func expand(keyboardFrame: CGRect?) {
        
    }

    /// original frame before expansion
    internal var oldFrame: CGRect

    /// original bound before expansion
    internal var oldBound: CGRect!

    /// initial setup for button
    internal func defaultSetup() {
        layer.backgroundColor = color.cgColor
        layer.cornerRadius = frame.width/2
        addSubview(plusSign)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        addTarget(self, action: #selector(onTap), for: UIControlEvents.touchDown)
    }

    /// get keyboard frame
    @objc internal func keyboardWillShow(notification: Notification) {
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        guard keyboardFrame.contains(frame) else { return }
        animateLayer()
        UIView.animate(withDuration: animateDuration, animations: {
            self.frame.origin = CGPoint(x: 0,
                                        y: keyboardFrame.minY - self.frame.height)
            self.frame.size.width = UIScreen.main.bounds.width
            self.plusSign.frame.origin.x = UIScreen.main.bounds.width/2 - self.plusSign.frame.width/2
        })
    }

    
    @objc internal func keyboardWillHide() {
        shrink()
    }
    
    @objc internal func onTap() {
        if expanded {
            addButtonDelegate?.buttonWillShrink()
        } else {
            addButtonDelegate?.buttonWillExpand()
        }
    }

    /// animation when tapped
    internal func animateLayer() {
        expanded = !expanded
        layer.removeAllAnimations()
        let animate: CABasicAnimation = CABasicAnimation(keyPath: "cornerRadius")
        animate.duration = animateDuration
        animate.fromValue = layer.cornerRadius
        animate.toValue = expanded ? 0 : oldFrame.width/2
        layer.cornerRadius = expanded ? 0 : oldFrame.width/2
        layer.add(animate, forKey: animate.keyPath)
    }
    
    // MARK: - override funcs
    public override init(frame: CGRect) {
        oldFrame = frame
        super.init(frame: frame)
        oldBound = bounds
        defaultSetup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

