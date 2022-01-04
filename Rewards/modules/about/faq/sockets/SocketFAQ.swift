//
//  SocketFAQ.swift
//  FAQs
//
//  Created by Anthonio Ez on 09/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

import UIKit
import Foundation
import SocketIO

class SocketFAQ: ServerSocketAsync
{
    override var TAG: String { return String.className(SocketFAQ.self); }
    
    private weak var delegate: SocketFAQDelegate?
    
    public init(delegate: SocketFAQDelegate)
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
        
        idEvent = ServerSocket.onEvent(event: Support.EVENT_FAQS, callback: listenerSuccess);
        idError = ServerSocket.onError(callback: listenerError);
        
        var json = [String: Any]();
        json["app"] = "rw"
        json["index"] = index
        json["size"] = size
        
        ServerSocket.output(event: Support.EVENT_FAQS, data: json, done: nil, error: listenerError);
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

                        var items = [FAQItem]();
                        
                        let list        = (data["list"] as? [Any]) ?? []
                        for entry in list
                        {
                            let item = FAQItem();
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
                    err = message ?? "Unable to load FAQa!";
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
            self.delegate?.faqStarted();
        })
    }
    
    private func done(_ items: [FAQItem], _ index: Int)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.delegate?.faqSuccess(items, index);
        })
        
        stop();
    }
    
    override internal func error(msg: String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            
            self.delegate?.faqError(msg);
            
        })
        
        stop();
    }
    
    public func setCallback(delegate: SocketFAQDelegate!)
    {
        self.delegate = delegate;
    }
}

protocol SocketFAQDelegate : NSObjectProtocol
{
    func faqStarted();
    func faqSuccess(_ items: [FAQItem], _ index: Int);
    func faqError(_ error: String);
}
