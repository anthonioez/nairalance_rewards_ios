//
import UIKit

@IBDesignable public class Progress : UIView
{
    //public var view:UIView!;
    
    var style = RTSpinKitViewStyle.bounce;
    var color = UIColor.white;
    var type = "bounce"
    var spinKit: RTSpinKitView!
    
    let nibName = "Progress" 

    @IBInspectable public var animationType : String?
    {
        get
        {
            return type
        }
        
        set(value)
        {
            switch value
            {
            case "bounce":
                style = RTSpinKitViewStyle.bounce;
                break;
            case "wave":
                style = RTSpinKitViewStyle.wave;
                break;
                
            case "pulse":
                style = RTSpinKitViewStyle.pulse;
                break;
                
            case "plane":
                style = RTSpinKitViewStyle.plane;
                break;
                
            case "cubes":
                style = RTSpinKitViewStyle.wanderingCubes;
                break;
                
            default:
                style = RTSpinKitViewStyle.bounce
                break;
            }
            
            type = value ?? "bounce"
            if(style != spinKit.style)
            {
                spinKit?.style = style;
                changed();
            }
        }
    }
    
    @IBInspectable public var objectColor : UIColor?
    {
        get
        {
            return color
        }
        
        set(value)
        {
            color = value ?? UIColor.white
            spinKit?.color = color
            
            changed();
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        loadViewFromNib ()        
    }
        
    func loadViewFromNib()
    {
        spinKit = RTSpinKitView(style: style, color: color);
        spinKit!.hidesWhenStopped = true
        spinKit!.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.addSubview(spinKit!);
        
        let x = (self.frame.width - spinKit.frame.width) / 2
        let y = (self.frame.height - spinKit.frame.height) / 2
        spinKit.frame = CGRect(x: x, y: y, width: spinKit.frame.width, height: spinKit.frame.height)
        spinKit!.sizeToFit();
    }
    
    func animate(_ state: Bool)
    {
        if(state)
        {
            start()
        }
        else
        {
            stop()
        }
    }
    
    func changed()
    {
        spinKit.reload();
        
        if(spinKit.isAnimating())
        {
            spinKit.startAnimating()
        }
    }
    
    func start()
    {
        spinKit!.isHidden = false;
        spinKit!.startAnimating()
    }
    
    func stop()
    {
        spinKit!.stopAnimating()
        spinKit!.isHidden = true;
    }
}
