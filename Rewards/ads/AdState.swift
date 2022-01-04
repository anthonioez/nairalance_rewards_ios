//
//  AdState.swift
//  Rewards
//
//  Created by Anthonio Ez on 16/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class AdState: NSObject {

    enum State {
        case none
        case failed
        case loading
        case loaded
    }

    public var  ad: Any?;
    public var  type: Int;
    public var  state: State;
    public var  time: Double;
    public var  adId: String;

    public weak var  delegate: AdStateDelegate?;

    init(_ ad: Any, _ type: Int, _ adId: String, _ state: State, delegate: AdStateDelegate)
    {
        self.ad = ad;
        self.type = type;
        self.adId = adId;
        self.state = state;
        self.delegate = delegate;
        self.time = DateTime.currentTimeMillis();
    }

    public func isLoading() -> Bool
    {
        return state == .loading;
    }

    public func isLoaded() -> Bool
    {
        return state == .loaded;
    }

    public func isFailed() -> Bool
    {
        return state == .failed;
    }

    public func canReload() -> Bool
    {
        if(isFailed() && (DateTime.currentTimeMillis() - time) > 30000)
        {
            return true;
        }
        return false;
    }
}


protocol AdStateDelegate: NSObjectProtocol
{
    func onAdState(_ state: AdState.State)
}
