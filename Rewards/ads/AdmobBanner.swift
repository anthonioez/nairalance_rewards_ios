//
//  AdmobBanner.swift
//  Rewards
//
//  Created by Anthonio Ez on 16/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdmobBanner: NSObject, GADBannerViewDelegate
{
    public static var animated = true;
    
    var controller: UIViewController?;
    var view: UIView! = nil
    
    var admobId = "";
    var paddingTop = CGFloat(0)
    var paddingBottom = CGFloat(0)
    var state: AdState.State = .failed
    var ready = false;
    var heightConstraint: NSLayoutConstraint!
    
    var adView: GADBannerView!

    init(_ controller: UIViewController!, _ view: UIView!, _ admobId: String, _ paddingTop: CGFloat, _ paddingBottom: CGFloat)
    {
        self.controller = controller;
        
        self.admobId = admobId;
        
        self.paddingTop = paddingTop;
        self.paddingBottom = paddingBottom;
        
        self.state = .failed;
        
        self.view = view;
        
        ready = false;
    }
    
    func prepare()
    {
        if(self.view == nil) { return }

        self.view.backgroundColor = .clear;
        
        for constraint in self.view.constraints
        {
            if constraint.firstAttribute == .height, constraint.relation == .equal
            {
                heightConstraint = constraint;
            }
        }

        self.adView = GADBannerView(adSize: kGADAdSizeBanner)
        self.adView.adUnitID = Rewards.admobIdBanner
        self.adView.rootViewController = controller
        self.adView.delegate = self;
        self.adView.load(Ad.admobRequest())
        
        addBannerViewToView(self.adView)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView)
    {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bannerView)
        self.view.addConstraints([
            NSLayoutConstraint(item: self.adView,  attribute: .top,         relatedBy: .equal,  toItem: self.view,  attribute: .top,        multiplier: 1,  constant: self.paddingTop),
            //NSLayoutConstraint(item: self.adView,  attribute: .bottom,      relatedBy: .equal,  toItem: self.view,  attribute: .bottom,     multiplier: 1,  constant: paddingBottom),
            NSLayoutConstraint(item: self.adView,  attribute: .centerX,     relatedBy: .equal,  toItem: self.view,  attribute: .centerX,    multiplier: 1,  constant: 0)
        ])
    }
    
    //MARK: - GADBannerViewDelegate
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView)
    {
        print("adViewDidReceiveAd")

        //bannerView.removeFromSuperview();
        //addBannerViewToView(bannerView)

        self.adView = bannerView;
        self.adView.alpha = 0
        self.view.layoutIfNeeded()

        let height = kGADAdSizeBanner.size.height + paddingTop + paddingBottom;
        self.heightConstraint.constant = height

        UIView.animate(withDuration: 0.5, animations: {
            self.adView.alpha = 1
            self.controller?.view.layoutIfNeeded()
        })
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError)
    {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView)
    {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView)
    {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView)
    {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView)
    {
        print("adViewWillLeaveApplication")
    }
}
