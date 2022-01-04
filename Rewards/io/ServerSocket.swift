//
//  ServerSocket.swift
//  MicinitiLib
//
//  Created by Anthonio Ez on 13/01/2017.
//  Copyright © 2017 Miciniti. All rights reserved.
//

import Foundation
import SocketIO

class ServerSocket
{
    static let TAG = String.className(ServerSocket.self);
    
    static let EVENT    = "event";
    
    static var instance : ServerSocket? = nil;
    static var emitter: SocketAckEmitter! = nil;
    static var url = "";
    static weak var delegate: SocketDelegate? = nil;
    static var timeout = Double(20);
    
    var socket : SocketIOClient?   = nil;
    
    var payload: SocketPayload! = nil;
    var payloadList: [SocketPayload]! = nil;
    
    var stage = 0;
    var busy = false;
    var newSocket = true;
    var registered = false;
    
    var idConnect: UUID! = nil;
    var idDisconnect: UUID! = nil;
    var idReconnect: UUID! = nil;
    var idError: UUID! = nil;
    var idStatus: UUID! = nil;
    
    var idAuthDone: UUID! = nil;
    var idAuthError: UUID! = nil;
    
    var manager: SocketManager;
    
    public init()
    {
        busy = false;
        registered = false;
        
        let config: SocketIOClientConfiguration = [.log(false), .forceNew(true), .forceWebsockets(true), .reconnects(false)]
        
        manager = SocketManager(socketURL: URL(string: ServerSocket.url)!, config: config)
        socket = manager.defaultSocket

        

        //socket = SocketIOClient(manager: manager, nsp: "rewards")

        print(ServerSocket.TAG, "connect: " + ServerSocket.url);
        
        if(socket != nil)
        {
            ServerSocket.emitter = SocketAckEmitter(socket: socket!, ackNum: 0)

            idConnect       = socket?.on(clientEvent: .connect, callback: listenerConnect)
            idDisconnect    = socket?.on(clientEvent: .disconnect, callback: listenerDisconnect)
            idStatus        = socket?.on(clientEvent: .statusChange, callback: listenerStatusChange)
            idError         = socket?.on(clientEvent: .error, callback: listenerError)

            //idConnect      = socket?.on("connect",      callback: listenerConnect);
            //idDisconnect   = socket?.on("disconnect",   callback: listenerDisconnect);
            //idReconnect    = socket?.on("reconnect",    callback: listenerReconnect);
            //idError        = socket?.on("error",        callback: listenerError);
        }
    }
    
    public func listenerError(data: [Any], callback: SocketAckEmitter)
    {
        print(ServerSocket.TAG, "listenerError: ", data)
        ServerSocket.emitter = callback;

        socket?.off(id: idConnect);
        socket?.off(id: idError);

        let output = [ServerData.err_server_unable]

        if(payload != nil && payload.errorListener != nil)
        {
            payload.errorListener!(output, ServerSocket.emitter);
        }

        //EventBus.getDefault().post(new MicinitiEvent("socket_errored", args));

        queuePurge(output)
        payload = nil;

        busy = false;
    }
    
    public func listenerConnect(data: [Any], callback: SocketAckEmitter)
    {
        print(ServerSocket.TAG, "listenerConnect: ", data)
        ServerSocket.emitter = callback;
        
        socket?.off(id: idConnect)
        socket?.off(id: idError)
        
        registered = false;
        
        //EventBus.getDefault().post(new MicinitiEvent("socket_connected", args));
        
        authWithPayload();
    }
    
    public func listenerStatusChange(data: [Any], callback: SocketAckEmitter)
    {
        print(ServerSocket.TAG, "listenerStatusChange: ", data);
        
    }
    
    public func listenerReconnect(data: [Any], callback: SocketAckEmitter)
    {
        print(ServerSocket.TAG, "listenerReconnect: ", data);
        
    }
    
    public func listenerDisconnect(data: [Any], callback: SocketAckEmitter)
    {
        print(ServerSocket.TAG, "listenerDisconnect: ", data);
        
        queuePurge(["Connection error!"])
        
        socket?.off(id: idConnect);
        socket?.off(id: idDisconnect);
        socket?.removeAllHandlers();
        
        MicinitiEvent.post("socket", message: "socket_disconnected")

        busy = false;
        registered = false;
        socket = nil;
        ServerSocket.instance = nil;
    }
    
    public static func getInstance() -> ServerSocket!
    {
        if (instance == nil)
        {
            instance = ServerSocket();
        }
        return instance;
    }
    
    public func getSocket() -> SocketIOClient!
    {
        return socket;
    }
    
    public static func isConnected() -> Bool
    {
        return getInstance().getSocket().status == SocketIOStatus.connected;
    }
    
    public static func setSocketDelegate(_ delegate: SocketDelegate?)
    {
        ServerSocket.delegate = delegate;
    }
    
    public static func getSocketUrl() -> String
    {
        return ServerSocket.url
    }

    public static func setSocketUrl(_ url: String)
    {
        ServerSocket.url = url;
    }

    public static func setNewType(_ n: Bool)
    {
        ServerSocket.getInstance().newSocket = n;
    }
    
    public static func setBusy(_ r: Bool)
    {
        ServerSocket.getInstance().busy = r;
    }
    
    public static func isBusy() -> Bool
    {
        return ServerSocket.getInstance().busy;
    }
    
    public static func setRegistered(_ r: Bool)
    {
        ServerSocket.getInstance().registered = r;
    }
    
    public static func isRegistered() -> Bool
    {
        return ServerSocket.getInstance().registered;
    }
    
    public static func onEvent(event: String, callback: @escaping NormalCallback) -> UUID
    {
        return ServerSocket.getInstance().getSocket().on(event, callback: callback);
    }
    
    public static func offEvent(id: UUID)
    {
        ServerSocket.getInstance().getSocket().off(id: id);
    }
    
    public static func onError(callback: @escaping NormalCallback) -> UUID
    {
        return ServerSocket.getInstance().getSocket().on("error", callback: callback);
    }
    
    public static func offError(id: UUID)
    {
        ServerSocket.getInstance().getSocket().off(id: id);
    }
    
    public static func disconnect()
    {
        if(instance == nil)
        {
            return;
        }
        
        instance?.busy = false;
        
        if(instance?.socket != nil)
        {
            instance?.socket?.disconnect();
        }
        
        instance = nil;
    }
    
    public static func emit(event: String, param: Any)
    {
        ServerSocket.getInstance().getSocket().emit(event, with: [param]);
    }
    
    @discardableResult
    public static func output(event: String, data: [String: Any], done: NormalCallback!, error: NormalCallback!) -> Bool
    {
        var json = data;
        
        let pyld = SocketPayload(event: event, payload: data, doneListener: done, errorListener: error);

        if(ServerSocket.isBusy())
        {
            ServerSocket.queueAdd(pyld);

            return false;
        }
        
        print(TAG, "output: " + event + " ", json);
        
        if(ServerSocket.isConnected())
        {
            if(isRegistered())
            {
                queueDrain();
                
                if(event.count > 0)  // && json.count != 0
                {
                    json["event"] = event;
                    
                    ServerSocket.getInstance().getSocket().emit(EVENT, with: [json]);
                }
            
                if(done != nil)
                {
                    done!([], ServerSocket.emitter);
                }
            }
            else
            {
                ServerSocket.getInstance().authWithPayload();
            }
        }
        else
        {
            if(!Server.isOnline())
            {
                if(error != nil && ServerSocket.emitter != nil)
                {
                    error!([ServerData.err_no_connection], ServerSocket.emitter);
                }
                return false;
            }
            
            ServerSocket.setBusy(true);
        
            ServerSocket.getInstance().payload = pyld;
            ServerSocket.getInstance().getSocket().connect(timeoutAfter: ServerSocket.timeout, withHandler: {
                ServerSocket.getInstance().timeout()
            })
        }
        
        return true;
    }
    
    func timeout()
    {
        listenerError(data: ["Timeout"], callback: ServerSocket.emitter)
    }
 
    public func authWithPayload()
    {
        ServerSocket.setBusy(true);

        var params = [String: String]();
        
        var event = "";
        if (ServerSocket.delegate?.shouldHome(self))!
        {
            let size = Device.screenSize()
            
            // params["tag"]       = "\(DeviceUID.uid()!)";
            
            params["make"]      = "Apple"
            params["name"]      = "\(Device.node())"    //TODO ??
            params["model"]     = "\(Device.model())"
            
            params["os"]        =  "iOS";
            params["osver"]     = "\(UIDevice.current.systemVersion)"
            
            params["width"]     = "\(size.width)"
            params["height"]    = "\(size.height)"
            
            params["lon"]       = "0"   //"\(Prefs.getLastLon())"
            params["lat"]       = "0"   //"\(Prefs.getLastLat())"
            
            params["network"]   = "\(Device.network())"
            params["country"]   = "\(Device.country())"
            
            if(newSocket)
            {
                params["app"]    = ServerSocket.delegate?.getApp(self) ?? "";
            }
            
            params["appver"]    = ServerSocket.delegate?.getAppVer(self) ?? ""
            params["stamp"]     = "\(DateTime.currentTimeMillis())"
            
            params["token"]     = Prefs.pushToken;

            event = Device.EVENT_REGISTER;
        }
        else
        {
            event = Device.EVENT_CONNECT;
        }

        params[ServerSocket.EVENT]      = event;
        params[ServerData.APIHASH]    = Prefs.apiHash;
        params[ServerData.APITOKEN]   = Prefs.apiToken;
        params[ServerData.APISIGN]    = ServerSocket.signJSON(event: event, params: params);
        
        idAuthDone = socket?.on(event, callback: listenerAuthDone);
        idAuthError = socket?.on("error", callback: listenerAuthError);
        
        socket?.emit(ServerSocket.EVENT, with: [params]);
    }
    
    public func listenerAuthDone(data: [Any], callback: SocketAckEmitter)
    {
        print(ServerSocket.TAG, "listenerAuthDone: ", data);
     
        socket?.off(id: idAuthDone);
        socket?.off(id: idAuthError);
        
        var error = "";
        
        if let json = data[0] as? [String: Any]
        {
            let status = json["status"] as! Bool;
            let message = json["message"] as! String;
            
            print(status, message);

            if(status)
            {
                if let data = json["data"] as? [String: Any]
                {
                    _ = ServerSocket.delegate?.payloadDone(self, payload, data)
                    
                    if(payload != nil && !payload!.event.isEmpty && !payload!.data.isEmpty)
                    {
                        if(payload!.sentListener != nil)
                        {
                            payload!.idDone  = socket?.on(payload!.event, callback: payload!.sentListener);
                        }
                        
                        if(payload!.errorListener != nil)
                        {
                            //payload!.idError = socket?.on("error", callback: payload!.errorListener)
                        }

                        payload!.data["event"] = payload!.event
                        socket?.emit("event", [payload!.data])
                    }
                    
                    //EventBus.getDefault().post(new MicinitiEvent("socket_registered", Integer.valueOf(update)));

                    ServerSocket.queueDrain();
                    
                    busy = false;
                    registered = true;

                    return;
                }
                else
                {
                    error = ServerData.err_invalid_data;
                }
            }
            else
            {
                error = message ;
            }
        }
        else
        {
            error = ServerData.err_invalid_response;
        }
        
        busy = false;

        if(payload != nil && payload.errorListener != nil)
        {
            payload.errorListener!([error], ServerSocket.emitter);
        }

        payload = nil;
        
        queuePurge([error])
    }
    
    public func listenerAuthError(data: [Any], e: SocketAckEmitter)
    {
        print(ServerSocket.TAG, "listenerAuthError: ", data);
        
        socket?.off(id: idAuthDone);
        socket?.off(id: idAuthError);

        //socket?.off(id: idConnect);
        socket?.off(id: idError);
        
        let output = ["Authentication error!"];
        
        if(payload != nil && payload.errorListener != nil)
        {
            payload.errorListener!(output, ServerSocket.emitter);
        }
        
        payload = nil;
        
        queuePurge(output)
        
        busy = false;
    }

    private static func signJSON(event: String, params: [String: String]) -> String
    {
        var hash = "";
        
        hash = String.sha1(event);

        let sortedKeys = Array(params.keys).sorted(by: <)
        
        for key in sortedKeys
        {
            if(key == ServerSocket.EVENT || key == ServerData.APISIGN)
            {
                continue;
            }
            
            let data : String = params[key]!;
            
            hash = String.sha1(hash + data);
        }

        return hash;
    }
    
    public static func queueAdd(_ payload: SocketPayload)
    {
        if let instance = ServerSocket.getInstance()
        {

            if(instance.payloadList == nil)
            {
                instance.payloadList = [SocketPayload]();
            }
            
            objc_sync_enter(self)
            
            instance.payloadList.append(payload);
            
            objc_sync_exit(self)
        }
    }
    
    public func queuePurge(_ data: [Any]?)
    {
        if(payloadList == nil || payloadList.count == 0)
        {
            return;
        }
        
        objc_sync_enter(self)
        
        let output = (data != nil) ? data! : ["An error occurred!"];
        
        for pd in payloadList
        {
            if (pd.errorListener != nil)
            {
                pd.errorListener(output, ServerSocket.emitter);
            }
        }

        payloadList.removeAll();

        objc_sync_exit(self)
    }
    
    public static func queueDrain()
    {
        if let instance = ServerSocket.getInstance()
        {
            if(instance.payloadList == nil || instance.payloadList.count == 0)
            {
                return;
            }
            
            objc_sync_enter(self)
            
            for pd in instance.payloadList
            {
                pd.data["event"] = pd.event;
                if(pd.sentListener != nil)
                {
                    instance.getSocket().on(pd.event, callback: pd.sentListener);
                }
                
                if(pd.errorListener != nil)
                {
                    instance.getSocket().on("error", callback: pd.errorListener);
                }

                instance.getSocket().emit(ServerSocket.EVENT, with: [pd.data])
            }
            
            instance.payloadList.removeAll();
        
            objc_sync_exit(self)
        }
    }

}

class SocketPayload
{
    public var event: String ;
    public var data: [String: Any];
    public var sentListener: NormalCallback!;
    public var errorListener: NormalCallback!;

    public var idDone: UUID! = nil;
    public var idError: UUID! = nil;

    public init(event: String, payload: [String: Any], doneListener: NormalCallback!, errorListener: NormalCallback!)
    {
        self.event = event;
        self.data = payload;
        self.sentListener = doneListener;
        self.errorListener = errorListener;
    }
}

protocol SocketDelegate : NSObjectProtocol
{
    func payloadDone    (_ server: ServerSocket!, _ payload: SocketPayload?, _ json: [String: Any]) -> [Any]
    func shouldHome     (_ server: ServerSocket!) -> Bool
    func getApp         (_ server: ServerSocket!) -> String
    func getAppVer      (_ server: ServerSocket!) -> String
    func getHash        (_ server: ServerSocket!) -> String
    func getToken       (_ server: ServerSocket!) -> String
    func getPush        (_ server: ServerSocket!) -> String
    func getLon         (_ server: ServerSocket!) -> String
    func getLat         (_ server: ServerSocket!) -> String
}
