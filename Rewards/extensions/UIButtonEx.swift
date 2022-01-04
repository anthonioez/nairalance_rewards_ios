//
//  UIButtonEx.swift
//  Rewards
//
//  Created by Anthonio Ez on 02/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

extension UIButton
{
    func setActive(_ active: Bool)
    {
        self.alpha = active ? 1.0 : 0.45;
        self.isEnabled = active;
    }
}
