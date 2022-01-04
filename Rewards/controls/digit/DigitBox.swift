//
import UIKit

@IBDesignable public class DigitBox : UIView, UITextFieldDelegate
{
    @IBOutlet weak var imageDot: UIImageView!
    @IBOutlet weak var labelDigit: UILabel!
    @IBOutlet weak var viewActive: UIView!
    let nibName = "DigitBox"

    @IBInspectable public var titleText : String?
    {
        get
        {
            return labelDigit.text;
        }
        
        set(value)
        {
            labelDigit.text = value
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
        //view.backgroundColor = UIColor.clear;
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
        //self.backgroundColor = UIColor.clear;
        
        //labelDigit.font = Rewards.fontBold;
    }
    
    func setDigit(_ digit: String)
    {
        labelDigit.text = digit;
        imageDot.isHidden = digit.count > 0
        
        setCursor(digit.count > 0)
    }
    
    func setCursor(_ show: Bool)
    {
        viewActive.backgroundColor = show ? Rewards.colorPassive : UIColor.clear;
    }
}
