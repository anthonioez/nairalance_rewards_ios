//
//  AppDelegate.swift
//  Rewards
//
//  Created by Anthonio Ez on 26/05/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import SDWebImage

import UserNotifications
import MessageUI


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MFMailComposeViewControllerDelegate, MessagingDelegate, SocketDelegate, SocketTokenDelegate
{
    var window: UIWindow?
    var navController: UINavigationController!
    var socketToken: SocketToken! = nil;
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        GADMobileAds.configure(withApplicationID: Rewards.admobIdApp)
        
        Rewards.setup(self)
        
        navController = UINavigationController();
        navController.isNavigationBarHidden = true
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = navController
        self.window!.backgroundColor = UIColor.white
        self.window!.makeKeyAndVisible()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        navController.pushViewController(StartViewController.instance(), animated: true)
        
        registerForPushNotifications(application);
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: - Push
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings)
    {
        if notificationSettings.types != UIUserNotificationType()
        {
            //application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        print("didRegisterForRemoteNotificationsWithDeviceToken:", deviceToken)
        
        Messaging.messaging().apnsToken = deviceToken;

        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count
        {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("Device Token:", tokenString)
        
        let old = Prefs.pushToken;
        if(!old.isEmpty && old == tokenString)
        {
            //TODO return;
        }
        
        Prefs.pushToken = (tokenString)
        Prefs.pushTokenSent = (false)
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("didFailToRegisterForRemoteNotificationsWithError:", error)
    }
    
    /*
     @available(iOS 10.0, *)
     func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void)
     {
     print("userNotificationCenter didReceive:", response)
     
     }*/
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        print("userNotificationCenter willPresent:", notification.request.content.userInfo)
        
        completionHandler( [.alert, .badge, .sound]);   //show OS banner
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any])
    {
        print("didReceiveRemoteNotification: ", userInfo)
        
    }
    
    // MARK: Handle notifications tap
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        let state = application.applicationState;
        
        print("didReceiveRemoteNotificationc: ", state, userInfo)
        
        application.applicationIconBadgeNumber = 0;
        
        var title = Rewards.appName;
        var body = "";
        
        if let aps = userInfo["aps"] as? [String: AnyObject]
        {
            if let alert = aps["alert"] as? String
            {
                body = alert;
            }
            else if let alert = aps["alert"] as? [String: String]
            {
                if let t = alert["title"] as String?
                {
                    title = t
                }
                if let b = alert["body"] as String?
                {
                    body = b
                }
            }
            
            var data = [String: Any]();
            data["title"]   = (userInfo["title"] as? String) ?? title;
            data["body"]    = body;
            data["path"]    = (userInfo["path"] as? String) ?? "";
            data["type"]    = (userInfo["type"] as? String) ?? "";
            data["link"]    = (userInfo["link"] as? String) ?? "";
            data["image"]   = (userInfo["image"] as? String) ?? "";
            data["data"]    = userInfo["data"] as Any;
            data["pid"]     = (userInfo["pid"] as? String) ?? "";
            
            //let alert = aps["content-available"] as? NSString
            
            if(!body.isEmpty)
            {
                if (application.applicationState == UIApplicationState.active)
                {
                    if #available(iOS 10.0, *)
                    {
                        Rewards.processNotification(data);
                    }
                    else
                    {
                        Rewards.notify(title, message: body, image: nil, type: "push", data: data)
                    }
                }
                else if (application.applicationState == UIApplicationState.inactive)
                {
                    if(Rewards.mainReady)
                    {
                        Rewards.processNotification(data);
                    }
                    else
                    {
                        Rewards.pushPayload = data;
                    }
                }
                else if (application.applicationState == UIApplicationState.background)
                {
                    if(Rewards.mainReady)
                    {
                        Rewards.processNotification(data);
                    }
                    else
                    {
                        Rewards.pushPayload = data;
                    }
                }
            }
            else
            {
                //Rewards.processNotification(title!, body, data);
            }
        }
        
        Messaging.messaging().appDidReceiveMessage(userInfo);
        
        completionHandler(UIBackgroundFetchResult.noData)
    }
    
    // MARK: Handle notification action
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void)
    {
        print("handleActionWithIdentifier:", userInfo)
        
        /*
         // 1
         let aps = userInfo["aps"] as! [String: AnyObject]
         
         // 2
         if let newsItem = createNewNewsItem(aps)
         {
         // 3
         if identifier == "VIEW_IDENTIFIER", let url = NSURL(string: newsItem.link) {
         let safari = SFSafariViewController(URL: url)
         window?.rootViewController?.presentViewController(safari, animated: true, completion: nil)
         }
         }
         */

        completionHandler()
    }

    //MARK: - NAV
    public static func setControllers(_ controllers: [UIViewController], animated: Bool)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.navController.setViewControllers(controllers, animated: animated);
    }
    
    public static func pushController(_ controller: UIViewController, animated: Bool)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.navController.pushViewController(controller, animated: animated);
    }
    
    public static func popController(_ animated: Bool)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.navController.popViewController(animated: animated);
    }
    
    // MARK: Funcs
    func registerForPushNotifications(_ application: UIApplication)
    {
        if #available(iOS 10.0, *)
        {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        }
        else
        {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

        Messaging.messaging().delegate = self
    }
    
    //MARK: - MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String)
    {
        print("Messaging token: \(fcmToken )")

        /*
        if let atoken = Messaging.messaging().apnsToken
        {
        }
        
        if let token = Messaging.messaging().fcmToken
        {
            print("Messaging token: \(token )")
        }
        
        if let refreshedToken = InstanceID.instanceID().token()
        {
            print("InstanceID token: \(refreshedToken)")
        }
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }*/
    }
    
    //MARK: Send token
    func untoken()
    {
        if(socketToken != nil)
        {
            socketToken.setCallback(delegate: nil);
            socketToken.stop()
            socketToken = nil;
        }
    }
    
    func token()
    {
        untoken()
        
        socketToken = SocketToken(delegate: self)
        socketToken.start()
    }
    
    //MARK: SocketTokenDelegate
    func tokenStarted()
    {
        Utils.networkActivity(true)
    }
    
    func tokenSuccess(_ message: String)
    {
        Utils.networkActivity(false)
    }
    
    func tokenError(_ error: String)
    {
        Utils.networkActivity(false)
    }
    
    //MARK: SocketDelegate
    func payloadDone(_ server: ServerSocket!, _ payload: SocketPayload?, _ json: [String : Any]) -> [Any]
    {
        let res = [Any]();
        
        let route = json["route"] as? String;
        if(route != nil && !route!.isEmpty)
        {
            ServerSocket.setSocketUrl(route!);
            ServerSocket.disconnect();
        }
        
        Ad.parse(json); 

        Rewards.feedback = json["feedback"] as! Int;
        
        let hash = json["hash"] as! String;
        let token = json["token"] as! String;
        
        Prefs.apiHash = (hash);
        Prefs.apiToken = (token);
        
        
        let update      = json["update"] as! Int
        let updateMsg   = json["message"] as! String;
        //-2: maintenance
        //0: no update
        //1: alert update
        //2: force update

        Prefs.lastDev = (update <= 0 ? DateTime.currentTimeMillis() : 0);

        if(payload != nil && payload!.sentListener != nil)
        {
            payload!.sentListener!([update, updateMsg], ServerSocket.emitter);
        }

        return res;
    }
    
    func shouldHome     (_ server: ServerSocket!) -> Bool
    {
        return true;
    }
    
    func getApp         (_ server: ServerSocket!) -> String
    {
        return "rw";
    }
    
    func getAppVer      (_ server: ServerSocket!) -> String
    {
        return Rewards.appVer;
    }
    
    func getHash        (_ server: ServerSocket!) -> String
    {
        return Prefs.apiHash;
    }

    func getToken       (_ server: ServerSocket!) -> String
    {
        return Prefs.apiToken;
    }

    func getPush        (_ server: ServerSocket!) -> String
    {
        return Prefs.pushToken;
    }

    func getLon         (_ server: ServerSocket!) -> String
    {
        return "0"
    }
    
    func getLat         (_ server: ServerSocket!) -> String
    {
        return "0"
    }
    
    //MARK: - Support
    func support(_ controller: UIViewController)
    {
        //Rewards.countInterstitial(count: 1)
        
        if MFMailComposeViewController.canSendMail()
        {
            var body = "";
            body += "\r\n";
            body += "\r\n";
            body += "\r\n";
            body += "\r\nVersion: " + Rewards.appVer;
            body += "\r\nOS: " + UIDevice.current.systemVersion;
            body += "\r\nPhone: " + Device.node() + " " + Device.model();
            body += "\r\nCountry: " + Device.country();
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self;
            
            mail.setSubject("");
            mail.setToRecipients([Rewards.appEmail])
            mail.setMessageBody(body, isHTML: false)
            
            controller.present(mail, animated: true)
        }
        else
        {
            UI.alert(controller, Rewards.appName, "Your device cannot send mail!");
        }
    }
    
    //MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true)
    }
}

