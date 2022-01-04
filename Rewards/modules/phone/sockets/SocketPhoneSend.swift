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

class SocketPhoneSend: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketPhoneSend.self); }
    
    private var delegate: SocketPhoneSendDelegate!
    
    public init(delegate: SocketPhoneSendDelegate)
    {
        self.delegate = delegate;
    }
    
    deinit
    {
        print(TAG, "deinit");
    }
    
    public func start(_ phone: String, _ type: Bool)
    {
        begin();
        
        isStopped = false;

        idEvent = ServerSocket.onEvent(event: Phone.EVENT_SIGNIN, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);

        var json = [String: Any]();
        json["phone"] = phone;
        json["type"] = type;
        
        ServerSocket.output(event: Phone.EVENT_SIGNIN, data: json, done: nil, error: listenerError);
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
                    done(msg: message ?? "Verification code sent!");
                    return;
                }
                else
                {
                    err = message ?? "Unable to send verification code!";
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
            self.delegate?.phoneSendStarted();
        })
    }
    
    private func done(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.phoneSendSuccess(msg);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.phoneSendError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketPhoneSendDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketPhoneSendDelegate : NSObjectProtocol
{
    func phoneSendStarted();
    func phoneSendSuccess(_ message: String);
    func phoneSendError(_ error: String);
}
