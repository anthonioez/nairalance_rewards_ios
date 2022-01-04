//
//  ListingsDelegate.swift
//  Rewards
//
//  Created by Anthonio Ez on 14/01/2017.
//  Copyright © 2017 Rewards. All rights reserved.
//

import Foundation

protocol ListingsDelegate : NSObjectProtocol
{
    func switchValue(id: Int) -> Bool
    func switchChanged(id: Int, value: Bool)
}

