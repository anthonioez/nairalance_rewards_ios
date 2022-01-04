//
import UIKit

@IBDesignable public class MenuBar : UIView, UITextFieldDelegate
{
    //public var view:UIView!;
    
    static let barHeight = CGFloat(50);
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonLeft: UIButton!
    @IBOutlet weak var buttonRight: UIButton!
    @IBOutlet weak var buttonLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewDivider: UIView!
    
    public weak var delegate: MenuBarDelegate?
    
    let nibName = "MenuBar"

    public static var color = UIColor.blue;
    public static var font = UIFont.systemFont(ofSize: 20)

    @IBInspectable public var titleText : String?
    {
        get
        {
            return labelTitle.text;
        }
        
        set(value)
        {
            labelTitle.text = value
        }
    }
    
    @IBInspectable public var leftImage : UIImage?
    {
        get
        {
            return buttonLeft.image(for: .normal);
        }
        
        set(value)
        {
            buttonLeftConstraint.constant = value == nil ? -30 : 15
            buttonLeft.setImage(value, for: .normal)
        }
    }
    
    @IBInspectable public var rightImage : UIImage?
    {
        get
        {
            return buttonRight.image(for: .normal);
        }
        
        set(value)
        {
            buttonRight.setImage(value, for: .normal)
        }
    }
    
    @IBInspectable public var leftHidden : Bool
    {
        get
        {
            return buttonLeft.isHidden
        }
        
        set(value)
        {
            buttonLeft.isHidden = value
        }
    }
    
    @IBInspectable public var rightHidden : Bool
    {
        get
        {
            return buttonRight.isHidden
        }
        
        set(value)
        {
            buttonRight.isHidden = value
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
        
    
    }
        
    func loadViewFromNib()
    {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
        
        view.backgroundColor = MenuBar.color;
        self.backgroundColor = MenuBar.color
        labelTitle.font = MenuBar.font;
    }
    
    func shadow()
    {
        //self.dropShadow();
        self.shadow(color: UIColor.black, opacity: 0.2, offSet: CGSize(width: 0, height: 2), radius: 2, scale: true);
    }
    
    @IBAction func onButtonLeft(_ sender: Any)
    {
        self.delegate?.buttonLeftTapped(self);
    }
    
    @IBAction func onButtonRight(_ sender: Any)
    {
        self.delegate?.buttonRightTapped(self);
    }
}

public protocol MenuBarDelegate : NSObjectProtocol
{
    func buttonLeftTapped   (_ input: MenuBar!);
    func buttonRightTapped  (_ input: MenuBar!);
}
