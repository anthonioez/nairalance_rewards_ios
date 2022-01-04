//
//  Rewards.swift
//  Rewards
//
//  Created by Anthonio Ez on 02/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class Rewards: NSObject {

    static let colorMain    = UIColor(hex: "#3F51B5");
    static let colorTheme   = UIColor(hex: "#303F9F");
    
    static let colorActive  = UIColor(hex: "#00B000");
    static let colorPassive = UIColor(hex: "#7babed");
    static let colorClaimed = UIColor(hex: "#C0C0C0");
    
    static let colorAlert       = UIColor(hex: "#B90000");
    static let colorEdit        = UIColor(hex: "#CCCCFF");
    static let colorAsh         = UIColor(hex: "#ced6e3");
    static let colorTitle       = UIColor(hex: "#313131");
    static let colorDetail      = UIColor(hex: "#727272");
    static let colorDivider     = UIColor(hex: "#e6e6e6", alpha: 0.2);
    static let colorDividerDark = UIColor(hex: "#e6e6e6");
    static let colorHilite      = UIColor(hex: "#EEEEEE")
    
    static var font : UIFont!
    static var fontBold : UIFont!
    static var fontLight : UIFont!

    static var appName      = "Nairalance Rewards"
    static var appVer       = "1.0.0"
    static var appID        = "1397061665";   
    static var appPhone     = "+2348168838969"
    static var appEmail     = "rewards@nairalance.com"
    static var appUrl       = "https://nairalance.com"
    static var feedback     = 0;
    static let appStoreUrl  = "http://nairalance.com/rewards" //TODO

    static var logoMain: UIImage! = nil;
    static var logoWhite: UIImage! = nil;
    
    static var admobIdApp       = "ca-app-pub-7287313281467473~9059468731"
    static var admobIdBanner    = "ca-app-pub-7287313281467473/4880265161"  //TODO test -> "ca-app-pub-3940256099942544/2934735716"
    static var admobIdInters    = "ca-app-pub-7287313281467473/9187052120"  //TODO test -> "ca-app-pub-3940256099942544/4411468910"
    static var admobIdRewarded  = "ca-app-pub-7287313281467473/3100279633"; //TODO test -> "ca-app-pub-3940256099942544/1712485313"
    
    
    static var youtubeAPIKey    = "";
    
    static var rewardedAdmob : AdmobRewarded! = nil;
    
    static var mainReady = false;
    static var pushPayload: [String: Any]! = nil;

    public static func setup(_ delegate: SocketDelegate)
    {
        appVer = Utils.version()

        font        = UIFont.init(name: "sourcesanspro-regular", size: 16);
        fontBold    = UIFont.init(name: "sourcesanspro-bold", size: 16);
        fontLight   = UIFont.init(name: "sourcesanspro-light", size: 16);

        logoMain = UIImage.init(named: "logo.png")
        logoWhite = UIImage.init(named: "logo_white.png")
        
        MenuBar.color = Rewards.colorMain
        MenuBar.font = Rewards.font.withSize(20);

        RoundInput.textColor = Rewards.colorTitle;
        RoundInput.buttonColor = Rewards.colorMain;
        RoundInput.font = Rewards.font;
        
        Toast.font = Rewards.font;
        ProgressDialog.font = Rewards.font;
        
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().textFont = Rewards.font;
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = Rewards.colorPassive; // UIColor.lightGray
        DropDown.appearance().cellHeight = 50

        PMAlertController.titleFont          = Rewards.fontBold;
        PMAlertController.titleColor         = Rewards.colorTitle;
        
        PMAlertController.bodyFont           = Rewards.font;
        PMAlertController.bodyColor          = Rewards.colorDetail;
        
        PMAlertController.buttonFont         = Rewards.font;
        PMAlertController.buttonColorActive  = Rewards.colorTheme;
        PMAlertController.buttonColorDefault = Rewards.colorTitle;

        
        Listings.colorHeader    = Rewards.colorMain
        Listings.colorTitle     = Rewards.colorTitle
        Listings.colorDesc      = Rewards.colorDetail;
        Listings.colorDivider   = Rewards.colorDividerDark;
        
        Listings.fontHeader     = Rewards.fontBold.withSize(12);
        Listings.fontTitle      = Rewards.font
        Listings.fontDesc       = Rewards.font.withSize(12);
        
        ServerSocket.setSocketUrl(appUrl + ":1550")
        ServerSocket.setSocketDelegate(delegate);
    }
    
    public static func isUser() -> Bool
    {
        return !Prefs.userID.isEmpty && !Prefs.apiToken.isEmpty;
    }    

    static func shareApp()
    {
        shareText("Check out Nairalance Rewards for iOS. Download it today from http://nairalance.com/rewards")
    }
    
    static func invite()
    {
        //TODO invite a friend
        shareText("Check out Nairalance Rewards for iOS. Download it today from http://nairalance.com/rewards")
    }
    
    static func shareText(_ text: String)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // set up activity view controller
        let objectsToShare: [AnyObject] = [ text as AnyObject ]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = appDelegate.navController.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        //activityViewController.excludedActivityTypes = [ UIActivityTypeAirDrop, UIActivityTypePostToTwitter, UIActivityTypePostToFacebook, UIActivityTypeMessage, UIActivityTypeMail ]
        
        appDelegate.navController.present(activityViewController, animated: true, completion: nil)
    }
    
    static func shareImage(_ image: UIImage, text: String)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // set up activity view controller
        var objectsToShare: [AnyObject] = []
        
        objectsToShare.append(image)
        
        if(!text.isEmpty)
        {
            objectsToShare.append(text as AnyObject)
        }
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = appDelegate.navController.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        //activityViewController.excludedActivityTypes = [ UIActivityTypeAirDrop, UIActivityTypePostToFacebook ]
        
        appDelegate.navController.present(activityViewController, animated: true, completion: nil)
    }
    
    static func openUrl(_ url: String)
    {
        openUrl(URL(string: url)!)
    }
    
    static func openUrl(_ url: URL)
    {
        UIApplication.shared.openURL(url)
    }
    
    static func openStoreDevUrl()
    {
        //let url = URL(string: "itms-apps://itunes.com/apps/miciniti-nigeria-ltd") //TODO
        let url = URL(string: "itms-apps://itunes.apple.com/ng/developer/miciniti-nigeria-ltd/id889715682")
        if (UIApplication.shared.canOpenURL(url!))
        {
            UIApplication.shared.openURL(url!)
        }
        else
        {
            openUrl(url!)
        }
    }
    
    static func openStoreUrl()
    {
        let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)")
        if (UIApplication.shared.canOpenURL(url!))
        {
            UIApplication.shared.openURL(url!)
        }
        else
        {
            openUrl(appStoreUrl)
        }
    }
    
    static func signin()
    {
        RewardsEvent.post("signin", message: "")

        RewardsAnalytics.logEvent("signin", Prefs.userName);
    }
    
    static func login()
    {
        RewardsEvent.post("login", message: "")
            
        RewardsAnalytics.logEvent("login", Prefs.userName);
    }
    
    static func typeImage(_ type: String) -> UIImage?
    {
        var image = "logo";
        
        switch (type)
        {
        case "invite":
            image = "type_invite"
            break;
            
        case "admob":
            image = "type_admob";
            break;
            
        case "youtube":
            image = "type_youtube";
            break;
            
        case "audience":
            image = "type_facebook";
            break;
            
        case "facebook":
            image = "type_facebook";
            break;
            
        case "instagram":
            image = "type_instagram";
            break;
            
        case "twitter":
            image = "type_twitter";
            break;
            
        case "android":
            image = "type_android";
            break;
            
        case "bonus":
            image = "type_bonus";
            break;
            
        default:
            image = "logo";
        }
        
        return UIImage(named: image);
    }
    
    public static func payoutType(_ type: String) -> String
    {
        switch (type)
        {
            case "airtime":
                return "Airtime";
    
            case "bank":
                return "Bank Transfer";
    
            default:
                return "Unknown";
        }
    }
    
    public static func providerImage(_ type: String) -> UIImage?
    {
        switch (type)
        {
            case "airtime":
                return UIImage(named: "ic_phone_iphone_white_48pt");
        
            case "bank":
                return UIImage(named: "ic_account_balance_white_48pt");
        
            default:
                return UIImage(named: "logo");
        }
    }

    static func dropDown() -> DropDown
    {
        let drop = DropDown()
        drop.width = 160;
        return drop;
    }
    
    static func popupTell(_ view: UIView)
    {
        let dropDown = Rewards.dropDown()
        dropDown.anchorView = view
        dropDown.dataSource = ["Tell a friend"]        
        dropDown.selectionAction = { (index: Int, item: String) in
            if(index == 0)
            {
                Rewards.invite()
            }
        }
        
        dropDown.show()
    }
    
    static func notify(_ title: String, message: String, image: UIImage!, type: String = "", data: [String: Any])
    {
        /*
        let notificationManager = LNRNotificationManager()
        notificationManager.notificationsPosition = LNRNotificationPosition.top
        notificationManager.notificationsBackgroundColor = UIColor.white
        notificationManager.notificationsTitleTextColor = HelperUi.primaryColor
        notificationManager.notificationsBodyTextColor = UIColor.black
        notificationManager.notificationsSeperatorColor = HelperUi.secondaryColor
        
        if Prefs.getPushSound()
        {
            notificationManager.notificationSound = notifySound
        }
        else
        {
            notificationManager.notificationSound = nil
        }
        
        notificationManager.notificationsIcon = image;
        notificationManager.notificationsIconSize = CGSize(width: 64, height: 64);
        
        notificationManager.notificationsDefaultDuration = LNRNotificationDuration.endless.rawValue //5    //
        
        notificationManager.notificationAlert = Prefs.getPushVibrate()
        
        var body: String = message;
        let len = 300;
        if(body.length() > len)
        {
            body = body.substringWithRange(0, length: len) + "...";
        }
        
        notificationManager.showNotification(title, body: body, hint: nil, onTap: {  () -> Void in
            _ = notificationManager.dismissActiveNotification({ () -> Void in
                print("Notification tap")
                
                Catchup.processNotification(data);
            })
        }, onSwipe: {  () -> Void in
            _ = notificationManager.dismissActiveNotification({ () -> Void in
                print("Notification dismissed")
            })
            
        })*/
    }
    
    static func processNotification(_ payload: [String: Any])
    {
        RewardsAnalytics.logEvent("push_open", (payload["pid"] as? String) ?? "");

        if(payload.count == 0)
        {
            return;
        }
        
        let path = payload["path"] as? String;    
        if(path == nil)
        {
            return
        }
        else if(path == "rewards")
        {
            guard
                let id = payload["data"] as? Int,
                let title = payload["title"] as? String,
                let type = payload["type"] as? String
                else
            {
                return
            }
            
            if(id != 0 && !title.isEmpty)
            {
                AppDelegate.pushController(RewardsViewController.instance(id, title, type), animated: true)
            }
        }
        else if(path == "youtube")
        {
            guard
                let json = payload["data"] as? [String: Any]
                else
            {
                return
            }
            
            let item = RewardItem();
            if(item.copyJSON(json: json))
            {
                AppDelegate.pushController(YoutubeViewController.instance(item), animated: true)
            }
        }
        else if(path == "rankings")
        {
            AppDelegate.pushController(RankingsViewController.instance(), animated: true)
        }
        else if(path == "earnings")
        {
            AppDelegate.pushController(EarningsViewController.instance(), animated: true)
        }
        else if(path == "cashout")
        {
            AppDelegate.pushController(CashoutViewController.instance(), animated: true)
        }
        else if(path == "faq")
        {
            AppDelegate.pushController(AboutFAQViewController.instance(), animated: true)
        }
        else if(path == "profile")
        {
            AppDelegate.pushController(ProfileEditViewController.instance(), animated: true)
        }
        else if(path == "link")
        {
            guard
                let data = payload["data"] as? String
                else
            {
                return
            }
            
            Rewards.openUrl(data);
        }
        else if(path == "rate")
        {
            Rewards.openStoreUrl();
        }

        /*
        else if(type == "content")
        {
            guard
                let id = payload["data"] as? Int,
                let title = payload["title"] as? String,
                let link = payload["link"] as? String
                else
            {
                return
            }
            
         
            let item = ContentItem();
            item.id = id;
            item.title = title;
            item.link = link
            Catchup.openContent(item: item);
        }
        else if( type == "source")
        {
            guard
                let id = payload["data"] as? Int,
                let title = payload["title"] as? String
                else
            {
                return
            }
            
            //Catchup.openFeed(title: title, id: id, type: "source", data: "", search: false);
        }
        else if( type == "interest")
        {
            guard
                let id = payload["data"] as? Int,
                let title = payload["title"] as? String
                else
            {
                return
            }
            
            //Catchup.openFeed(title: title, id: id, type: "interest", data: "", search: false);
        }
        else if( type == "search")
        {
            guard
                let title = payload["title"] as? String,
                let query = payload["data"] as? String
                else
            {
                return
            }
            //Catchup.openFeed(title: title, id: 0, type: "search", data: query, search: true);
        }*/
    }
    

}
