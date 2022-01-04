//
//  UI.swift
//  Rewards
//
//  Created by Anthonio Ez on 03/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class UI: NSObject
{
    static func imageWithColor(_ name: String) -> UIImage?
    {
        let img = UIImage(named: name)
        if (img != nil)
        {
            return img!.withRenderingMode(.alwaysTemplate)
        }
        else
        {
            return nil
        }
    }

    public static func dimView(_ view: UIView, _ dim : Bool, _ animate: Bool = true)
    {
        if(!dim && animate)
        {
            UIView.animate(withDuration: 1, animations: {
                view.alpha = dim ? 0.25 : 1.0;
            })
        }
        else
        {
            view.alpha = dim ? 0.25 : 1.0;
        }
    }
    
    public static func dimViews(_ views: [UIView], _ dim : Bool, _ excepts: [UIView]?)
    {
        if(!dim)
        {
            UIView.animate(withDuration: 1, animations: {
                for view in views
                {
                    if(excepts == nil || !excepts!.contains(view))
                    {
                        dimView(view, dim, false)
                    }
                }
            })
        }
        else
        {
            for view in views
            {
                if(excepts == nil || !excepts!.contains(view))
                {
                    dimView(view, dim, false)
                }
            }
        }
    }
    
    public static func insets() -> UIEdgeInsets
    {
        var inset = UIEdgeInsets.zero;
        if #available(iOS 11, *)
        {
            inset = (UIApplication.shared.delegate?.window??.safeAreaInsets)!;
        }
        return inset;
    }

    static func toast(_ parentView: UIView, _ message: String)
    {
        if(message.trim().isEmpty) { return; }
        
        Toast.show(parentView, message, 3, .bottom)
    }
    
    static func toast(_ message: String)
    {
        if(message.trim().isEmpty) { return; }
        
        Toast.show(message, 3, .bottom)
    }
    
    public static func alert(_ controller: UIViewController, _ title: String, _ message: String)
    {
        alert(controller, title, message, response: nil);
    }
    
    public static func alert(_ controller: UIViewController, _ title: String, _ message: String, response: (() -> Void)?)
    {
        let alertVC = PMAlertController(title: title, description: message, image: nil, style: .alert);
        alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
            
            if(response != nil)
            {
                response!()
            }
        }))
        
        DispatchQueue.main.async {
            controller.present(alertVC, animated: true, completion: nil)
        }
    }
    
    public static func ask(_ controller: UIViewController, title: String, message: String, yes: String, no: String, accept: (() -> Void)?, decline: (() -> Void)?)
    {
        let alertVC = PMAlertController(title: title, description: message, image: nil, style: .alert);

        //let alertVC = alertController(title: title, description: message, image: nil, style: .walkthrough)
        alertVC.addAction(PMAlertAction(title: no, style: .cancel, action: { () in
            
            if(decline != nil)
            {
                decline!()
            }
        }))
        
        alertVC.addAction(PMAlertAction(title: yes, style: .default, action: { () in
            
            if(accept != nil)
            {
                accept!()
            }
        }))
        
        DispatchQueue.main.async {
            controller.present(alertVC, animated: true, completion: nil)
        }
    }
    
    public static func confirm(_ controller: UIViewController, _ title: String, _ message: String, accept: (() -> Void)?, decline: (() -> Void)?)
    {
        ask(controller, title: title, message: message, yes: "Yes", no: "No", accept: accept, decline: decline);
    }
    
    public static func ask(_ controller: UIViewController, title: String, message: String, accept: (() -> Void)?, decline: (() -> Void)?)
    {
        ask(controller, title: title, message: message, yes: "Ok", no: "Cancel", accept: accept, decline: decline);
    }
        
    @discardableResult
    static func showProgress(_ message: String) -> UIView
    {
        return ProgressDialog.show(message);
    }
    
    static func hideProgress()
    {
        ProgressDialog.dismiss();
    }
    
    static func fromHtml(_ text: String, color: UIColor, font: UIFont) -> NSMutableAttributedString
    {
        if let htmlData = text.data(using: String.Encoding.unicode)
        {
            do
            {
                let attr = try NSMutableAttributedString(data: htmlData, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                
                let range = NSMakeRange(0, attr.length)
                
                attr.addAttributes([NSAttributedStringKey.foregroundColor: color], range: range);
                attr.addAttributes([NSAttributedStringKey.font: font], range: range);
                attr.addAttributes([NSAttributedStringKey.underlineColor : UIColor.clear ], range: range)
                attr.addAttributes([NSAttributedStringKey.underlineStyle : NSNumber(value: NSUnderlineStyle.styleNone.rawValue)], range: NSMakeRange(0, attr.length))
                
                return attr;
                
            }
            catch _ as NSError
            {
                return NSMutableAttributedString(string: text)
            }
        }
        else
        {
            return NSMutableAttributedString(string: text)
        }
    }
}
