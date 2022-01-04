//
//  AdmobInterst.swift
//  Rewards
//
//  Created by Anthonio Ez on 16/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdmobInters: NSObject, GADInterstitialDelegate
{
    private static let KEY_LIMIT        = "admob_inters_limit"
    
    var controller: UIViewController?;
    
    var admobId = "";
    var state: AdState.State = .failed
    
    var adInterstitial: GADInterstitial!
    
    weak var delegate: AdmobIntersDelegate?

    init(_ controller: UIViewController!, _ admobId: String, delegate: AdmobIntersDelegate?)
    {
        self.controller = controller;
        self.delegate = delegate;
        
        self.admobId = admobId;
        self.state = .failed;        
    }
    
    func load()
    {
        state = .loading;
        
        adInterstitial = GADInterstitial(adUnitID: admobId) 
        adInterstitial.delegate = self
        adInterstitial.load(Ad.admobRequest())
    }
    
    public func show()
    {
        if(adInterstitial != nil && adInterstitial.isReady)
        {
            adInterstitial.present(fromRootViewController: self.controller!)
    
            self.state = .none;

            RewardsAnalytics.logEvent("inters_admob", "");
    
            Ad.resetCount();
        }
    }

    public func showOrFinish()
    {
        if adInterstitial != nil && adInterstitial.isReady
        {
            show();
        }
        else
        {
            self.controller?.navigationController?.popViewController(animated: true);
        }
    }

    func closeIntersAdmob(_ ad: GADInterstitial)
    {
        ad.delegate = nil;
    }
    
    //MARK: - GADBannerViewDelegate
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial)
    {
        print("interstitialDidReceiveAd")
        
        self.state = .loaded;
        
        self.delegate?.onAdInterstLoaded()
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError)
    {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        
        closeIntersAdmob(ad);
        
        state = .failed;
        self.delegate?.onAdInterstFailed();
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial)
    {
        print("interstitialWillPresentScreen")
        
        self.delegate?.onAdInterstOpened();
    }
    
    /// Called when |ad| fails to present.
    func interstitialDidFail(toPresentScreen ad: GADInterstitial)
    {
        closeIntersAdmob(ad);
        
        state = .none;
        self.delegate?.onAdInterstClosed();
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        
        closeIntersAdmob(ad);
        
        state = .none;
        self.delegate?.onAdInterstClosed();
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial)
    {
        print("interstitialWillLeaveApplication")
    }
}

protocol AdmobIntersDelegate: NSObjectProtocol
{
    func onAdInterstLoaded();
    func onAdInterstOpened();
    func onAdInterstClosed();
    func onAdInterstFailed();
}
