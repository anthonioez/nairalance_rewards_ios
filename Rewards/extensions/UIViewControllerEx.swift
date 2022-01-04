//
//  UIViewControllerEx.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

extension UIViewController
{
    func shouldLoadNext(_ index: Int, count: Int, last: Double, loading: Bool, infinite: Bool) -> Bool
    {
        if(count > 0 && index >= (count - 1) && !loading && infinite)
        {
            if ((DateTime.currentTimeMillis() - last) >= 3000)
            {
                return true
            }
        }
        
        return false
    }
}
