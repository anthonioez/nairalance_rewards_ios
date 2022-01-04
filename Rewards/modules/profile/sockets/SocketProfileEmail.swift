//
//  SocketProfileEmail.swift
//  Rewards
//
//  Created by Anthonio Ez on 17/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

import Foundation
import SocketIO

class SocketProfileEmail: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketProfileEmail.self); }
    
    private weak var delegate: SocketProfileEmailDelegate?
    private var email = "";
    
    public init(delegate: SocketProfileEmailDelegate)
    {
        self.delegate = delegate;
    }
    
    deinit
    {
        print(TAG, "deinit");
    }
    
    public func start(_ email: String, _ password: String)
    {
        begin();
        
        self.email = email;
        
        isStopped = false;
        
        idEvent = ServerSocket.onEvent(event: Profile.EVENT_PROFILE_EMAIL, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        var json = [String: Any]();
        json["email"] = email;
        json["password"] = password;
        
        ServerSocket.output(event: Profile.EVENT_PROFILE_EMAIL, data: json, done: nil, error: listenerError);
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
                    Prefs.userEmail = email;
                    
                    done(message ?? "Verification email sent!");
                    return;
                }
                else
                {
                    err = message ?? "Unable to send verification email!";
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
            self.delegate?.profileEmailStarted();
        })
    }
    
    private func done(_ message: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.profileEmailSuccess(message);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.profileEmailError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketProfileEmailDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketProfileEmailDelegate : NSObjectProtocol
{
    func profileEmailStarted();
    func profileEmailSuccess(_ message: String);
    func profileEmailError(_ error: String);
}
