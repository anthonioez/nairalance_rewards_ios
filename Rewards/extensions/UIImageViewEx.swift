//
//  UIImageViewEx.swift
//  MyFin
//
//  Created by Anthonio Ez on 23/03/2018.
//

import UIKit

extension UIImageView
{
    func circularImage(_ border: Int = 0, _ color: UIColor = UIColor.clear)
    {
        self.contentMode = .scaleAspectFit
        self.layer.cornerRadius = (self.frame.size.width)/2
        self.clipsToBounds = true
        
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = CGFloat(border);
    }

}
