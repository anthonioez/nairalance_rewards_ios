//
//  SocketCashoutRequest.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketCashoutRequest: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketCashoutRequest.self); }
    
    private weak var delegate: SocketCashoutRequestDelegate?
    var action = "";
    
    public init(delegate: SocketCashoutRequestDelegate)
    {
        self.delegate = delegate;
    }
    
    deinit
    {
        print(TAG, "deinit");
    }
    
    public func start(_ provider: Int, _ points: Int, _ name: String, _ account: String)
    {
        begin();
        
        isStopped = false;
        
        idEvent = ServerSocket.onEvent(event: Cashout.EVENT_REQUEST, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        var json = [String: Any]();
        json["provider"]    = provider;
        json["points"]      = points;
        json["name"]        = name;
        json["account"]     = account;

        ServerSocket.output(event: Cashout.EVENT_REQUEST, data: json, done: nil, error: listenerError);
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

                if let earnings = json["data"] as? Int
                {
                    Prefs.userRewards = earnings;
                }

                if(status != nil && status! == true)
                {
                    done(message ?? "Cash out request sent!");
                    return;
                }
                else
                {
                    action = (json["action"] as? String) ?? "";
                    err = message ?? "Unable to send cash out request!";
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
            self.delegate?.cashoutRequestStarted();
        })
    }
    
    private func done(_ message: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.cashoutRequestSuccess(message);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.cashoutRequestError(msg, self.action);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketCashoutRequestDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketCashoutRequestDelegate : NSObjectProtocol
{
    func cashoutRequestStarted();
    func cashoutRequestSuccess(_ message: String);
    func cashoutRequestError(_ error: String, _ action: String);
}
