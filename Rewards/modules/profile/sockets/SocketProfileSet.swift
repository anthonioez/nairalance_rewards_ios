//
//  SocketProfileSet.swift
//  Rewards
//
//  Created by Anthonio Ez on 08/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketProfileSet: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketProfileSet.self); }
    
    private weak var delegate: SocketProfileSetDelegate?
    
    public init(delegate: SocketProfileSetDelegate)
    {
        self.delegate = delegate;
    }
    
    deinit
    {
        print(TAG, "deinit");
    }
    
    public func start(_ username: String, _ gender: Int, _ city: String, _ state: String, _ data: Data?)
    {
        begin();
        
        isStopped = false;
        
        idEvent = ServerSocket.onEvent(event: Profile.EVENT_PROFILE_SET, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        var json = [String: Any]();
        json["username"]    = username;
        json["gender"]      = gender;
        json["city"]        = city;
        json["state"]       = state;
        json["photo"]       = data == nil ? Data() : data;
        
        ServerSocket.output(event: Profile.EVENT_PROFILE_SET, data: json, done: nil, error: listenerError);
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
                    if let _ = json["data"] as? [String: Any]
                    {
                    }

                    Prefs.profileStamp  = Int(DateTime.currentTimeMillis());

                    let msg = message ?? "Profile updated!";
                    RewardsEvent.post(RewardsEvent.PROFILE_CHANGED, message: msg)

                    done(msg);
                    return;
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
            self.delegate?.profileSetStarted();
        })
    }
    
    private func done(_ msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.profileSetSuccess(msg);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.profileSetError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketProfileSetDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketProfileSetDelegate : NSObjectProtocol
{
    func profileSetStarted();
    func profileSetSuccess(_ msg: String);
    func profileSetError(_ error: String);
}
