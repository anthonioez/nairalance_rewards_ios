//
//  DigitInput.swift
//  Rewards
//
//  Created by Anthonio Ez on 03/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

@IBDesignable public class DigitInput : UIView, UITextFieldDelegate
{
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var digitBox1: DigitBox!
    @IBOutlet weak var digitBox2: DigitBox!
    @IBOutlet weak var digitBox3: DigitBox!
    @IBOutlet weak var digitBox4: DigitBox!

    public weak var delegate: DigitInputDelegate?
    
    let nibName = "DigitInput"
    
    @IBInspectable public var inputText : String?
    {
        get
        {
            return textInput.text;
        }
        
        set(value)
        {
            textInput.text = value
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
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        //view.backgroundColor = UIColor.clear;
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
        //self.backgroundColor = UIColor.clear;
        
    }
    
    override public func awakeFromNib()
    {
        super.awakeFromNib();
        
        textInput.delegate = self;
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        displayInput("")
    }
    
    //MARK: UITextFieldDelegate
    public func textFieldDidBeginEditing(_ textField: UITextField)
    {
        displayInput(textInput.text!);

        digitBox1.setCursor(true);

        self.delegate?.inputBegin(self);
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField)
    {
        /*
        digitBox1.setCursor(false);
        digitBox2.setCursor(false);
        digitBox3.setCursor(false);
        digitBox4.setCursor(false);*/

        self.delegate?.inputEnd(self);
    }
    

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let oldLength = textField.text!.count;
        let replacementLength = string.count;
        let rangeLength = range.length;
        
        let newLength = oldLength - rangeLength + replacementLength;
        
        //let returnKey = string.range(of: "\n"). [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= 4;  // || returnKey;
    }
    
    //MARK: Notification
    @objc func textDidChange(_ notification: Notification)
    {
        let text = textInput.text;
        self.displayInput(text!)
        
        if(text!.count == 0)
        {
            digitBox1.setCursor(true);
        }
        
        if(text!.count >= 4)
        {
            textInput.resignFirstResponder();
        }
        
        self.delegate?.inputChanged(self)
    }
    
    //MARK: Funcs
    func input() -> String?
    {
        return textInput.text;
    }

    func setInput(_ text: String)
    {
        textInput.text = text;
        displayInput(text);
    }
    
    func setActive(_ active: Bool)
    {
        textInput.isEnabled = active;
    }

    func addListener(target: Any?, action: Selector, events: UIControlEvents)
    {
        textInput.addTarget(target, action: action, for: events)
    }
    
    func becomeResponder() -> Bool
    {
        return textInput.becomeFirstResponder();
    }
    
    func resignResponder() -> Bool
    {
        return textInput.resignFirstResponder()
    }
    
    func displayInput(_ text: String)
    {
        for i in stride(from: 0, to: 4, by: 1)
        {
            var digit = "";
            if(text.count > 0 && i < text.count)
            {
                digit =  text.substr(start: i).substr(to: 1);  // [text substringWithRange: NSMakeRange(i, 1)];
            }
    
            if(i == 0)
            {
                digitBox1.setDigit(digit)
            }
            else if(i == 1)
            {
                digitBox2.setDigit(digit)
            }
            else if(i == 2)
            {
                digitBox3.setDigit(digit)
            }
            else if(i == 3)
            {
                digitBox4.setDigit(digit)
            }    
        }
    }
    
    func resign()
    {
        self.textInput.resignFirstResponder();
    }
}

public protocol DigitInputDelegate : NSObjectProtocol
{
    func inputBegin     (_ input: DigitInput!);
    func inputEnd       (_ input: DigitInput!);
    func inputChanged   (_ input: DigitInput!);
}
