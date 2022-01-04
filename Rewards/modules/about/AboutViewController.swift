//
//  AboutViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 14/01/2017.
//  Copyright © 2017 Anthonio Ez. All rights reserved.
//

import UIKit
import SDWebImage

class AboutViewController: ListingViewController, MenuBarDelegate
{
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableList: UITableView!
    
    var adInters: AdmobInters! = nil

    let itemHlp = 10;
    let itemFaq = 11;
    
    let itemWeb = 17
    let itemVer = 13;
    let itemRat = 14;
    let itemMor = 15;
    
    let itemSup = 16;
    let itemPub = 18
    let itemDev = 19
    
    let itemFcb = 20
    let itemTwt = 21
    let itemTll = 22
    
    var pageName = "About"

    static func instance() -> AboutViewController
    {
        let vc = AboutViewController(nibName: "AboutViewController", bundle: nil)
        return vc;
    }
    
    deinit
    {
        print("AboutViewController deinit")
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white; // Rewards.colorMain

        menuBar.delegate = self
        menuBar.titleText = pageName
        menuBar.shadow();
        
        setupTable(tableList);

        Ad.count(1);
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        loadItems();
    }
    
    override func viewWillLayoutSubviews()
    {
        let inset = UI.insets();
        if(inset.bottom > 0)
        {
            menuBarHeight.constant = inset.top + MenuBar.barHeight
        }
        
        tableList.contentInset.bottom = inset.bottom
        
        super.viewWillLayoutSubviews();
    }
    
    //MARK: - MenuBarDelegate
    func buttonLeftTapped(_ input: MenuBar!)
    {
        AppDelegate.popController(true)
    }
    
    func buttonRightTapped(_ input: MenuBar!)
    {
        AppDelegate.pushController(SettingsViewController.instance(), animated: true);
    }
    
    //MARK: - Funcs
    override func listingSelect(_ item: ListingsItem)
    {
        if(item.type == .link)
        {
            processLinks(item);
        }
        
    }
    
    func processLinks(_ item: ListingsItem)
    {
        //Rewards.countInterstitial(count: 1)
        
        switch(item.id)
        {
        case itemHlp:
            AppDelegate.pushController(AboutHelpViewController.instance(), animated: true)
            break;
            
        case itemFaq:
            AppDelegate.pushController(AboutFAQViewController.instance(), animated: true)
            break;
                        
        case itemWeb:
            Rewards.openUrl("http://nairalance.com");
            break;
            
        case itemVer:
            Rewards.openStoreUrl()
            break;

        case itemRat:
            Appirater.rateApp();
            break;
            
        case itemMor:
            Rewards.openStoreDevUrl();
            break;
            
            
        case itemFcb:
            Rewards.openUrl("http://facebook.com/Nairalance");
            break;
            
        case itemTwt:
            Rewards.openUrl("http://twitter.com/Nairalance");
            break;
            
        case itemTll:
            Rewards.invite();
            break;
            

        case itemSup:
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.support(self);
            break;
            
        case itemPub:
            Rewards.openUrl("https://miciniti.com");
            break;
            
        case itemDev:
            Rewards.openUrl("http://twitter.com/ai_n_ce");
            break;
            
        default:
            break;
        }
    }
    
    func loadItems()
    {
        listings.removeAll();
        
        listings.append(ListingsItem(id: 0,             type: .section, title: "Help"))
        
        listings.append(ListingsItem(id: itemHlp,       type: .link,    title: "Help",              desc: "How it works",                           image: UI.imageWithColor("ic_info_white_48pt"),                 color: Rewards.colorTheme))
        listings.append(ListingsItem(id: itemFaq,       type: .link,    title: "FAQs",              desc: "Frequently asked questions",             image: UI.imageWithColor("ic_help_white_48pt"),                 color: Rewards.colorActive))
        
        listings.append(ListingsItem(id: 0,             type: .section, title: "Info"))
        listings.append(ListingsItem(id: itemWeb,       type: .link,    title: "Website",           desc: "nairalance.com",                         image: UI.imageWithColor("ic_public_white_48pt"),               color: Rewards.colorPassive))
        listings.append(ListingsItem(id: itemVer,       type: .link,    title: "Version",           desc: Rewards.appVer,                           image: UI.imageWithColor("ic_ios_white_48pt"),         color: Rewards.colorMain))
        listings.append(ListingsItem(id: itemRat,       type: .link,    title: "Rate",              desc: "Rate Rewards on App Store",              image: UI.imageWithColor("ic_star_white_48pt"),                 color: UIColor(hex: "#FFFFa800")))
        listings.append(ListingsItem(id: itemMor,       type: .link,    title: "More apps",         desc: "Get more apps by Miciniti",              image: UI.imageWithColor("ic_apps_white_48pt"),                 color: Rewards.colorActive))
        
        listings.append(ListingsItem(id: 0,             type: .section, title: "Connect With Us"))
        listings.append(ListingsItem(id: itemFcb,       type: .link,    title: "Like on Facebook",  desc: "facebook.com/Nairalance",                image: UI.imageWithColor("ic_facebook_white_48pt"),             color: UIColor(hex: "#4267B2")))
        listings.append(ListingsItem(id: itemTwt,       type: .link,    title: "Follow on Twitter", desc: "twitter.com/Nairalance",                 image: UI.imageWithColor("ic_twitter_white_48pt"),              color: UIColor(hex: "#1DA1F2")))
        listings.append(ListingsItem(id: itemTll,       type: .link,    title: "Tell a Friend",     desc: "Tell a friend about Rewards",            image: UI.imageWithColor("ic_record_voice_over_white_48pt"),    color: Rewards.colorTheme))
        
        listings.append(ListingsItem(id: 0,             type: .section, title: "Contact Us"))
        listings.append(ListingsItem(id: itemSup,       type: .link,    title: "Support",           desc: Rewards.appEmail,                         image: UI.imageWithColor("ic_mail_white_48pt"),                 color: Rewards.colorActive))
        listings.append(ListingsItem(id: itemPub,       type: .link,    title: "Publisher",         desc: "miciniti.com",                           image: UIImage(named: "miciniti"),                              color: nil))
        listings.append(ListingsItem(id: itemDev,       type: .link,    title: "Developer",         desc: "@ai_n_ce",                               image: UI.imageWithColor("ic_bug_report_white_48pt"),           color: Rewards.colorAlert))
        
        //listings.append(ListingsItem(id: 0,             type: .spacer))
        
        tableList.reloadData()
        
    }    
}
