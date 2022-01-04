//
//  SocketUsername.swift
//  Rewards
//
//  Created by Anthonio Ez on 05/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketUsername: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketUsername.self); }
    
    private weak var delegate: SocketUsernameDelegate?
    private var username = "";
    
    public init(delegate: SocketUsernameDelegate)
    {
        self.delegate = delegate;
    }
    
    deinit
    {
        print(TAG, "deinit");
    }
    
    public func start(_ username: String, _ existing: Bool)
    {
        begin();
        
        self.username = username;
        isStopped = false;
        
        idEvent = ServerSocket.onEvent(event: Profile.EVENT_USERNAME, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        var json = [String: Any]();
        json["username"] = username;
        json["existing"] = existing ? "1" : "0";

        ServerSocket.output(event: Profile.EVENT_USERNAME, data: json, done: nil, error: listenerError);
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
                    if let found = json["data"] as? Bool
                    {
                        done(found);
                        return;
                    }
                }
                else
                {
                    err = message ?? "Unable to check username!";
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
            self.delegate?.usernameStarted();
        })
    }
    
    private func done(_ data: Bool)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.usernameSuccess(self.username, data);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.usernameError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketUsernameDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketUsernameDelegate : NSObjectProtocol
{
    func usernameStarted();
    func usernameSuccess(_ username: String, _ data: Bool);
    func usernameError(_ error: String);
}
