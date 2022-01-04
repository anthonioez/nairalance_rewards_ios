//
//  UIViewEx.swift
//  MyFin
//
//  Created by Anthonio Ez on 07/03/2018.
//

import UIKit
import QuartzCore

extension UIView
{

    func rounded(_ radius: CGFloat = 0)
    {
        var r = radius;
        
        if(r == 0)
        {
            r = bounds.height / 2;
        }
        
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topLeft , .topRight, .bottomLeft, .bottomRight],
                                     cornerRadii: CGSize(width: r, height: r))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.layer.bounds; // bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    func layerBorder(radius: CGFloat, border: CGFloat, color: UIColor)
    {
        layer.borderWidth = border;
        layer.borderColor = color.cgColor;
        layer.cornerRadius = radius;
    }
    
    // OUTPUT 1
    func dropShadow(_ scale: Bool = true)
    {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 5
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func shadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true)
    {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }

    func raiseShadow()
    {
        self.shadow(color: UIColor.black, opacity: 0.4, offSet: CGSize(width: 0, height: -2), radius: 4, scale: true);
    }
    
    func dropShadow()
    {
        self.shadow(color: UIColor.black, opacity: 0.4, offSet: CGSize(width: 0, height: 2), radius: 4, scale: true);
    }
}

