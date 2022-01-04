//
//  Keyboarder.swift
//  MyFin
//
//  Created by Anthonio Ez on 06/03/2018.
//

import UIKit

public class Keyboarder: NSObject
{
    public var keyboardSize: CGSize!;
    public var currentInput: UIView!;

    var view: UIView!;
    var scrollView: UIScrollView!;
    var delegate: KeyboarderDelegate?

    var tapGesture: UITapGestureRecognizer!
    
    override public init()
    {
        
    }
    
    init(_ view: UIView, _ scrollView: UIScrollView, delegate: KeyboarderDelegate?)
    {
        super.init()
        
        self.view = view;
        self.scrollView = scrollView;
        self.delegate = delegate;

        
        self.tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(viewTap));
        self.tapGesture.cancelsTouchesInView = false

        self.keyboardSize = CGSize();
        self.currentInput = nil;
    }
    
    func viewWillAppear()
    {
        self.view.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func viewWillDisappear()
    {
        self.view.removeGestureRecognizer(tapGesture)

        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object:nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object:nil)
    }
    
    @objc func viewTap(sender: UITapGestureRecognizer)
    {
        hideKeyboard()
    }
    
    func inputBegin(_ view: UIView)
    {
        currentInput = view;
        
        keyboardScroll();
    }
    
    func inputEnd(_ view: UIView)
    {
        currentInput = nil;
    }
    
    //MARK: Keyboard
    @objc func keyboardWillHide(sender: NSNotification)
    {
        keyboardUnscroll()
    }
    
    @objc func keyboardDidShow(sender: NSNotification)
    {
        let info: NSDictionary = sender.userInfo! as NSDictionary;
        keyboardSize = (info.object(forKey: UIKeyboardFrameBeginUserInfoKey) as AnyObject).cgRectValue.size;
        
        self.keyboardScroll();
    }
    
    func keyboardUnscroll()
    {
        keyboardSize = .zero;   //CGSize(width: 0, 0);
        
        self.scrollView.setContentOffset(.zero, animated: true)
    }
    
    func keyboardScroll()
    {
        if(keyboardSize.height == 0)
        {
            return;
        }
        
        if(currentInput == nil)
        {
            return;
        }
        
        //let scrollRect0 = self.scrollView.frame
        let scrollRect = self.scrollView.convert(self.scrollView.frame, to:nil)
        
        //var frameRect0 = self.view.bounds;
        var frameRect = self.view.convert(self.view.bounds, to:nil)

        var textRect = currentInput.frame
        //var textRect = self.currentInput.convert(self.currentInput.frame, to:nil)

        frameRect.size.height -= (keyboardSize.height + 50)
        
        textRect.origin.y += scrollRect.origin.y;
        
        if(!frameRect.contains(textRect))
        {
            UIView.animate(withDuration: 1.0, animations:
            {
                let offsetY: CGFloat = textRect.origin.y - scrollRect.origin.y - (frameRect.size.height / 2) + (textRect.size.height / 2);
                
                self.scrollView.contentOffset = CGPoint(x: 0.0, y: offsetY);
            }, completion: nil)
        }
    }
    
    public func hide()
    {
        hideKeyboard()
    }
    
    func hideKeyboard()
    {
        self.view.becomeFirstResponder()
        self.delegate?.keyboarderResign(self);
        self.keyboardUnscroll();
    }
}


public protocol KeyboarderDelegate : NSObjectProtocol
{
    func keyboarderResign     (_ keyboarder: Keyboarder!);
}
