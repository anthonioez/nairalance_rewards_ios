//
//  HomeViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 03/06/2018.
//  Copyright © 2018 waltech. All rights reserved.
//

import UIKit
import SDWebImage

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AdmobRewardedDelegate, AdmobIntersDelegate, SocketHomeDelegate, SocketActionRequestDelegate, SocketActionResponseDelegate
{    
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet weak var viewMenuHeight: NSLayoutConstraint!
    @IBOutlet weak var viewMenuBox: UIView!

    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var progress: Progress!
    
    @IBOutlet weak var viewHolder: UIView!
    @IBOutlet weak var imageHolder: UIImageView!
    @IBOutlet weak var imageProfile: UIImageView!
    
    @IBOutlet weak var labelEarning: UILabel!
    @IBOutlet weak var labelRanking: UILabel!

    @IBOutlet weak var viewAd: UIView!
    
    @IBOutlet weak var viewBox: UIView!
    @IBOutlet weak var tableRewards: UITableView!
    
    @IBOutlet weak var buttonRankings: UIButton!
    @IBOutlet weak var buttonEarnings: UIButton!
    
    @IBOutlet weak var buttonRankingBottom: NSLayoutConstraint!
    var refreshControl: UIRefreshControl!

    var socketHome: SocketHome! = nil;
    var socketRequest: SocketActionRequest! = nil;
    var socketResponse: SocketActionResponse! = nil;
    
    var requestHash = "";
    
    var homeItems = [RewardTypeItem]();

    var isLoading = false;
    var profileRefresh = false;
    
    var adBanner: AdmobBanner! = nil
    var adInters: AdmobInters! = nil

    static func instance() -> HomeViewController
    {
        let vc = HomeViewController(nibName: "HomeViewController", bundle: nil)
        return vc;
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
        unload()
        
        unrequest();
        
        unresponse();
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = Rewards.colorMain

        viewHolder.rounded();        
        buttonRankings.layerBorder(radius: 20, border: 0, color: .clear);
        buttonEarnings.layerBorder(radius: 20, border: 0, color: .clear);
        
        viewBox.layerBorder(radius: 10, border: 0, color: UIColor.clear)
        
        self.tableRewards.delegate = self
        self.tableRewards.dataSource = self
        
        self.tableRewards.separatorColor = UIColor.clear
        self.tableRewards.register(UINib(nibName: HomeItemCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: HomeItemCell.cellIdentifier)

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: UIControlEvents.valueChanged)
        
        refreshControl.backgroundColor = UIColor.clear;
        refreshControl.tintColor = Rewards.colorMain;
        
        self.tableRewards.addSubview(refreshControl)

        NotificationCenter.default.addObserver(self, selector: #selector(newEvent), name: NSNotification.Name(rawValue: RewardsEvent.EVENT), object: nil);

        adBanner = AdmobBanner(self, viewAd, Rewards.admobIdBanner, 5, 7.5)
        if(Ad.hasSlot(Ad.SLOT_HOME))
        {
            adBanner.prepare();
        }

        adInters = AdmobInters(self, Rewards.admobIdInters, delegate: self);
        if(Ad.isPossible())
        {
            adInters.load();
        }
        
        RewardsAnalytics.logEvent("launch", "");

        Rewards.rewardedAdmob = AdmobRewarded(self, delegate: self)

        load();
        
        Rewards.mainReady = true;
        
        if(Rewards.pushPayload != nil)
        {
            Rewards.processNotification(Rewards.pushPayload);
            
            Rewards.pushPayload = nil;
        }
        
        if(Rewards.feedback != 0 && Rewards.feedback > Prefs.lastFeedback && Prefs.runCount > 5)
        {
            askFeedback();
        }
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
        
        showProfile();
        
        //Rewards.rewardAudience.check();

        Rewards.rewardedAdmob.check();

        //firstTime = false;
        
        tableRewards!.reloadData();
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        isLoading = false;
    }
    
    override func viewWillLayoutSubviews()
    {
        let inset = UI.insets();
        if(inset.bottom > 0)
        {
            viewMenuHeight.constant = inset.top + viewMenuBox.frame.height
        }
        
        buttonRankingBottom.constant = max(15, inset.bottom)
        
        super.viewWillLayoutSubviews();
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return HomeItemCell.cellHeight;
    }
    
    //MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return homeItems.count;
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        return true;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeItemCell.cellIdentifier, for: indexPath as IndexPath) as! HomeItemCell
        
        let data = homeItems[indexPath.row];
        cell.setData(data)
        return cell        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let item = homeItems[indexPath.row]
        
        Ad.count(1);

        if(item.type == "admob")
        {
            Rewards.rewardedAdmob.show(item.reward);
        }
        else if(item.type == "audience")
        {
            //Rewards.rewardAudience.show(item.reward);
        }
        else if(item.type == "points")
        {
            request(item, "daily", DateTime.datetimeLong(DateTime.currentTimeMillis()/1000));
        }
        else if(item.type == "bonus")
        {
            request(item, "bonus", item.data);
        }
        else if(item.type == "invite")
        {
            shareInvite(item);
        }
        else if(item.type == "youtube")
        {
            AppDelegate.pushController(RewardsViewController.instance(item.id, item.title, item.type), animated: true);
        }

        //Ad.count(activity, 1);
    }
    
    //MARK: - Actions
    @IBAction func buttonInfoTap(_ sender: Any)
    {
        AppDelegate.pushController(AboutViewController.instance(), animated: true);
    }

    @IBAction func buttonProfileTap(_ sender: Any)
    {
        AppDelegate.pushController(ProfileEditViewController.instance(), animated: true);
    }

    @IBAction func buttonRankingsTap(_ sender: Any)
    {
        AppDelegate.pushController(RankingsViewController.instance(), animated: true);
    }
    
    @IBAction func buttonEarningsTap(_ sender: Any)
    {
        AppDelegate.pushController(EarningsViewController.instance(), animated: true);
    }
    
    //MARK: - Event
    @objc func newEvent(_ notification: Notification)
    {
        print("newEvent:", notification)
        
        if let info = notification.userInfo
        {
            if let event = info["event"] as? String
            {
                switch (event)
                {
                case RewardsEvent.REWARDED_POINTS:
                    showProfile()
                    break;
                    
                case RewardsEvent.GOOGLE_AD_LOADED:
                    setItemCount("admob", 1)
                    break;
                    
                case RewardsEvent.GOOGLE_AD_CLEARED:
                    setItemCount("admob", 0)
                    break;
                    
                    
                case RewardsEvent.FACEBOOK_AD_LOADED:
                    //adapter.setCount("audience", 1);
                    break;
                    
                case RewardsEvent.FACEBOOK_AD_CLEARED:
                    //adapter.setCount("audience", 0);
                    break;
                    
                case RewardsEvent.PROFILE_CHANGED:
                    showProfile();
                    break;
                default:
                    break;
                }
            }
        }
    }
    
    //MARK: - Funcs
    func setItemCount(_ type: String, _ count: Int)
    {
        var index = 0;
        for item in homeItems
        {
            if(item.type == type)
            {
                item.available = count;
                
                tableRewards.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade);
            }
            index += 1;
        }
    }

    func shareInvite(_ item: RewardTypeItem)
    {
        let text = String(format: item.data.replacingOccurrences(of: "%s", with: "%@"), Prefs.userName);
        
        Rewards.shareText(text)
    }
    
    func showProfile()
    {
        labelUsername.text = Prefs.userName;
        labelRanking.text = Utils.formatRanking(Prefs.userRanking);
        labelEarning.text = Utils.formatPoints(Prefs.userRewards);
        
        let thumb = Prefs.userThumb;
        if(!thumb.isEmpty)
        {
            imageProfile.sd_setImage(with: URL(string: thumb + "?stamp=\(Prefs.profileStamp)"), placeholderImage: nil, options: SDWebImageOptions.refreshCached, completed: { [weak self] (img, err, type, url) in
                if(err == nil && img != nil)
                {
                    self?.imageProfile.isHidden = false;
                    self?.imageHolder.isHidden = true;
                }
                else
                {
                    self?.imageProfile.isHidden = true;
                    self?.imageHolder.isHidden = false;
                }
            })
            profileRefresh = false;
        }
        else
        {
            imageProfile.isHidden = true;
            imageHolder.isHidden = false;
        }
    }
    
    @objc func onRefresh(refreshControl: UIRefreshControl)
    {
        if(isLoading)
        {
            refreshControl.endRefreshing()
            return
        }
        
        load()
    }

    func unload()
    {
        if(socketHome != nil)
        {
            socketHome.setCallback(delegate: nil)
            socketHome.stop()
            socketHome = nil
        }
    }
    
    func load()
    {
        unload();
        
        socketHome = SocketHome(delegate: self);
        socketHome.start()
    }
    
    func homeUI(_ active: Bool)
    {
        isLoading = active;
        
        UI.dimViews(self.viewBox.subviews, active, [progress]);
        
        if(active)
        {
            if(!refreshControl.isRefreshing)
            {
                progress.animate(active)
            }
        }
        else
        {
            progress.animate(active)

            UIView.animate(withDuration: 1.0, animations:
            {
                self.refreshControl.endRefreshing()
            }, completion: nil)
        }
        
    }
    
    //MARK: - SocketHomeDelegate
    func homeStarted()
    {
        homeUI(true)
    }
    
    func homeSuccess(_ data: HomeItem)
    {
        homeUI(false)
        
        showProfile();
        
        Rewards.rewardedAdmob.recheck();

        //Rewards.rewardAudience.check();
        
        isLoading = false;

        for item in data.items
        {
            item.titleAttr   = UI.fromHtml(item.title, color: Rewards.colorTitle, font: Rewards.font.withSize(16));
            item.descAttr    = UI.fromHtml(item.desc, color: Rewards.colorDetail, font: Rewards.font.withSize(12));
        }
        
        homeItems = data.items;

        showProfile()
        tableRewards.reloadData();
    }
    
    func homeError(_ error: String)
    {
        homeUI(false)
        
        UI.toast(self.view, error)
    }
    
    //MARK: - Request
    func unrequest()
    {
        if(socketRequest != nil)
        {
            socketRequest.setCallback(delegate: nil)
            socketRequest.stop()
            socketRequest = nil
        }
    }
    
    func request(_ item: RewardTypeItem, _ action: String, _ info: String)
    {
        unrequest()
        
        requestHash = "";
        
        let actionItem = RewardActionItem();
        actionItem.action = action;
        actionItem.info = info;
        actionItem.data = item.data;
        
        socketRequest = SocketActionRequest(actionItem, delegate: self);
        socketRequest.start(item.reward, action, item.data);
    }
    
    //MARK: - SocketActionRequestDelegate
    func actionRequestStarted()
    {
        UI.showProgress(Strings.reward_request);
    }
    
    func actionRequestSuccess(_ data: Any?, _ hash: String)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [unowned self] in
            
            UI.hideProgress()
            
            self.requestHash = hash;
            
            if let actionItem = data as? RewardActionItem
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: { [unowned self] in
                    self.response(actionItem.action, actionItem.data, actionItem.info);
                });
            }
        })
    }
    
    func actionRequestError(_ error: String)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [unowned self] in

            UI.hideProgress()
            
            self.requestHash = "";
            
            UI.toast(self.view, error);
        })
    }
    
    //MARK: - Response
    func unresponse()
    {
        if(socketResponse != nil)
        {
            socketResponse.setCallback(delegate: nil)
            socketResponse.stop()
            socketResponse = nil
        }
    }
    
    func response(_ action: String, _ data: String, _ info: String)
    {
        unresponse();
        
        if(requestHash.isEmpty)
        {
            UI.toast(self.view, Strings.reward_not_requested);
            return;
        }
        
        socketResponse = SocketActionResponse(delegate: self);
        socketResponse.start(requestHash, action, data, info)
    }
    
    //MARK: - SocketActionResponseDelegate
    func actionResponseStarted()
    {
        UI.showProgress(Strings.reward_claim);
    }
    
    func actionResponseSuccess(_ message: String, _ points: Int, _ action: String)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [unowned self] in
            
            UI.hideProgress()
            
            self.requestHash = "";
            
            UI.toast(self.view, message); //TODO animation and sound!!
        })
    }
    
    func actionResponseError(_ error: String)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [unowned self] in
            
            UI.hideProgress()
            
            self.requestHash = "";
            
            UI.toast(self.view, error);
        })
    }
    
    //MARK: AdmobIntersDelegate
    func onAdInterstLoaded()
    {
        adInters.show()
    }
    
    func onAdInterstFailed()
    {
        
    }
    
    func onAdInterstOpened()
    {
        
    }
    
    func onAdInterstClosed()
    {
        
    }
    
    //MARK: - AdmobRewarded
    func onAdmobRewardClosed()
    {
        if(adInters.state == .loaded)
        {
            adInters.show();
        }
        else if((adInters.state == .failed || adInters.state != .loading) && Ad.isPossible())
        {
            adInters.load();
        }
    }
    
    //MARK: - Feedback
    //MARK: Enjoy
    func askFeedback()
    {
        UI.ask(self, title: "Do you like Nairalance Rewards?", message: "", yes: "Yes!", no: "Not really", accept: { [weak self] in
            
            self?.perform(#selector(self?.askRating), with: nil, afterDelay: 1)
            
            }, decline: { [weak self] in
                
                self?.perform(#selector(self?.askSupport), with: nil, afterDelay: 1)
        })
    }
    
    @objc func askRating()
    {
        Prefs.lastFeedback = (Rewards.feedback);
        
        UI.ask(self, title: "How about a rating on App Store?", message: "", yes: "Ok, sure!", no: "No, thanks", accept: { [weak self] in
            
            Prefs.lastFeedback = Rewards.feedback + 1;
            self?.perform(#selector(self?.openRating), with: nil, afterDelay: 1)
            
        }, decline: nil);
    }
    
    @objc func askSupport()
    {
        Prefs.lastFeedback = (Rewards.feedback);
        
        UI.ask(self, title: "Would you mind giving us some feedback?", message: "", yes: "Ok, sure!", no: "No, thanks", accept: { [weak self] in
            
            Prefs.lastFeedback = (Rewards.feedback + 1);
            self?.perform(#selector(self?.openSupport), with: nil, afterDelay: 1)
            
        }, decline: nil);
    }
    
    @objc func openRating()
    {
        Appirater.rateApp();
    }
    
    @objc func openSupport()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.support(self);
    }

}
