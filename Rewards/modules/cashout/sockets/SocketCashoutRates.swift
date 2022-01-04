//
//  SocketCashoutRates.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Foundation
import SocketIO

class SocketCashoutRates: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketCashoutRates.self); }
    
    private weak var delegate: SocketCashoutRatesDelegate?
    
    public init(delegate: SocketCashoutRatesDelegate)
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
        
        idEvent = ServerSocket.onEvent(event: Cashout.EVENT_DATA, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        let json = [String: Any]();
        
        ServerSocket.output(event: Cashout.EVENT_DATA, data: json, done: nil, error: listenerError);
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
                        Prefs.userRewards = (data["earnings"] as? Int) ?? 0;
                        let info = (data["message"] as? String) ?? "";

                        var rates = [CashoutRateItem]();
                        
                        let rateList = (data["rates"] as? [Any]) ?? []
                        for entry in rateList
                        {
                            let item = CashoutRateItem();
                            if(item.copyJSON(json: entry as? [String: Any]))
                            {
                                rates.append(item);
                            }
                        }
                        
                        var types = [CashoutTypeItem]();
                        
                        let typeList = (data["types"] as? [Any]) ?? []
                        for entry in typeList
                        {
                            let item = CashoutTypeItem();
                            if(item.copyJSON(json: entry as? [String: Any]))
                            {
                                types.append(item);
                            }
                        }
                        
                        done(info, rates, types);
                        return;
                    }
                    else
                    {
                        err = ServerData.err_invalid_data
                    }
                }
                else
                {
                    err = message ?? "Unable to load cash out rates!";
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
            self.delegate?.cashoutRatesStarted();
        })
    }
    
    private func done(_ info: String, _ rates: [CashoutRateItem], _ types: [CashoutTypeItem])
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.cashoutRatesSuccess(info, rates, types);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.cashoutRatesError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketCashoutRatesDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketCashoutRatesDelegate : NSObjectProtocol
{
    func cashoutRatesStarted();
    func cashoutRatesSuccess(_ info: String, _ rates: [CashoutRateItem], _ types: [CashoutTypeItem]);
    func cashoutRatesError(_ error: String);
}
