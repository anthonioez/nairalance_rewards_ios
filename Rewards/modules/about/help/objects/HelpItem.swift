//
//  HelpItem.swift
//  Rewards
//
//  Created by Anthonio Ez on 09/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class HelpItem: NSObject
{
    var title: String = ""
    var desc: String = ""
    var image: UIImage! = nil;
    
    init(image: UIImage?, title: String, desc: String)
    {
        self.title = title;
        self.desc = desc;
        self.image = image;
    }
}
