//
//  SocketProfileJoin.swift
//  Rewards
//
//  Created by Anthonio Ez on 05/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketProfileJoin: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketProfileJoin.self); }
    
    private weak var delegate: SocketProfileJoinDelegate?
    
    public init(delegate: SocketProfileJoinDelegate)
    {
        self.delegate = delegate;
    }
    
    deinit
    {
        print(TAG, "deinit");
    }
    
    public func start(_ username: String, _ referrer: String, _ data: Data?)
    {
        begin();
        
        isStopped = false;
        
        idEvent = ServerSocket.onEvent(event: Profile.EVENT_JOIN, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        var json = [String: Any]();
        json["username"]    = username;
        json["referrer"]    = referrer;
        json["photo"]       = data == nil ? Data() : data;

        ServerSocket.output(event: Profile.EVENT_JOIN, data: json, done: nil, error: listenerError);
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
                        let username    = data["username"] as? String;
                        let thumb       = data["thumb"] as? String;

                        if(username != nil && username!.trim().length() > 0)
                        {
                            Prefs.userThumb = thumb ?? "";
                            Prefs.userName = username!;
                            
                            done(message ?? "Profile created!");
                            return;
                        }
                        else
                        {
                            err = ServerData.err_invalid_data;
                        }
                    }
                }
                else
                {
                    err = message ?? "Unable to create profile!";
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
            self.delegate?.profileJoinStarted();
        })
    }
    
    private func done(_ msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.profileJoinSuccess(msg);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.profileJoinError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketProfileJoinDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketProfileJoinDelegate : NSObjectProtocol
{
    func profileJoinStarted();
    func profileJoinSuccess(_ msg: String);
    func profileJoinError(_ error: String);
}
