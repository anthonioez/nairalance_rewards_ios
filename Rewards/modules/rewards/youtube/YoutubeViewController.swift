//
//  YoutubeViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 03/06/2018.
//  Copyright © 2018 waltech. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class YoutubeViewController: AdViewController, UITableViewDelegate, UITableViewDataSource, YTPlayerViewDelegate, MenuBarDelegate, SocketActionsDelegate, SocketActionRequestDelegate, SocketActionResponseDelegate
{
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonShare: UIButton!
    
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var labelTime: UILabel!

    @IBOutlet weak var viewAction: UIView!
    @IBOutlet weak var youtubeView: YTPlayerView!
    
    @IBOutlet weak var progressYoutube: Progress!
    @IBOutlet weak var progressActions: Progress!
    
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var tableActions: UITableView!
    
    @IBOutlet weak var labelAction: UILabel!
    
    @IBOutlet weak var viewAd: UIView!
    @IBOutlet weak var viewAdBottom: NSLayoutConstraint!

    var actionList = [RewardActionItem]();
    var claimList = [String]();
    
    var actionCodes = "";

    var wasSeeked = false;
    var wasPaused = false;
    
    var hasShort = false;
    var hasFull = false;
    
    var isLoading  = false;
    var isVideoLoaded = false;
    var isActionsLoaded = false;
    
    var reward: RewardItem! = nil;
    
    var socketActions: SocketActions! = nil
    var socketRequest: SocketActionRequest! = nil
    var socketResponse: SocketActionResponse! = nil;
    
    var requestHash: String! = nil;
    
    var responseBackOff = 0;
    var shortDuration = -1;
    
    var countMap = [String: Any]()
    var positionLast = -1;
    var firstPlay = true;
    var playTimer : Timer! = nil;
    
    let pageName = "Youtube Rewards"
    
    deinit
    {
        unactions()
        unresponse();
        unrequest()
        untimer();
    }
    
    static func instance(_ item: RewardItem) -> YoutubeViewController
    {
        let vc = YoutubeViewController(nibName: "YoutubeViewController", bundle: nil)
        vc.reward = item;
        return vc;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = Rewards.colorMain

        menuBar.shadow();
        menuBar.titleText = reward.title
        menuBar.delegate = self;

        labelDesc.text = reward.desc;
        buttonShare.rounded();
        
       
        labelProgress.isHidden = true;
        labelAction.isHidden = true;

        tableActions.delegate = self
        tableActions.dataSource = self
        
        tableActions.separatorColor = UIColor.clear
        tableActions.register(UINib(nibName: RewardActionCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: RewardActionCell.cellIdentifier)

        youtubeView.delegate = self;
        
        var params = [AnyHashable : Any]();
        params["controls"] = 1
        params["playsinline"] = 1
        params["autohide"] = 1
        params["showinfo"] = 1
        params["origin"] = "https://www.nairalance.com";
        params["modestbranding"] = 1
        
        progressYoutube.start()
        youtubeView.isHidden = true;
        youtubeView.load(withVideoId: reward.data, playerVars: params)
        
        Ad.count(1);

        admobLoadBanner(viewAd, Ad.SLOT_LISTING, 10, 0)

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
        
        if(isVideoLoaded && !isActionsLoaded && actionList.count == 0)
        {
            actions();
        }
        else
        {
            tableActions.reloadData()
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
        admobShowOrFinish();
    }
    
    func buttonRightTapped(_ input: MenuBar!)
    {
        let dropDown = Rewards.dropDown()
        dropDown.anchorView = menuBar.buttonRight
        dropDown.dataSource = ["Open in Youtube"]
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if(index == 0)
            {
                Ad.count(1);

                Rewards.openUrl(self.reward.link);
            }
        }
        dropDown.show()
    }
    
    //MARK: - YTPlayerViewDelegate
    func playerViewDidBecomeReady(_ playerView: YTPlayerView)
    {
        youtubeView.isHidden = false;
        progressYoutube.stop()
        
        RewardsAnalytics.logEvent("youtube_loaded", reward.data);

        actions();
    }
    
    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor
    {
        return UIColor.black;
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState)
    {
        if(state == .buffering)
        {
            print("buffering:");
            
            firstPlayed();
        }
        else if(state == .playing)
        {
            if(wasPaused || playTimer == nil)
            {
                timer();
                wasPaused = false;
            }
            
            firstPlayed();
        }
        else if(state == .paused)
        {
            //positionLast = Int(playerView.currentTime() * 1000)
            wasPaused = true;
            
            untimer();
            print("paused:", positionLast);
        }
        else if(state == .unstarted)
        {
            print("unstarted:");
        }
        else if(state == .queued)
        {
            print("queued:");
        }
        else if(state == .ended)
        {
            print("ended:");
            
            untimer()
        }
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError)
    {
        UI.toast(self.view, "YouTube error\(error.rawValue) occurred!")
        
        untimer()
    }

    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float)
    {
        //updateCounter()
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return RewardActionCell.cellHeight;
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return actionList.count;
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        return true;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: RewardActionCell.cellIdentifier, for: indexPath as IndexPath) as! RewardActionCell
        
        let data = actionList[indexPath.row];
        cell.setData(data);
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
    
    //MARK: - Actions
    @IBAction func buttonShareTap(_ sender: Any)
    {
        Ad.count(1);

        //let title = String(format: "%@", reward.title);   //Youtube Video:
        let message = String(format:"%@ %@", reward.desc, reward.link);
        Rewards.shareText(message);
    }
    

    //MARK: - Funcs
    func firstPlayed()
    {
        if(firstPlay)
        {
            positionLast = 0
            firstPlay = false;
            request()
        }
    }
    
    func canRespond(_ action: String) -> Bool
    {
        return (requestHash != nil && !wasSeeked && !isLoading && !claimList.contains(action));
    }
    
    func updateCounter()
    {
        let position = Int(youtubeView.currentTime() * 1000);
        let posText = DateTime.formatDurationMillis(position);
        
        labelTime.isHidden = false;
        labelTime.text = posText;
        
        countMap[posText] = true;
        
        //print("count:", positionLast, " >> ", position, "diff:", (position - positionLast));
        
        if(positionLast != -1 && abs(position - positionLast) > 1000 && !wasSeeked && actionList.count > 0 && claimList.count != actionList.count)
        {
            wasSeeked = true;
            
            UI.toast(self.view, "Seek not allowed, reward points will not be awarded!");
        }
        
        positionLast = position;
        
        if(shortDuration != -1 && position >= (shortDuration * 1000) && countMap.count > (shortDuration / 2) )
        {
            if(hasShort && canRespond("short") )
            {
                if(responseBackOff <= 0)
                {
                    response("short");
                }
                else
                {
                    responseBackOff-=1;
                }
            }
        }
    }

    //MARK: - Action
    func unactions()
    {
        if(socketActions != nil)
        {
            socketActions.setCallback(delegate: nil)
            socketActions.stop()
            socketActions = nil
        }
    }
    
    func actions()
    {
        unactions();
        
        socketActions = SocketActions(delegate: self);
        socketActions.start(reward.id)
    }
    
    func actionUI(_ active: Bool)
    {
        isLoading = active;

        labelProgress.text = "Loading rewards..."
        labelProgress.isHidden = !active
        progressActions.animate(active)
        UI.dimViews(viewAction.subviews, active, [labelProgress, progressActions]);
    }
    
    //MARK: - SocketActionsDelegate
    func actionStarted()
    {
        actionUI(true)
    }
    
    func actionSuccess(_ items: [RewardActionItem])
    {
        actionUI(false)

        actionList.removeAll()
        
        hasShort = false;
        hasFull = false;
        
        for item in items
        {
            if(item.claimed)
            {
                claimList.append(item.action); //continue;
            }
            
            if(item.action == ("short"))
            {
                shortDuration = Utils.getInt(item.data);
                hasShort = true;
            }
            else if(item.action == "full")
            {
                hasFull = true;
            }
            
            actionCodes += (actionCodes.trim().count == 0 ? "" : ",");
            actionCodes += item.action;
            
            actionList.append(item);
        }
        
        tableActions.reloadData()
    
        labelAction.isHidden = false;
        labelAction.text = (actionList.count > 0 ? "Available rewards:" : "No rewards available.");
        
        isLoading = false;
        isActionsLoaded = true;
    }
    
    func actionError(_ error: String)
    {
        actionUI(false)
        
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
    
    func request()
    {
        unrequest();
        
        if(claimList.count == actionList.count)
        {
            return;
        }
        
        requestHash = nil;

        socketRequest = SocketActionRequest(nil, delegate: self);
        socketRequest.start(reward.id, actionCodes, reward.data)
    }
    
    func requestUI(_ active: Bool)
    {
        isLoading = active;

        labelProgress.text = "Sending reward request..."
        labelProgress.isHidden = !active
        progressActions.animate(active)
        UI.dimViews(viewAction.subviews, active, [labelProgress, progressActions]);
    }
    
    //MARK: - SocketActionRequestDelegate
    func actionRequestStarted()
    {
        requestUI(true)
    }
    
    func actionRequestSuccess(_ data: Any?, _ hash: String)
    {
        requestUI(false)

        requestHash = hash;
    }
    
    func actionRequestError(_ error: String)
    {
        requestUI(false)
        
        requestHash = nil;
        
        UI.toast(self.view, error)
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
    
    func response(_ action: String)
    {
        unresponse();
        
        if(requestHash == nil || requestHash!.isEmpty)
        {
            UI.toast(self.view, Strings.reward_not_requested);
            return;
        }

        socketResponse = SocketActionResponse(delegate: self);
        socketResponse.start(requestHash, actionCodes, reward.data, "")
    }
    
    func responseUI(_ active: Bool)
    {
        isLoading = active;
        
        labelProgress.text = Strings.reward_claim
        labelProgress.isHidden = !active
        progressActions.animate(active)
        UI.dimViews(viewAction.subviews, active, [labelProgress, progressActions]);
    }
    
    //MARK: - SocketActionResponseDelegate
    func actionResponseStarted()
    {
        responseUI(true)
    }
    
    func actionResponseSuccess(_ message: String, _ points: Int, _ action: String)
    {        
        responseUI(false)
        
        claimList.append(action);
        
        UI.toast(self.view, message); //TODO animation and sound!!
    }
    
    func actionResponseError(_ error: String)
    {
        responseUI(false)
        
        UI.toast(self.view, error)
        
        responseBackOff = 15
    }
    
    //MARK: - Timer
    func timer()
    {
        untimer();
        
        //print("timer")
       
        //positionLast = Int(youtubeView.currentTime() * 1000);
        updateCounter();
        
        playTimer = Timer.scheduledTimer(timeInterval: 0.50, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true);
    }
    
    func untimer()
    {
        print("untimer")
        
        if(playTimer != nil)
        {
            playTimer.invalidate();
            playTimer = nil;
        }
    }
    
    @objc func timerUpdate()
    {
        print("timerUpdate")
        
        DispatchQueue.main.async(execute: {
            self.updateCounter();
        })
    }
    
}



