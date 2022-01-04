//
//  SocketPhoneVerify.swift
//  Rewards
//
//  Created by Anthonio Ez on 05/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketPhoneVerify: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketPhoneVerify.self); }
    
    private var delegate: SocketPhoneVerifyDelegate!
    
    public init(delegate: SocketPhoneVerifyDelegate)
    {
        self.delegate = delegate;
    }
    
    deinit
    {
        print(TAG, "deinit");
    }
    
    public func start(_ phone: String, _ code: String)
    {
        begin();
        
        isStopped = false;
        
        idEvent = ServerSocket.onEvent(event: Phone.EVENT_VERIFY, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        var json = [String: Any]();
        json["phone"] = phone;
        json["code"] = code;
        
        ServerSocket.output(event: Phone.EVENT_VERIFY, data: json, done: nil, error: listenerError);
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
                        let id          = (data["id"] as? Int) ?? 0;
                        let token       = data["token"] as? String;
                        let username    = data["username"] as? String;
                        let email       = data["email"] as? String;

                        if(id > 0 && token != nil && token!.trim().length() > 0)
                        {
                            Prefs.apiToken      = token!;
                            
                            Prefs.userID        = "\(id)";
                            Prefs.userName      = username ?? "";
                            Prefs.userEmail     = email ?? "";
                            Prefs.pushTokenSent = false;
                            
                            if(Prefs.userName.isEmpty)
                            {
                                Rewards.signin();
                            }
                            else
                            {
                                Rewards.login();
                            }

                            done(message ?? "Verification successful!");
                            return;
                        }
                    }

                    err = ServerData.err_invalid_response;
                }
                else
                {
                    err = message ?? "Unable to check verification code!";
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
            self.delegate?.phoneVerifyStarted();
        })
    }
    
    private func done(_ msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.phoneVerifySuccess(msg);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.phoneVerifyError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketPhoneVerifyDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketPhoneVerifyDelegate : NSObjectProtocol
{
    func phoneVerifyStarted();
    func phoneVerifySuccess(_ message: String);
    func phoneVerifyError(_ error: String);
}

