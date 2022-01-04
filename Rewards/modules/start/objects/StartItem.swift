//
//  StartItem.swift
//  Rewards
//
//  Created by Anthonio Ez on 02/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//
import UIKit
import Foundation

class StartItem: NSObject
{
    var title   = ""
    var icon    = "";
    var desc    = "";
    var ctrl: StartIntroViewController!    = nil

    init(_ icon: String, _ title: String, _ desc: String)
    {
        self.icon   = icon;
        self.title  = title;
        self.desc   = desc;
    }
}
