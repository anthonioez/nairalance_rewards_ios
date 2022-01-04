//
//  SocketStart.swift
//  Rewards
//
//  Created by Anthonio Ez on 05/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketStart: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketStart.self); }
    
    private var delegate: SocketStartDelegate!
    
    public init(delegate: SocketStartDelegate)
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
        
        let json = [String: Any]();
        
        ServerSocket.output(event: "", data: json, done: listenerSuccess, error: listenerError);
    }
    
    public func listenerSuccess(params: [Any], callback: SocketAckEmitter)
    {
        print(TAG, "listenerSuccess: ", params)
        
        if(isStopped)
        {
            return;
        }
        
        var update = 0;
        var message = "";
        
        if(params.count > 0)
        {
            if let up = params[0] as? Int
            {
                update = up;
            }
            
            if let ms = params[1] as? String
            {
                message = ms;
            }
        }
        
        done(update: update, msg: message);
    }
    
    override func begin()
    {
        super.begin()
        
        DispatchQueue.main.async(execute: {
            self.delegate?.startStarted();
        })
    }
    
    private func done(update: Int, msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.startSuccess(update, msg);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.startError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketStartDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketStartDelegate : NSObjectProtocol
{
    func startStarted();
    func startSuccess(_ update: Int, _ message: String);
    func startError(_ error: String);
}
