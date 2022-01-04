//
//  SocketActionRequest.swift
//  Rewards
//
//  Created by Anthonio Ez on 09/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketActionRequest: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketActionRequest.self); }
    
    private weak var delegate: SocketActionRequestDelegate?
    private var data: Any?
    
    public init(_ data: Any?, delegate: SocketActionRequestDelegate)
    {
        self.data = data;
        self.delegate = delegate;
    }
    
    deinit
    {
        print(TAG, "deinit");
    }
    
    public func start(_ id: Int, _ actions: String, _ data: String)
    {
        begin();
        
        isStopped = false;
        
        idEvent = ServerSocket.onEvent(event: Reward.EVENT_REQUEST, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        var json = [String: Any]();
        json["id"] = id
        json["actions"] = actions
        json["data"] = data

        ServerSocket.output(event: Reward.EVENT_REQUEST, data: json, done: nil, error: listenerError);
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
                    if let hash = json["data"] as? String
                    {
                        done(hash);
                        stop()
                        return;
                    }
                    else
                    {
                        err = ServerData.err_invalid_data
                    }
                }
                else
                {
                    err = message ?? "Unable to load request reward action!";
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
            self.delegate?.actionRequestStarted();
        })
    }
    
    private func done(_ hash: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.actionRequestSuccess(self.data, hash);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.actionRequestError(msg);
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketActionRequestDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketActionRequestDelegate : NSObjectProtocol
{
    func actionRequestStarted();
    func actionRequestSuccess(_ data: Any?, _ hash: String);
    func actionRequestError(_ error: String);
}
