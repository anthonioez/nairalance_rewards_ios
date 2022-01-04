//
//  SocketToken.swift
//  Rewards
//
//  Created by Anthonio Ez on 18/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import Foundation
import SocketIO

class SocketToken: ServerSocketAsync
{
    static var EVENT_TOKEN      = "devices_token"

    override var TAG: String { return String.className(SocketToken.self); }
    
    private var delegate: SocketTokenDelegate!
    
    public init(delegate: SocketTokenDelegate)
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
        
        var json = [String: Any]();
        json["token"]       = Prefs.pushToken;
        json["status"]      = Prefs.pushStatus ? "1" : "0";
        
        idEvent = ServerSocket.onEvent(event: SocketToken.EVENT_TOKEN, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        ServerSocket.output(event: SocketToken.EVENT_TOKEN, data: json, done: nil, error: listenerError);
    }
    
    public func listenerSuccess(data: [Any], callback: SocketAckEmitter)
    {
        //print(TAG, "listenerSuccess: ")
        
        var err = "";
        
        if(data.count > 0)
        {
            if let json = data[0] as? [String: Any]
            {
                let status = json["status"] as? Bool;
                let message = json["message"] as? String;
                
                if(status != nil && status! == true)
                {
                    if let _ = json["data"]
                    {
                        Prefs.pushTokenSent = true;
                        
                        done(msg: message ?? "Token successfully updated!");
                        return;
                    }
                    else
                    {
                        err = ServerData.err_invalid_data;
                    }
                }
                else
                {
                    err = message ?? "Unable to update token!" ;
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
        super.begin();
        
        DispatchQueue.main.async(execute: {
            self.delegate?.tokenStarted();
        })
    }
    
    private func done(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.tokenSuccess(msg);
        })
        
        stop();
    }
    
    override func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.tokenError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketTokenDelegate!)
    {
        self.delegate = delegate;
    }
}


protocol SocketTokenDelegate : NSObjectProtocol
{
    func tokenStarted();
    func tokenSuccess(_ message: String);
    func tokenError(_ error: String);
}

