//
//  SocketProfileGet.swift
//  Rewards
//
//  Created by Anthonio Ez on 08/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketProfileGet: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketProfileGet.self); }
    
    private weak var delegate: SocketProfileGetDelegate?
    
    public init(delegate: SocketProfileGetDelegate)
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
        
        idEvent = ServerSocket.onEvent(event: Profile.EVENT_PROFILE_GET, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        let json = [String: Any]();
        ServerSocket.output(event: Profile.EVENT_PROFILE_GET, data: json, done: nil, error: listenerError);
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
                        let item = ProfileItem();
                        if(item.copyJSON(json: data))
                        {
                            Prefs.userName      = item.username;
                            Prefs.userThumb     = item.thumb
                            Prefs.userEmail     = item.email

                            Prefs.profileStamp  = Int(DateTime.currentTimeMillis());
                            
                            done(item);
                            return;
                        }
                        else
                        {
                            err = ServerData.err_invalid_data
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
            self.delegate?.profileGetStarted();
        })
    }
    
    private func done(_ item: ProfileItem)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.profileGetSuccess(item);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.profileGetError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketProfileGetDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketProfileGetDelegate : NSObjectProtocol
{
    func profileGetStarted();
    func profileGetSuccess(_ item: ProfileItem);
    func profileGetError(_ error: String);
}
