//
import UIKit

@IBDesignable public class RoundInput : UIView, UITextFieldDelegate
{

    @IBOutlet weak var viewBg: UIView!
    
    @IBOutlet weak var labelPrefix: UILabel!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var labelPrefixLeft: NSLayoutConstraint!
    @IBOutlet weak var buttonSuffix: UIButton!
    @IBOutlet weak var activitySuffix: UIActivityIndicatorView!
    
    @IBOutlet weak var buttonSuffixRight: NSLayoutConstraint!
    public weak var delegate: RoundInputDelegate?
    
    var enabled = true;
    var pickerIndex = -1;
    var pickerList: [[String: String]]! = nil;
    var pickerDate: Date! = nil;
    var pickerDateMin: Date! = nil;
    var pickerDateMax: Date! = nil;
    var regex: NSRegularExpression! = nil;
    
    var maxTextLength: Int = 0;
    
    var tapGesture: UITapGestureRecognizer!

    let nibName = "RoundInput"
    
    public static var textColor = UIColor.black;
    public static var buttonColor = UIColor.blue;
    public static var font = UIFont.systemFont(ofSize: 16)
    
    @IBInspectable public var maxLength : Int
    {
        get
        {
            return maxTextLength;
        }
        
        set(value)
        {
            maxTextLength = value;
        }
    }
    
    @IBInspectable public var prefixText : String?
    {
        get
        {
            return labelPrefix.text;
        }
        
        set(value)
        {
            labelPrefixLeft.constant = (value == nil || value!.trim().isEmpty) ? ((-1 * labelPrefix.frame.width) + 10) : 5
            labelPrefix.text = value!;
        }
    }
    
    @IBInspectable public var suffixProgress : Bool
    {
        get
        {
            return !activitySuffix.isHidden;
        }
        
        set(value)
        {
            buttonSuffixRight.constant = value ? 10 : ((-1 * buttonSuffix.frame.width) + 10)
            buttonSuffix.isHidden = true;
            activitySuffix.isHidden = !value;
            
            if(value)
            {
                activitySuffix.startAnimating()
            }
            else
            {
                activitySuffix.stopAnimating()
            }
        }
    }
    
    @IBInspectable public var suffixIcon : UIImage?
    {
        get
        {
            return buttonSuffix.image(for: .normal);
        }
        
        set(value)
        {
            buttonSuffixRight.constant = (value == nil ? ((-1 * buttonSuffix.frame.width) + 10) : 10)
            buttonSuffix.setImage(value, for: .normal)
            buttonSuffix.isHidden = value == nil;
        }
    }
    
    @IBInspectable public var inputPlaceholder : String?
    {
        get
        {
            return textInput.placeholder
        }
        
        set(value)
        {
            textInput.attributedPlaceholder = NSAttributedString(string: value ?? "", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        }
    }
    
    @IBInspectable public var inputReturn : String?
    {
        get
        {
            return ""; //textInput.keyboardType
        }
        
        set(value)
        {
            if(value != nil)
            {
                if(value == "done")
                {
                    textInput.returnKeyType = UIReturnKeyType.done;
                }
                else if(value == "next")
                {
                    textInput.returnKeyType = UIReturnKeyType.next;
                }
            }
        }
    }
    
    @IBInspectable public var inputType : String?
    {
        get
        {
            return ""; //textInput.keyboardType
        }
        
        set(value)
        {
            if(value != nil)
            {
                if(value == "email")
                {
                    textInput.keyboardType = UIKeyboardType.emailAddress;
                    textInput.autocapitalizationType = UITextAutocapitalizationType.none;
                    //textInput.autocorrectionType = UITextAutocorrectionTypeNo;
                }
                else if(value == "name" || value == "username")
                {
                    if(value == "username")
                    {
                        regex = try! NSRegularExpression(pattern: "[a-zA-Z0-9_]+", options: [])
                        textInput.autocapitalizationType = UITextAutocapitalizationType.none;
                    }
                    else
                    {
                        textInput.autocapitalizationType = UITextAutocapitalizationType.words
                    }
                    
                    textInput.keyboardType = UIKeyboardType.default;
                    textInput.autocorrectionType = UITextAutocorrectionType.no;
                    textInput.spellCheckingType = UITextSpellCheckingType.no
                }
                else if(value == "url")
                {
                    textInput.keyboardType = UIKeyboardType.URL;
                }
                else if(value == "decimal")
                {
                    textInput.keyboardType = UIKeyboardType.decimalPad;
                }
                else if(value == "number")
                {
                    textInput.keyboardType = UIKeyboardType.numberPad;
                }
                else if(value == "phone")
                {
                    textInput.keyboardType = UIKeyboardType.phonePad;
                }
                else if(value == "password")
                {
                    textInput.isSecureTextEntry = true;
                }
                else
                {
                    textInput.keyboardType = UIKeyboardType.default;
                }
            }
            else
            {
                textInput.keyboardType = UIKeyboardType.default;
            }
        }
    }
    
    
    @IBInspectable public var inputText : String?
    {
        get
        {
            return textInput.text;
        }
        
        set(value)
        {
            textInput.text = value!;
        }
    }

    @IBInspectable public var isEnabled : Bool
    {
        get
        {
            return enabled
        }
        
        set(value)
        {
            self.alpha = value ? 1.0 : 0.6;
            self.enabled = value;
            
            if(pickerList == nil)
            {
                textInput.isEnabled = value;
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
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
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        self.backgroundColor = UIColor.clear;
        view.frame = bounds
        view.backgroundColor = UIColor.clear;
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
        
        self.textInput.delegate = self;
        self.textInput.addTarget(self, action: #selector(nextControl), for: UIControlEvents.editingDidEndOnExit);
        self.textInput.addTarget(self, action: #selector(textChanged), for: UIControlEvents.editingChanged)

        //NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        //viewBg.rounded()
        //viewBg.layerBorder(radius: 20, border: 0, color: UIColor.clear)
        
        self.tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap));
        self.tapGesture.cancelsTouchesInView = false
        self.tapGesture.numberOfTapsRequired = 1;

        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap()
    {
        if(enabled)
        {
            if(pickerList != nil)
            {
                let dlg = ItemPicker(textColor: RoundInput.textColor, buttonColor: RoundInput.buttonColor, font: RoundInput.font);
                dlg.show(inputPlaceholder!, list: pickerList, index: pickerIndex == -1 ? 0 : pickerIndex, select: "Select", cancel: "Cancel", callback: { index in
                    
                    if(index >= 0 && index < self.pickerList.count)
                    {
                        self.pickerIndex = index;
                        let item = self.pickerList[index]
                        
                        self.textInput.text = item["title"]
                        
                        self.delegate?.inputChanged?(self)
                    }
                })
            }
            else if(pickerDate != nil)
            {
                let dlg = DatePicker(textColor: RoundInput.textColor, buttonColor: RoundInput.buttonColor, font: RoundInput.font);
                dlg.show(inputPlaceholder!, select: "Select", cancel: "Cancel", defaultDate: pickerDate, minimumDate: pickerDateMin, maximumDate: pickerDateMax, datePickerMode: .date, callback: { date in
                    
                    if(date != nil)
                    {
                        self.pickerDate = date;
                        
                        self.textInput.text = DateTime.stringDate(date!)

                        self.delegate?.inputChanged?(self)
                    }
                })
            }
        }
        
    }
    
    //MARK: - Public
    public func become()
    {
        textInput.becomeFirstResponder()
    }
    
    public func resign()
    {
        textInput.resignFirstResponder()
    }
    
    func setActive(_ active: Bool)
    {
        self.alpha = active ? 1.0 : 0.45;
        //self.isEnabled = active;
        self.textInput.isEnabled = active;
    }
    

    //MARK: Targets
    @objc func textChanged()
    {
        self.delegate?.inputChanged?(self)
    }

    @objc func nextControl()
    {
        self.delegate?.inputNext?(self);
        self.resign();
    }

    //MARK: - UITextFieldDelegate
    public func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.delegate?.inputBegin?(self);
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField)
    {
        self.delegate?.inputEnd?(self);
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        guard let text = textField.text else {
            return true
        }
        
        if(regex != nil)
        {
            let range = regex.rangeOfFirstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count))
            if(range.length != string.count)
            {
                return false;
            }
        }

        if(maxTextLength != 0)
        {
            let newLength = text.count + string.count - range.length;
            
            return newLength <= maxTextLength;
        }
        
        return true;
    }
    
    //MARK: - Actions
    @IBAction func buttonSuffixTap(_ sender: Any)
    {
        if(pickerList != nil)
        {
            //handleTap()
        }
        else
        {        
            self.delegate?.inputSuffix!(self);
        }
    }

    //MARK: - Funcs
    public func setItemPicker(_ items: [[String: String]])
    {
        setSuffixIcon("ic_arrow_drop_down_white_48pt", UIColor.lightGray);

        inputText = "";
        textInput.isEnabled = false;
        pickerList = items;
        pickerIndex = -1;
        pickerDate = nil;
    }
    
    public func setDatePicker(_ date: Date, minDate: Date? = nil, maxDate: Date? = nil, set: Bool = false)
    {
        textInput.isEnabled = false;
        pickerList = nil;
        pickerDate = date;
        pickerDateMin = minDate
        pickerDateMax = maxDate
        
        if(set)
        {
            self.textInput.text = DateTime.stringDate(date)
        }
    }
    
    public var selectedIndex : Int
    {
        get
        {
            return pickerIndex
        }
        set(value)
        {
            pickerIndex = value;
        }
    }
    
    public func getPickerData(_ key: String) -> String
    {
        if(pickerIndex >= 0 && pickerIndex < pickerList.count)
        {
            let item = pickerList[pickerIndex];
            return item[key]!;
        }
        
        return "";
    }
    
    public func setPickerData(_ key: String, _ value: String)
    {
        pickerIndex = -1;
        var index = 0
        for item in pickerList
        {
            if item[key] == value
            {
                pickerIndex = index;
                
                self.textInput.text = item["title"]

                break;
            }
            
            index+=1;
        }
    }
    
    public func getPickerIndex() -> Int
    {
        return pickerIndex;
    }
    
    public func setPickerIndex(_ index: Int)
    {
        if(index >= 0 && index < pickerList.count)
        {
            pickerIndex = index;

            let item = pickerList[pickerIndex];
            self.textInput.text = item["title"]
        }
    }
    
    func setSuffixIcon(_ name: String, _ color: UIColor)
    {
        let img = UIImage(named: name)
        if (img != nil)
        {
            self.buttonSuffix.tintColor = color;
            
            self.suffixIcon = img!.withRenderingMode(.alwaysTemplate)
            self.buttonSuffix.isHidden = false;
        }
        else
        {
            self.buttonSuffix.isHidden = true;
        }
    }
    
}

@objc public protocol RoundInputDelegate : NSObjectProtocol
{
    @objc optional func inputBegin     (_ input: RoundInput!);
    @objc optional func inputEnd       (_ input: RoundInput!);
    @objc optional func inputNext      (_ input: RoundInput!);
    @objc optional func inputChanged   (_ input: RoundInput!);
    @objc optional func inputSuffix    (_ input: RoundInput!);
}
