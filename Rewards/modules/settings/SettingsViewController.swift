//
//  SettingsViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 08/06/2018.
//  Copyright © 2017 Anthonio Ez. All rights reserved.
//

import UIKit

class SettingsViewController: ListingViewController, MenuBarDelegate, ListingsDelegate
{
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableList: UITableView!
    
    let pushStatus   = 1
    let pushSound    = 2
    let pushVibrate  = 3

    var pageName = "Settings"
    
    static func instance() -> SettingsViewController
    {
        let vc = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        return vc;
    }
    
    deinit
    {
        print("SettingsViewController deinit")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white;
        
        menuBar.delegate = self
        menuBar.titleText = pageName
        menuBar.shadow();
        
        self.listingDelegate = self;
        setupTable(tableList);

        Ad.count(1);
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
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
    }
    
    //MARK: - Funcs
    override func listingSelect(_ item: ListingsItem)
    {
        if(item.type == .toggle)
        {
            switchChanged(id: item.id, value: !switchValue(id: item.id))
        }
        else if(item.type == .link)
        {
            //processLinks(item);
        }
        
    }
    
    //MARK: - ListingsDelegate
    func switchValue(id: Int) -> Bool
    {
        switch(id)
        {
        case pushStatus:
            return Prefs.pushStatus
            
        case pushSound:
            return Prefs.pushSound
            
        case pushVibrate:
            if(!Prefs.pushSound)
            {
                //return false
            }
            return Prefs.pushVibrate
            
        default:
            return false
        }
    }
    
    func switchChanged(id: Int, value: Bool)
    {
        switch(id)
        {
        case pushStatus:
            Prefs.pushStatus = value;
            Prefs.pushTokenSent = false;
            break;
            
        case pushSound:
            Prefs.pushSound = value
            if(!value)
            {
                //Prefs.pushVibrate = false
                //tableView.reloadData()
            }
            break;
            
        case pushVibrate:
            Prefs.pushVibrate = value
            break;
            
        default:
            return
        }
        
        self.tableList.reloadData()
        
        //Rewards.countInterstitial(count: 1)
    }

    func loadItems()
    {
        listings.removeAll();
        
        listings.append(ListingsItem(id: 0,                     type: .section, title: "Notifications"))
        listings.append(ListingsItem(id: pushStatus,            type: .toggle,  title: "Status",        descOn: "Push notifications enabled",           descOff: "Push notifications disabled"))
        listings.append(ListingsItem(id: pushSound,             type: .toggle,  title: "Sound",         descOn: "Play sound on incoming notifications", descOff: "No sound"))
        listings.append(ListingsItem(id: pushVibrate,           type: .toggle,  title: "Vibrate",       descOn: "Vibrate on incoming notifications",    descOff: "Do not vibrate"))
        
        tableList.reloadData()
    }
    
}

