//
//  AdViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 16/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class AdViewController: UIViewController, AdmobIntersDelegate
{
    var adInters: AdmobInters! = nil
    var adBanner: AdmobBanner! = nil

    func admobLoadBanner(_ view: UIView!, _ slot: Int, _ paddingTop: CGFloat = 0, _ paddingBottom: CGFloat = 0)
    {
        adBanner = AdmobBanner(self, view, Rewards.admobIdBanner, paddingTop, paddingBottom)
        if(Ad.hasSlot(slot))
        {
            adBanner.prepare();
        }
    }
    
    func admobLoadInters()
    {
        adInters = AdmobInters(self, Rewards.admobIdInters, delegate: self);
        if(Ad.isPossible())
        {
            adInters.load();
        }
    }
    
    func admobShowOrFinish()
    {
        adInters.showOrFinish()
    }


    //MARK: AdmobIntersDelegate
    func onAdInterstLoaded()
    {
        
    }
    
    func onAdInterstOpened()
    {
        //self.navigationController?.popViewController(animated: false)
    }
    
    func onAdInterstClosed()
    {
        self.navigationController?.popViewController(animated: false)
    }
    
    func onAdInterstFailed()
    {
        
    }    
}
