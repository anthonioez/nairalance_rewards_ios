//
//  AboutHelpViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 03/06/2018.
//  Copyright © 2018 waltech. All rights reserved.
//

import UIKit

class AboutHelpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MenuBarDelegate
{    
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableList: UITableView!

    var listings = [HelpItem]();
    
    static func instance() -> AboutHelpViewController
    {
        let vc = AboutHelpViewController(nibName: "AboutHelpViewController", bundle: nil)
        return vc;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        menuBar.delegate = self;
        menuBar.titleText = "How It Works"
        menuBar.shadow();

        tableList.delegate = self
        tableList.dataSource = self
        
        tableList.separatorColor = UIColor.clear
        
        tableList.register(UINib(nibName: HelpItemCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: HelpItemCell.cellIdentifier)

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
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
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
        Rewards.popupTell(menuBar.buttonRight)        
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ heightForRowAttableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return HelpItemCell.cellHeight;
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        return false
    }
    
    //MARK: UITableViewDataSource
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return listings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let item = listings[indexPath.row];
        let cell = tableView.dequeueReusableCell(withIdentifier: HelpItemCell.cellIdentifier, for: indexPath) as! HelpItemCell
        cell.setData(item: item)
        return cell
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }

    //MARK: - Funcs
    func loadItems()
    {
        listings.removeAll();
        
        listings.append(HelpItem(image: UIImage(named: "intro_invite"),     title: Strings.intro_invite,      desc: Strings.intro_invite_desc));
        listings.append(HelpItem(image: UIImage(named: "intro_play"),       title: Strings.intro_play,        desc: Strings.intro_play_desc));
        
        listings.append(HelpItem(image: UIImage(named: "intro_earn"),       title: Strings.intro_earn,        desc: Strings.intro_earn_desc));
        listings.append(HelpItem(image: UIImage(named: "intro_cashout"),    title: Strings.intro_cashout,     desc: Strings.intro_cashout_desc));

        tableList.reloadData()
        
    }
}
