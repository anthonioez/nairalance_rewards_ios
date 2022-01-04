//
//  SocketActionResponse.swift
//  Rewards
//
//  Created by Anthonio Ez on 09/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketActionResponse: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketActionResponse.self); }
    
    private weak var delegate: SocketActionResponseDelegate?
    var action = "";
    
    public init(delegate: SocketActionResponseDelegate)
    {
        self.delegate = delegate;
    }
    
    deinit
    {
        print(TAG, "deinit");
    }
    
    public func start(_ hash: String, _ action: String, _ data: String, _ info: String)
    {
        begin();
        
        self.action = action;
        
        isStopped = false;
        
        idEvent = ServerSocket.onEvent(event: Reward.EVENT_RESPONSE, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        var json = [String: Any]();
        json["hash"] = hash
        json["action"] = action
        json["data"] = data
        json["info"] = info
        
        ServerSocket.output(event: Reward.EVENT_RESPONSE, data: json, done: nil, error: listenerError);
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
                    if let points = json["data"] as? Int
                    {
                        let msg = message ?? "Points rewarded!";
                        if(points > 0)
                        {
                            Prefs.userRewards += points;
                            
                            RewardsEvent.post(RewardsEvent.REWARDED_POINTS, message: msg)
                        }
                        
                        done(msg, points);
                        return;
                    }
                    else
                    {
                        err = ServerData.err_invalid_data
                    }
                }
                else
                {
                    err = message ?? "Unable to send reward response!";
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
            self.delegate?.actionResponseStarted();
        })
    }
    
    private func done(_ message: String, _ points: Int)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.actionResponseSuccess(message, points, self.action);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.actionResponseError(msg);
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketActionResponseDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketActionResponseDelegate : NSObjectProtocol
{
    func actionResponseStarted();
    func actionResponseSuccess(_ message: String, _ points: Int, _ action: String);
    func actionResponseError(_ error: String);
}
