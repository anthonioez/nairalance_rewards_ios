//
//  ListingsItem.swift
//  nairalance
//
//  Created by Anthonio Ez on 06/08/2016.
//  Copyright © 2016 Anthonio Ez. All rights reserved.
//

import Foundation

class ListingsItem
{
    var id: Int
    var type: SettingsType
    var title: String
    var descOn: String
    var descOff: String
    var image: UIImage? = nil;
    var imageColor: UIColor? = nil;
    
    init(id: Int, type: SettingsType, title: String, descOn: String, descOff: String)
    {
        self.id = id;
        self.type = type;
        
        self.title = title;
        self.descOn = descOn;
        self.descOff = descOff;
    }
    
    init(id: Int, type: SettingsType, title: String, desc: String, image: UIImage? = nil, color: UIColor? = nil)
    {
        self.id = id;
        self.type = type;
        self.title = title;
        
        self.descOn = desc;
        self.descOff = desc;
        self.image = image;
        self.imageColor = color;
    }
    
    init(id: Int, type: SettingsType, title: String)
    {
        self.id = id;
        self.type = type;
        self.title = title;
        
        self.descOn = "";
        self.descOff = "";
    }
    
    init(id: Int, type: SettingsType)
    {
        self.id = id;
        self.type = type;
        self.title = "";
        
        self.descOn = "";
        self.descOff = "";
    }
}


enum SettingsType: Int
{
    case spacer = -2
    case section = -1
    case toggle = 0
    case link = 1
}
