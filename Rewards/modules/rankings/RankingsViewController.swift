//
//  RankingsViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 03/06/2018.
//  Copyright © 2018 waltech. All rights reserved.
//

import UIKit
import SDWebImage

class RankingsViewController: AdViewController, UITableViewDelegate, UITableViewDataSource, MenuBarDelegate, SocketRankingDelegate
{
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var progress: Progress!
    @IBOutlet weak var tableFooter: UITableView!
    @IBOutlet weak var tableRankings: UITableView!
    @IBOutlet weak var tableFooterHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewFooter: UIView!
    @IBOutlet weak var viewFooterHeight: NSLayoutConstraint!
    @IBOutlet weak var viewFooterBottom: NSLayoutConstraint!
    @IBOutlet weak var viewAd: UIView!

    var socketRanking: SocketRanking! = nil;
    
    var isLoaded = false;
    var userRankItem = RankingItem();
    var rankings = [RankingItem]();

    let pageName = "Rankings";
    
    static func instance() -> RankingsViewController
    {
        let vc = RankingsViewController(nibName: "RankingsViewController", bundle: nil)
        return vc;
    }
    
    deinit
    {
        unload()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = Rewards.colorMain

        menuBar.delegate = self;
        menuBar.titleText = pageName
        menuBar.shadow();
        
        self.tableRankings.delegate = self
        self.tableRankings.dataSource = self
        
        self.tableRankings.separatorColor = UIColor.clear
        self.tableRankings.register(UINib(nibName: RankingItemCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: RankingItemCell.cellIdentifier)
        
        self.tableFooter.delegate = self
        self.tableFooter.dataSource = self
        
        self.tableFooter.separatorColor = UIColor.clear
        self.tableFooter.register(UINib(nibName: RankingItemCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: RankingItemCell.cellIdentifier)
        
        self.tableFooterHeight.constant = RankingItemCell.cellHeight;
        self.viewFooterHeight.constant = RankingItemCell.cellHeight;
        
        self.viewFooter.backgroundColor = Rewards.colorMain
        self.viewFooter.raiseShadow()

        updateFooter()
        
        Ad.count(1);

        admobLoadBanner(viewAd, Ad.SLOT_RANKINGS, 5, 5)

        admobLoadInters()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        //updateFooter();
        
        if(!isLoaded && rankings.count == 0)
        {
            load();
        }
        else
        {
            tableRankings!.reloadData();
        }
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
        viewFooterHeight.constant = EarningItemCell.cellHeight + (inset.bottom / 2) + 1

        super.viewWillLayoutSubviews();
    }
    
    //MARK: MenuBarDelegate
    func buttonLeftTapped(_ input: MenuBar!)
    {
        admobShowOrFinish()
    }
    
    func buttonRightTapped(_ input: MenuBar!)
    {
        let dropDown = Rewards.dropDown()
        dropDown.anchorView = menuBar.buttonRight // UIView or UIBarButtonItem
        dropDown.dataSource = ["Reload"]
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if(index == 0)
            {
                self.load()
            }
        }
        
        dropDown.show()

    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return RankingItemCell.cellHeight;
    }
    
    //MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(tableView == tableRankings)
        {
            return rankings.count;
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        if(tableView == tableRankings)
        {
            return true;
        }
        else
        {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: RankingItemCell.cellIdentifier, for: indexPath as IndexPath) as! RankingItemCell
        
        if(tableView == tableRankings)
        {
            let data = rankings[indexPath.row];
            cell.setData(data)
            cell.viewDivider.isHidden = indexPath.row == (rankings.count - 1)
            return cell
        }
        else
        {
            cell.setData(userRankItem)
            cell.viewDivider.isHidden = true;
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(tableView == tableRankings)
        {
        }
    }
    
    //MARK: - Funcs
    func updateFooter()
    {
        userRankItem.id         = 0;
        userRankItem.image      = Prefs.userThumb;
        userRankItem.username   = Prefs.userName;
        userRankItem.ranking    = Prefs.userRanking;
        userRankItem.rewards    = Prefs.userRewards;
        
        tableFooter.reloadData()
    }
    
    func unload()
    {
        if(socketRanking != nil)
        {
            socketRanking.setCallback(delegate: nil)
            socketRanking.stop()
            socketRanking = nil
        }
    }
    
    func load()
    {
        unload();
        
        Ad.count(1);
        
        socketRanking = SocketRanking(delegate: self);
        socketRanking.start()
    }
    
    func rankingUI(_ active: Bool)
    {
        progress.animate(active)
        UI.dimView(tableRankings, active);
    }
    
    //MARK: - SocketRankingDelegate
    func rankingStarted()
    {
        rankingUI(true)
    }
    
    func rankingSuccess(_ items: [RankingItem])
    {
        rankingUI(false)
        
        self.rankings.removeAll();
        self.rankings.append(contentsOf: items);
        
        tableRankings.reloadData();
        
        if(self.rankings.count > 0)
        {
            tableRankings.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    func rankingError(_ error: String)
    {
        rankingUI(false)
        
        UI.toast(self.view, error)
    }
}
