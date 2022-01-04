//
//  SocketAsync.swift
//  nairalance
//
//  Created by Anthonio Ez on 13/01/2017.
//  Copyright © 2017 Anthonio Ez. All rights reserved.
//

import Foundation
import SocketIO

class ServerSocketAsync
{
    internal var TAG: String { return "SocketAsync"; }

    internal var idError: UUID! = nil
    internal var idEvent : UUID! = nil;
    internal var socketTimer: Timer! = nil;
    
    internal var isStopped = false;
    
    func stop()
    {
        untimer()
        isStopped = true;
        
        if(idEvent != nil)
        {
            ServerSocket.offEvent(id: idEvent);
        }
        
        if(idError != nil)
        {
            ServerSocket.offError(id: idError);
        }
    }
    
    internal func listenerError(params: [Any], callback: SocketAckEmitter)
    {
        print(TAG, "listenerError: ", params);
        
        if(isStopped)
        {
            return;
        }
        
        var response = ServerData.err_unable_to_connect;
        
        if let msg = params[0] as? String
        {
            response = msg;
        }
        
        error(msg: response);
    }
    
    internal func begin()
    {
        //start timer
        
        timer();
    }

    internal func error(msg: String)
    {
        stop()
    }
    
    func timer()
    {
        untimer()
        
        socketTimer = Timer.scheduledTimer(timeInterval: ServerSocket.timeout, target: self, selector: #selector(timeout), userInfo: nil, repeats: false);
    }
    
    func untimer()
    {
        if(socketTimer != nil)
        {
            socketTimer.invalidate();
            socketTimer = nil;
        }
    }
    
    @objc func timeout()
    {
        untimer();
        
        listenerError(params: ["Connection timeout!"], callback: ServerSocket.emitter)
        
        stop()
    }
}
