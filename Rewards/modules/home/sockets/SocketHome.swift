//
//  SocketHome.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketHome: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketHome.self); }
    
    private weak var delegate: SocketHomeDelegate?
    
    public init(delegate: SocketHomeDelegate)
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
        
        idEvent = ServerSocket.onEvent(event: Home.EVENT_HOME, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        let json = [String: Any]();
        
        ServerSocket.output(event: Home.EVENT_HOME, data: json, done: nil, error: listenerError);
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
                        let item = HomeItem();
                        if(item.copyJSON(json: data))
                        {
                            Prefs.userName      = item.username;
                            Prefs.userThumb     = item.thumb
                            Prefs.userRewards   = item.rewards;
                            Prefs.userRanking   = item.ranking;

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
                    err = message ?? "Unable to load load data!";
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
    
    override internal func begin()
    {
        super.begin();
        
        DispatchQueue.main.async(execute: {
            self.delegate?.homeStarted();
        })
    }
    
    private func done(_ item: HomeItem)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.homeSuccess(item);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.homeError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketHomeDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketHomeDelegate : NSObjectProtocol
{
    func homeStarted();
    func homeSuccess(_ data: HomeItem);
    func homeError(_ error: String);
}
