//
//  SocketPayoutCancel.swift
//  Rewards
//
//  Created by Anthonio Ez on 10/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketPayoutCancel: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketPayoutCancel.self); }
    
    private weak var delegate: SocketPayoutCancelDelegate?
    
    public init(delegate: SocketPayoutCancelDelegate)
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
        
        idEvent = ServerSocket.onEvent(event: Payout.EVENT_CANCEL, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        var json = [String: Any]();
        json["id"] = id
        
        ServerSocket.output(event: Payout.EVENT_CANCEL, data: json, done: nil, error: listenerError);
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
                    done(message ?? "Cash out request cancelled!");
                    return;
                }
                else
                {
                    err = message ?? "Unable to cancel cash out request!";
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
            self.delegate?.payoutCancelStarted();
        })
    }
    
    private func done(_ message: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.payoutCancelSuccess(message);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.payoutCancelError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketPayoutCancelDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketPayoutCancelDelegate : NSObjectProtocol
{
    func payoutCancelStarted();
    func payoutCancelSuccess(_ message: String);
    func payoutCancelError(_ error: String);
}
