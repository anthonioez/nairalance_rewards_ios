//
//  PMAlertAction.swift
//  PMAlertController
//
//  Created by Paolo Musolino on 07/05/16.
//  Copyright © 2016 Codeido. All rights reserved.
//

import UIKit

@objc public enum PMAlertActionStyle : Int {
    
    case `default`
    case cancel
}

@objc open class PMAlertAction: UIButton
{
    fileprivate var action: (() -> Void)?
    
    open var actionStyle : PMAlertActionStyle
    
    var separator = UIImageView()
    
    init(){
        self.actionStyle = .cancel
        super.init(frame: CGRect.zero)
    }
    
    @objc public convenience init(title: String?, style: PMAlertActionStyle, action: (() -> Void)? = nil)
    {
        self.init()
        
        self.action = action
        self.addTarget(self, action: #selector(PMAlertAction.tapped(_:)), for: .touchUpInside)
        
        self.setTitle(title, for: UIControlState())
        //self.backgroundColor = UIColor.lightGray
        self.actionStyle = style
        
        self.addSeparator()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapped(_ sender: PMAlertAction)
    {
        self.action?()
    }
    
    @objc fileprivate func addSeparator()
    {
        /*
        separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        //self.addSubview(separator)
        
        // Autolayout separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *)
        {
            separator.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            separator.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: 8).isActive = true
            separator.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor, constant: -8).isActive = true
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
        else
        {
            // Fallback on earlier versions
        }*/
    }
    
}
