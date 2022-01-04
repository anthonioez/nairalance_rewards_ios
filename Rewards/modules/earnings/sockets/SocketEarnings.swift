//
//  SocketEarnings.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketEarnings: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketEarnings.self); }
    
    private weak var delegate: SocketEarningsDelegate?
    
    public init(delegate: SocketEarningsDelegate)
    {
        self.delegate = delegate;
    }
    
    deinit
    {
        print(TAG, "deinit");
    }
    
    public func start(_ index: Int, _ size: Int)
    {
        begin();
        
        isStopped = false;
        
        idEvent = ServerSocket.onEvent(event: Earning.EVENT_LIST, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        var json = [String: Any]();
        json["index"] = index
        json["size"] = size

        ServerSocket.output(event: Earning.EVENT_LIST, data: json, done: nil, error: listenerError);
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
                        let index = (data["index"] as? Int) ?? 0;
                        
                        Prefs.userRewards = (data["earnings"] as? Int) ?? 0;
                        
                        var items = [EarningItem]();

                        let list        = (data["list"] as? [Any]) ?? []
                        for entry in list
                        {
                            let item = EarningItem();
                            if(item.copyJSON(json: entry as? [String: Any]))
                            {
                                items.append(item);
                            }
                        }

                        done(items, index);
                        return;
                    }
                    else
                    {
                        err = ServerData.err_invalid_data
                    }
                }
                else
                {
                    err = message ?? "Unable to load earnings!";
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
            self.delegate?.earningStarted();
        })
    }
    
    private func done(_ items: [EarningItem], _ index: Int)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.earningSuccess(items, index);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.earningError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketEarningsDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketEarningsDelegate : NSObjectProtocol
{
    func earningStarted();
    func earningSuccess(_ items: [EarningItem], _ index: Int);
    func earningError(_ error: String);
}
