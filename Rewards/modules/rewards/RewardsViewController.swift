//
//  RewardsViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 03/06/2018.
//  Copyright © 2018 waltech. All rights reserved.
//

import UIKit
import SDWebImage

class RewardsViewController: AdViewController, UITableViewDelegate, UITableViewDataSource, MenuBarDelegate, SocketRewardsDelegate
{
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var progress: Progress!
    @IBOutlet weak var tableRewards: UITableView!
    @IBOutlet weak var viewAd: UIView!
    @IBOutlet weak var viewAdBottom: NSLayoutConstraint!
    
    var index = 0;
    var last : Double = 0

    var socketReward: SocketRewards! = nil;
    
    var isLoaded = false;
    var isLoading = false;
    var isInfinite = true;
    var rewards = [RewardItem]();

    var rewardId = 0;
    var rewardTitle = "";
    var rewardType = "";
    var rewardPlaceholder: UIImage! = nil;
    
    var pageName = "Rewards";
    
    static func instance(_ id: Int, _ title: String, _ type: String) -> RewardsViewController
    {
        let vc = RewardsViewController(nibName: "RewardsViewController", bundle: nil)
        vc.rewardId = id;
        vc.rewardType = type;
        vc.rewardTitle = title;
        return vc;
    }
    
    deinit
    {
        unload()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        //self.view.backgroundColor = Rewards.colorMain
        
        rewardPlaceholder = Rewards.typeImage(rewardType);
        pageName = "\(rewardTitle) Rewards"
        

        menuBar.shadow();
        menuBar.delegate = self;
        menuBar.titleText = pageName;
        
        self.tableRewards.delegate = self
        self.tableRewards.dataSource = self
        
        self.tableRewards.separatorColor = UIColor.clear
        self.tableRewards.register(UINib(nibName: RewardItemCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: RewardItemCell.cellIdentifier)
        
        Ad.count(1);

        admobLoadBanner(viewAd, Ad.SLOT_REWARDS, 10, 0)

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
        
        if(!isLoaded && rewards.count == 0)
        {
            load();
        }
        else
        {
            tableRewards!.reloadData();
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
        
        viewAdBottom.constant = inset.bottom
        
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
                self.reload()
            }
        }
        
        dropDown.show()
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return RewardItemCell.cellHeight;
    }
    
    //MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return rewards.count;
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        return true;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if(self.shouldLoadNext(indexPath.row, count: rewards.count, last: last, loading: isLoading, infinite: isInfinite))
        {
            //Rewards.countInterstitial(count: 1)
            
            Ad.count(1);

            load()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: RewardItemCell.cellIdentifier, for: indexPath as IndexPath) as! RewardItemCell
        
        let data = rewards[indexPath.row];
        cell.setData(data, rewardPlaceholder)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let data = rewards[indexPath.row];
        if(data.type == "youtube")
        {
            AppDelegate.pushController(YoutubeViewController.instance(data), animated: true);
        }
    }
    
    //MARK: - Funcs
    func reload()
    {
        index = 0;
        isInfinite = true;
        
        Ad.count(1);

        load()
    }
    
    func unload()
    {
        if(socketReward != nil)
        {
            socketReward.setCallback(delegate: nil)
            socketReward.stop()
            socketReward = nil
        }
    }
    
    func load()
    {
        unload();
        
        socketReward = SocketRewards(delegate: self);
        socketReward.start(rewardType, index, Reward.PAGE_SIZE)
    }
    
    func loadUI(_ active: Bool)
    {
        isLoading = active

        progress.animate(active)
        UI.dimView(tableRewards, active);
        
        if(active)
        {
            last = DateTime.currentTimeMillis()
        }
        else
        {
            last = 0;
        }
    }
    
    //MARK: - SocketRewardDelegate
    func rewardStarted()
    {
        loadUI(true)
    }
    
    func rewardSuccess(_ items: [RewardItem], _ index: Int)
    {
        loadUI(false)

        isLoaded = true
        if(index == 0)
        {
            self.rewards.removeAll();
        }
        
        self.rewards.append(contentsOf: items);
        
        isInfinite = items.count == Reward.PAGE_SIZE
        self.index = index + Reward.PAGE_SIZE;

        tableRewards.reloadData();

        if(index == 0 && self.rewards.count > 0)
        {
            tableRewards.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    func rewardError(_ error: String)
    {
        loadUI(false)
        
        UI.toast(self.view, error)
    }
}
