//
//  Progress+UIView.swift
//  Rewards
//
//  Created by Anthonio Ez on 16/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit


class ProgressDialog : NSObject
{
    static let containerViewTag     = 434343543
    static var font                 = UIFont.systemFont(ofSize: 14)
    static var horizontalMargin     = CGFloat(15);
    static var minHeight            = CGFloat(60);
    
    static var verticalOffset       = CGFloat(10);
    static var horizontalOffset     = CGFloat(20);
    
    static var spinnerSize          = CGFloat(40);
    static var spinnerColor         = UIColor.darkGray
    static var fadeDuration         = 0.2
    static var cornerRadius         = CGFloat(4)
    
    static var boxColor             = UIColor(white: 0.96, alpha: 1)
    static var textColor            = UIColor.black.withAlphaComponent(0.75)
    static var backgroundColor      = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)

    fileprivate class func addMainWindowBlocker() -> UIView
    {
        let window = UIApplication.shared.delegate!.window!!
        
        let blocker = UIView(frame: window.bounds)
        blocker.backgroundColor = ProgressDialog.backgroundColor
        blocker.tag = containerViewTag
        
        blocker.translatesAutoresizingMaskIntoConstraints = false
        
        window.addSubview(blocker)
        
        let viewsDictionary = ["blocker": blocker]
        
        // Add constraints to handle orientation change
        let constraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[blocker]-0-|",
                                                          options: NSLayoutFormatOptions(rawValue: 0),
                                                          metrics: nil,
                                                          views: viewsDictionary)
        
        let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "|-0-[blocker]-0-|",
                                                          options: NSLayoutFormatOptions(rawValue: 0),
                                                          metrics: nil,
                                                          views: viewsDictionary)
        
        window.addConstraints(constraintsV + constraintsH)
        
        return blocker
    }

    @discardableResult
    static func show(_ message: String) -> UIView
    {
        let blocker = ProgressDialog.addMainWindowBlocker()
        return show(blocker, message);
    }
    
    static func show(_ view: UIView, _ message: String) -> UIView
    {
        let rect = view.bounds;
        
        let width = min(300, rect.width - (ProgressDialog.horizontalOffset * 2));
     
        let labelWidth = width - ProgressDialog.spinnerSize - (ProgressDialog.horizontalMargin * 2) - 10;
        
        let labelHeight = message.progressTextHeightForWidth(labelWidth) + (ProgressDialog.verticalOffset * 2);
    
        let height = max(labelHeight, ProgressDialog.minHeight);

        let boxView = UIView(frame: CGRect(x: (rect.width - width)/2, y: (rect.height - height)/2, width: width, height: height))
        boxView.backgroundColor = ProgressDialog.boxColor;
        boxView.layer.cornerRadius = ProgressDialog.cornerRadius;
        boxView.dropShadow();
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: labelHeight > ProgressDialog.minHeight ? UIActivityIndicatorViewStyle.whiteLarge : UIActivityIndicatorViewStyle.white)
        activityView.frame = CGRect(x: ProgressDialog.horizontalMargin, y: (boxView.frame.height - ProgressDialog.spinnerSize) / 2, width: ProgressDialog.spinnerSize, height: ProgressDialog.spinnerSize)
        activityView.color = ProgressDialog.spinnerColor
        activityView.startAnimating()
        
        let titleLabel = UILabel(frame: CGRect(x: ProgressDialog.horizontalMargin + activityView.frame.width + 10, y: (boxView.frame.height - labelHeight) / 2, width: labelWidth, height: labelHeight))
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.alpha = 1.0
        titleLabel.font = ProgressDialog.font;
        titleLabel.textColor = ProgressDialog.textColor;
        titleLabel.text = message
        
        boxView.addSubview(activityView)
        boxView.addSubview(titleLabel)
        
        view.addSubview(boxView)
        
        return boxView;
    }
    
    static func dismiss()
    {
        let window = UIApplication.shared.delegate!.window!!
        dismiss(window)
    }

    static func dismiss(_ parentView: UIView)
    {
        var overlay: UIView?
        while true
        {
            overlay = parentView.viewWithTag(containerViewTag)
            if overlay == nil
            {
                break
            }
            
            overlay!.removeFromSuperview()
        }
    }
}

extension String
{
    func progressTextHeightForWidth(_ width: CGFloat) -> CGFloat
    {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping;
        
        let attributes = [NSAttributedStringKey.font: ProgressDialog.font, NSAttributedStringKey.paragraphStyle:paragraphStyle.copy()]
        
        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size.height
    }
}
