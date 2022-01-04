//
import UIKit

@IBDesignable public class TitleBar : UIView, UITextFieldDelegate
{
    public var view:UIView!;
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewTitle: UIView!
    
    let nibName = "TitleBar"
    
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
        
        labelTitle.font = Rewards.fontBold;
    }
}
