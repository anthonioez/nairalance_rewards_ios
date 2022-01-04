//
//  SocketProfileVerify.swift
//  Rewards
//
//  Created by Anthonio Ez on 17/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketProfileVerify: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketProfileVerify.self); }
    
    private weak var delegate: SocketProfileVerifyDelegate?
    
    public init(delegate: SocketProfileVerifyDelegate)
    {
        self.delegate = delegate;
    }
    
    deinit
    {
        print(TAG, "deinit");
    }
    
    public func start(_ email: String, _ code: String)
    {
        begin();
        
        isStopped = false;
        
        idEvent = ServerSocket.onEvent(event: Profile.EVENT_PROFILE_VERIFY, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        var json = [String: Any]();
        json["email"] = email;
        json["code"] = code;
        
        ServerSocket.output(event: Profile.EVENT_PROFILE_VERIFY, data: json, done: nil, error: listenerError);
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
                    done(message ?? "Email verification successful!");
                    return;
                }
                else
                {
                    err = message ?? "Unable to verifiy your email address!";
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
            self.delegate?.profileVerifyStarted();
        })
    }
    
    private func done(_ message: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.profileVerifySuccess(message);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.profileVerifyError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketProfileVerifyDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketProfileVerifyDelegate : NSObjectProtocol
{
    func profileVerifyStarted();
    func profileVerifySuccess(_ message: String);
    func profileVerifyError(_ error: String);
}
