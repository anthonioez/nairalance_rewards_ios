//
//  SocketActions.swift
//  Rewards
//
//  Created by Anthonio Ez on 09/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketActions: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketActions.self); }
    
    private weak var delegate: SocketActionsDelegate?
    
    public init(delegate: SocketActionsDelegate)
    {
        self.delegate = delegate;
    }
    
    deinit
    {
        print(TAG, "deinit");
    }
    
    public func start(_ id: Int)
    {
        begin();
        
        isStopped = false;
        
        idEvent = ServerSocket.onEvent(event: Reward.EVENT_ACTIONS, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        var json = [String: Any]();
        json["id"] = id
        
        ServerSocket.output(event: Reward.EVENT_ACTIONS, data: json, done: nil, error: listenerError);
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
                    if let data = json["data"] as? [Any]
                    {
                        var items = [RewardActionItem]();

                        for entry in data
                        {
                            let item = RewardActionItem();
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
                    err = message ?? "Unable to load reward actions!";
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
            self.delegate?.actionStarted();
        })
    }
    
    private func done(_ items: [RewardActionItem])
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.actionSuccess(items);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.actionError(msg);
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketActionsDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketActionsDelegate : NSObjectProtocol
{
    func actionStarted();
    func actionSuccess(_ items: [RewardActionItem]);
    func actionError(_ error: String);
}
