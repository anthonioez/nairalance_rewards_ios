//
//  AdmobRewarded.swift
//  Rewards
//
//  Created by Anthonio Ez on 16/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdmobRewarded: NSObject, GADRewardBasedVideoAdDelegate, SocketActionRequestDelegate, SocketActionResponseDelegate
{

    private let FAIL_COUNT = 3;

    private var adRewarded: GADRewardBasedVideoAd! = nil;
    
    private var state = AdState.State.none;
    private var fails = 0;
    private var isLoading = false;
    private var showOnRequest = false;
    
    private var rewardId = 0;
    private var requestHash = "";
    
    private var socketRequest: SocketActionRequest!  = nil;
    private var socketResponse: SocketActionResponse! = nil;
    
    private var controller: UIViewController! = nil
    
    private weak var delegate: AdmobRewardedDelegate?
    
    init(_ controller: UIViewController!, delegate: AdmobRewardedDelegate?)
    {
        self.controller = controller;
        self.delegate = delegate;
        
        self.adRewarded = GADRewardBasedVideoAd.sharedInstance();
    }
    
    func load()
    {
        state = .loading;
        
        self.adRewarded.delegate = self
        self.adRewarded.load(Ad.admobRequest(), withAdUnitID: Rewards.admobIdRewarded)   
    }
    
    @discardableResult
    func show(_ reward: Int) -> Bool
    {
        if (adRewarded.isReady)
        {
            self.rewardId = reward;
            
            if(requestHash.isEmpty)
            {
                showOnRequest = true;
                request();
            }
            else
            {
                showAndClear();
            }
            return true;
        }
        else
        {
            if(fails >= FAIL_COUNT)
            {
                fails = 0;
                check();
            }
            
            UI.toast("No videos ads available, please try again later!");
            
            return false;
        }
    }
    
    func showAndClear()
    {
        state = .none;
        
        RewardsEvent.post(RewardsEvent.GOOGLE_AD_CLEARED, message: "")
        
        if adRewarded.isReady
        {
            adRewarded.present(fromRootViewController: controller)
        }

        RewardsAnalytics.logEvent("reward_admob", "");
        
        showOnRequest = false;
    }
    
    func check()
    {
        if(state != .loading && state != .loaded)
        {
            load();
        }
    }
    
    func recheck()
    {
        fails = 0;
        check();
    }
    
    @objc func next()
    {
        check()
    }
    
    //MARK: - Request
    func unrequest()
    {
        if(socketRequest != nil)
        {
            socketRequest.setCallback(delegate: nil)
            socketRequest.stop()
            socketRequest = nil
        }
    }
    
    func request()
    {
        unrequest()
        
        requestHash = "";
        
        socketRequest = SocketActionRequest(nil, delegate: self);
        socketRequest.start(rewardId, "watch", Rewards.admobIdRewarded)
    }
    
    //MARK: - SocketActionRequestDelegate
    func actionRequestStarted()
    {
        UI.showProgress(Strings.reward_request);
    }
    
    func actionRequestSuccess(_ data: Any?, _ hash: String)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [unowned self] in
            
            UI.hideProgress()
            
            self.requestHash = hash;
            
            if(self.showOnRequest)
            {
                self.showAndClear();
            }
        })
    }
    
    func actionRequestError(_ error: String)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [unowned self] in
            
            UI.hideProgress()
            
            self.requestHash = "";
            
            UI.toast(error);
        })
    }
    

    //MARK: - Response
    func unresponse()
    {
        if(socketResponse != nil)
        {
            socketResponse.setCallback(delegate: nil)
            socketResponse.stop()
            socketResponse = nil
        }
    }
    
    func response()
    {
        unresponse();
        
        if(requestHash.isEmpty)
        {
            UI.toast(Strings.reward_not_requested);   
            return;
        }
        
        socketResponse = SocketActionResponse(delegate: self);
        socketResponse.start(requestHash, "watch", Rewards.admobIdRewarded, "")
    }
    
    //MARK: - SocketActionResponseDelegate
    func actionResponseStarted()
    {
        UI.toast(Strings.reward_claim);
    }
    
    func actionResponseSuccess(_ message: String, _ points: Int, _ action: String)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [unowned self] in
            
            self.requestHash = "";
            
            UI.toast(message); //TODO animation and sound!!
        })
    }
    
    func actionResponseError(_ error: String)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [unowned self] in
            
            self.requestHash = "";
            
            UI.toast(error);
        })
    }

    //MARK: - GADRewardBasedVideoAdDelegate
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward)
    {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        
        response();
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd)
    {
        print("Reward based video ad is received.")
        
        NSObject.cancelPreviousPerformRequests(withTarget: self);

        state = .loaded
        
        UI.toast("Google video ad available!");
        
        RewardsEvent.post(RewardsEvent.GOOGLE_AD_LOADED, message: "")
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd)
    {
        print("Opened reward based video ad.")
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd)
    {
        print("Reward based video ad started playing.")
    }
    
    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd)
    {
        print("Reward based video ad has completed.")
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd)
    {
        print("Reward based video ad is closed.")
                
        requestHash = "";

        load();

        self.delegate?.onAdmobRewardClosed();
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd)
    {
        print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error)
    {
        print("Reward based video ad failed to load.")
        
        state = .failed
        
        NSObject.cancelPreviousPerformRequests(withTarget: self);

        fails += 1;
        if(fails < FAIL_COUNT)
        {
            perform(#selector(next), with: nil, afterDelay: 20)
        }
        else if(fails == FAIL_COUNT)
        {
            //UI.toast("Unable to load Google video ad!")
        }
    }
}

protocol AdmobRewardedDelegate: NSObjectProtocol
{
    func onAdmobRewardClosed();
}
