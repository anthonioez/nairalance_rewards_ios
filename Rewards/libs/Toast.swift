//
//  Toast.swift
//  Rewards
//
//  Created by Anthonio Ez on 16/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

var ToastView: UnsafePointer<UIView>? =   nil
var ToastTimer: UnsafePointer<Timer>? =   nil

class Toast: NSObject
{
    static var font                 = UIFont.systemFont(ofSize: 14)
    
    static var verticalMargin       = CGFloat(10);
    static var horizontalMargin     = CGFloat(15);
    
    static var verticalOffset       = CGFloat(20);
    static var horizontalOffset     = CGFloat(20);

    static var minHeight            = CGFloat(40);
    
    static var fadeDuration         = 0.5
    static var cornerRadius         = CGFloat(4)
    
    static var boxColor             = UIColor.black.withAlphaComponent(0.75);
    static var textColor            = UIColor.white

    var toast: UIView! = nil;

    enum Gravity
    {
        case top
        case bottom
        case middle
    }
    
    @discardableResult
    static func show(_ message: String, _ duration: Int = 3, _ gravity: Gravity = .bottom ) -> Toast
    {
        let window = UIApplication.shared.delegate!.window!!
        let toast = Toast();
        toast.show(window, message, duration, gravity);
        return toast;
    }
    
    @discardableResult
    static func show(_ view: UIView!, _ message: String, _ duration: Int = 3, _ gravity: Gravity = .bottom ) -> Toast
    {
        let toast = Toast();
        toast.show(view, message, duration, gravity);
        return toast;
    }
    
    @discardableResult
    func show(_ view: UIView, _ message: String, _ duration: Int, _ gravity: Gravity = .bottom ) -> Toast
    {
        let existToast = objc_getAssociatedObject(self, &ToastView) as! UIView?
        if existToast != nil
        {
            if let timer: Timer = objc_getAssociatedObject(existToast!, &ToastTimer) as? Timer
            {
                timer.invalidate();
            }
            self.hide(existToast!, force: true);
        }

        let rect = view.bounds;
        
        let width = min(300, rect.width - (Toast.horizontalOffset * 2));
        
        let labelWidth = width - (Toast.horizontalMargin * 2);
        
        let labelHeight = message.toastTextHeightForWidth(labelWidth);
        
        let height = max(labelHeight + (Toast.verticalMargin * 2), Toast.minHeight);
        
        var ypos = CGFloat(0);
        
        var inset = UIEdgeInsets.zero;
        if #available(iOS 11, *)
        {
            inset = (UIApplication.shared.delegate?.window??.safeAreaInsets)!;
        }

        switch gravity {
        case .top:
            ypos = Toast.verticalOffset + inset.top;
            break;
        case .bottom:
            ypos = (rect.height - height) - Toast.verticalOffset - inset.bottom;
            break;
        default:
            ypos = (rect.height - height) / 2;
            break;
        }
        
        
        toast = UIView(frame: CGRect(x: (rect.width - width)/2, y: ypos, width: width, height: height))
        toast.backgroundColor = Toast.boxColor;
        toast.layer.cornerRadius = Toast.cornerRadius;
        toast.alpha = 0.0
        toast.dropShadow();
        
        let titleLabel = UILabel(frame: CGRect(x: Toast.horizontalMargin, y: (toast.frame.height - labelHeight) / 2, width: labelWidth, height: labelHeight))
        titleLabel.textColor = Toast.textColor
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.alpha = 1.0
        titleLabel.font = Toast.font;
        titleLabel.text = message
        
        toast.addSubview(titleLabel)
        
        view.addSubview(toast)
        
        objc_setAssociatedObject(self, &ToastView, toast, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        
        UIView.animate(withDuration: Toast.fadeDuration, delay: 0.0, options: ([.curveEaseOut, .allowUserInteraction]), animations: {
            self.toast.alpha = 1.0
        }, completion: { (finished: Bool) in
            let timer = Timer.scheduledTimer(timeInterval: Double(duration), target: self, selector: #selector(self.timeout), userInfo: self.toast, repeats: false)
            objc_setAssociatedObject(self.toast, &ToastTimer, timer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        })
        
        return self;
    }

    @objc func timeout(_ timer: Timer)
    {
        self.hide(timer.userInfo as! UIView, force: false)
    }
    
    func hide(_ toast: UIView!, force: Bool)
    {
        let completeClosure = { (finish: Bool) -> () in
            toast.removeFromSuperview()
            objc_setAssociatedObject(self, &ToastTimer, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        if force
        {
            completeClosure(true)
        }
        else
        {
            UIView.animate(withDuration: Toast.fadeDuration, delay: 0.0, options: ([.curveEaseIn, .beginFromCurrentState]), animations: {
                toast.alpha = 0.0
            },
            completion:completeClosure)
        }
    }
}

extension String
{
    func toastTextHeightForWidth(_ width: CGFloat) -> CGFloat
    {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping;
        
        let attributes = [NSAttributedStringKey.font: Toast.font, NSAttributedStringKey.paragraphStyle:paragraphStyle.copy()]
        
        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size.height
    }
}
