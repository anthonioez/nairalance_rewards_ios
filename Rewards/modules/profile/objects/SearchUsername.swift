//
//  SearchUsername.swift
//  Rewards
//
//  Created by Anthonio Ez on 06/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class SearchUsername: NSObject, SocketUsernameDelegate
{
    weak var delegate: SearchUsernameDelegate?
    
    var input: RoundInput!

    var existing = false;
    
    var socket: SocketUsername! = nil;
    //var allowed = nil;
    
    var timer: Timer! = nil;
    
    public init(_ input: RoundInput, _ existing: Bool, delegate: SearchUsernameDelegate?)
    {
        self.delegate = delegate;
        self.input = input;
        self.existing = existing;
    }
    
    func start(_ text: String)
    {
        stop();

        let qq = text.trim().lowercased()
        if(qq.length() < 3)
        {
            cancel();
            return;
        }
        else
        {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeout), userInfo: qq, repeats: false)
        }
    }
    
    @objc func timeout(timer: Timer)
    {
        if let qq = timer.userInfo as? String
        {
            self.socket(qq);
        }
    }
    
    func cancel()
    {
        input.suffixProgress = false

        self.delegate?.searchCanceled(self);
    }
    
    func reset()
    {
        input.suffixProgress = false;
        
    }
    
    func stop()
    {
        reset();
        
        untimer();
        unsocket();
    }
    
    func untimer()
    {
        if (timer != nil)
        {
            timer.invalidate();
            timer = nil;
        }
    }
    
    func unsocket()
    {
        if(socket != nil)
        {
            socket.setCallback(delegate: nil);
            socket.stop();
            socket = nil;
        }
    }
    
    func socket(_ username: String)
    {
        unsocket();
        
        socket = SocketUsername(delegate: self);
        socket.start(username, existing);
    }
    
    func usernameStarted()
    {
        input.suffixProgress = true
    }
    
    func usernameSuccess(_ username: String, _ data: Bool)
    {
        input.suffixProgress = false
        
        self.delegate?.searchDone(self, data);
    }
    
    func usernameError(_ error: String)
    {
        input.suffixProgress = false
        
        self.delegate?.searchFailed(self, error);
    }
}

protocol SearchUsernameDelegate : NSObjectProtocol
{
    func searchDone(_ target: SearchUsername, _ found: Bool);
    func searchFailed(_ target: SearchUsername, _ error: String);
    func searchCanceled(_ target: SearchUsername);
}

