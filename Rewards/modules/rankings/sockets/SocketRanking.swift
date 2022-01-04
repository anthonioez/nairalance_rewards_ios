//
//  SocketRanking.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketRanking: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketRanking.self); }
    
    private weak var delegate: SocketRankingDelegate?
    
    public init(delegate: SocketRankingDelegate)
    {
        self.delegate = delegate;
    }
    
    deinit
    {
        print(TAG, "deinit");
    }
    
    public func start()
    {
        begin();
        
        isStopped = false;
        
        idEvent = ServerSocket.onEvent(event: Ranking.EVENT_LIST, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        let json = [String: Any]();
        
        ServerSocket.output(event: Ranking.EVENT_LIST, data: json, done: nil, error: listenerError);
    }
    
    public func listenerSuccess(data: [Any], callback: SocketAckEmitter)
    {
        //print(TAG, "listenerSuccess: ", data)
        
        if(isStopped)
        {
            return;
        }
        
        var err = "";
        
        if(data.count > 0)
        {
            if let json = data[0] as? [String: Any]
            {
                let status = json["status"] as? Bool;
                let message = json["message"] as? String;
                
                if(status != nil && status! == true)
                {
                    if let data = json["data"] as? [String: Any]
                    {
                        Prefs.userRanking = (data["ranking"] as? Int) ?? 0;
                        Prefs.userRewards = (data["rewards"] as? Int) ?? 0;
                        
                        var items = [RankingItem]();

                        let list        = (data["list"] as? [Any]) ?? []
                        for entry in list
                        {
                            let item = RankingItem();
                            if(item.copyJSON(json: entry as? [String: Any]))
                            {
                                items.append(item);
                            }
                        }

                        done(items);
                        return;
                    }
                    else
                    {
                        err = ServerData.err_invalid_data
                    }
                }
                else
                {
                    err = message ?? "Unable to load rankings!";
                }
            }
            else
            {
                err = ServerData.err_invalid_response;
            }
        }
        else
        {
            err = ServerData.err_invalid_response;
        }
        
        error(msg: err);
    }
    
    override func begin()
    {
        super.begin()
        
        DispatchQueue.main.async(execute: {
            self.delegate?.rankingStarted();
        })
    }
    
    private func done(_ items: [RankingItem])
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.rankingSuccess(items);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.rankingError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketRankingDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketRankingDelegate : NSObjectProtocol
{
    func rankingStarted();
    func rankingSuccess(_ items: [RankingItem]);
    func rankingError(_ error: String);
}
