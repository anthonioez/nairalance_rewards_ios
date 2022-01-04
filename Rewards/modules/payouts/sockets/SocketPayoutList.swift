//
//  SocketPayoutList.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketPayoutList: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketPayoutList.self); }
    
    private weak var delegate: SocketPayoutListDelegate?
    
    public init(delegate: SocketPayoutListDelegate)
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
        
        idEvent = ServerSocket.onEvent(event: Payout.EVENT_LIST, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        var json = [String: Any]();
        json["index"] = index
        json["size"] = size

        ServerSocket.output(event: Payout.EVENT_LIST, data: json, done: nil, error: listenerError);
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
                        
                        let total = (data["payouts"] as? Double) ?? 0;
                        
                        var items = [PayoutItem]();

                        let list        = (data["list"] as? [Any]) ?? []
                        for entry in list
                        {
                            let item = PayoutItem();
                            if(item.copyJSON(json: entry as? [String: Any]))
                            {
                                items.append(item);
                            }
                        }

                        done(items, index, total);
                        return;
                    }
                    else
                    {
                        err = ServerData.err_invalid_data
                    }
                }
                else
                {
                    err = message ?? "Unable to load payouts!";
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
            self.delegate?.payoutListStarted();
        })
    }
    
    private func done(_ items: [PayoutItem], _ index: Int, _ total: Double)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.payoutListSuccess(items, index, total);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.payoutListError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketPayoutListDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketPayoutListDelegate : NSObjectProtocol
{
    func payoutListStarted();
    func payoutListSuccess(_ items: [PayoutItem], _ index: Int, _ total: Double);
    func payoutListError(_ error: String);
}
