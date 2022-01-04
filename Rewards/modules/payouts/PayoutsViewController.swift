//
//  PayoutsViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 03/06/2018.
//  Copyright © 2018 waltech. All rights reserved.
//

import UIKit
import SDWebImage

class PayoutsViewController: AdViewController, UITableViewDelegate, UITableViewDataSource, MenuBarDelegate, SocketPayoutListDelegate, SocketPayoutCancelDelegate
{
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var progress: Progress!
    @IBOutlet weak var tableFooter: UITableView!
    @IBOutlet weak var tablePayouts: UITableView!
    @IBOutlet weak var tableFooterHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewFooter: UIView!
    @IBOutlet weak var viewFooterHeight: NSLayoutConstraint!
    @IBOutlet weak var viewFooterBottom: NSLayoutConstraint!
    @IBOutlet weak var viewAd: UIView!

    var index = 0;
    var last : Double = 0

    var socketList: SocketPayoutList! = nil;
    var socketCancel: SocketPayoutCancel! = nil;
    
    var isLoaded = false;
    var isLoading = false;
    var isInfinite = true;
    
    var payouts = [PayoutItem]();
    var userPayoutItem = PayoutItem();

    let pageName = "Cash Out History";
    
    static func instance() -> PayoutsViewController
    {
        let vc = PayoutsViewController(nibName: "PayoutsViewController", bundle: nil)
        return vc;
    }
    
    deinit
    {
        unload()
        uncancel();
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = Rewards.colorMain
        self.viewFooter.backgroundColor = Rewards.colorMain

        self.viewFooter.raiseShadow()
        
        menuBar.shadow();
        menuBar.delegate = self;
        menuBar.titleText = pageName
        
        self.tablePayouts.delegate = self
        self.tablePayouts.dataSource = self
        
        self.tablePayouts.separatorColor = UIColor.clear
        self.tablePayouts.register(UINib(nibName: PayoutItemCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: PayoutItemCell.cellIdentifier)
        
        self.tableFooter.delegate = self
        self.tableFooter.dataSource = self
        
        self.tableFooter.separatorColor = UIColor.clear
        self.tableFooter.register(UINib(nibName: PayoutItemCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: PayoutItemCell.cellIdentifier)
        
        self.viewFooterHeight.constant = PayoutItemCell.cellHeightShort + 1;
        self.tableFooterHeight.constant = PayoutItemCell.cellHeightShort;
        
        userPayoutItem.title      = "Total Payouts"
        
        updateFooter()
        
        Ad.count(1);
        
        admobLoadBanner(viewAd, Ad.SLOT_PAYOUTS, 5, 5)
        
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
        
        updateFooter();
        
        if(!isLoaded && payouts.count == 0)
        {
            load();
        }
        else
        {
            tablePayouts!.reloadData();
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
            
            //viewFooterBottom.constant = inset.bottom;
        }
        
        viewFooterHeight.constant = PayoutItemCell.cellHeightShort + (inset.bottom / 2) + 1
        
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
        dropDown.anchorView = menuBar.buttonRight 
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
        if(tableView == tablePayouts)
        {
            return PayoutItemCell.cellHeight;
        }
        else
        {
            return PayoutItemCell.cellHeightShort;
        }
    }
    
    //MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(tableView == tablePayouts)
        {
            return payouts.count;
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        if(tableView == tablePayouts)
        {
            return true;
        }
        else
        {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if(self.shouldLoadNext(indexPath.row, count: payouts.count, last: last, loading: isLoading, infinite: isInfinite))
        {
            //Rewards.countInterstitial(count: 1)
            
            load()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if(tableView == tablePayouts)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: PayoutItemCell.cellIdentifier, for: indexPath as IndexPath) as! PayoutItemCell
            
            let data = payouts[indexPath.row];

            cell.labelDesc.isHidden = false;
            cell.labelStamp.isHidden = false;
            cell.labelStatus.isHidden = false;
            cell.labelDescVertical.constant = 0;

            cell.setData(data)
            cell.viewDivider.isHidden = indexPath.row == (payouts.count - 1)
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: PayoutItemCell.cellIdentifier, for: indexPath as IndexPath) as! PayoutItemCell
            
            cell.labelDesc.isHidden = true;
            cell.labelStamp.isHidden = true;
            cell.labelStatus.isHidden = true;
            cell.labelDescVertical.constant = 7;
            
            cell.setData(userPayoutItem)
            cell.viewDivider.isHidden = true;
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath)
        let data = payouts[indexPath.row];

        if(data.status != 0) { return }
        
        let dropDown = Rewards.dropDown()
        dropDown.anchorView = cell
        dropDown.bottomOffset = CGPoint(x: (dropDown.anchorView?.plainView.bounds.width)! - 140, y: (dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.dataSource = ["Cancel Request"]
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if(index == 0)
            {
                self.cancelAsk(data.id)
            }
        }
        
        dropDown.show()
        
        self.tablePayouts.deselectRow(at: indexPath, animated: false);
    }
    
    //MARK: - Funcs
    func updateFooter()
    {
        tableFooter.reloadData()
    }
    
    //MARK: - List
    func reload()
    {
        index = 0;
        isInfinite = true;
        
        load()
    }
    
    func unload()
    {
        if(socketList != nil)
        {
            socketList.setCallback(delegate: nil)
            socketList.stop()
            socketList = nil
        }
    }
    
    func load()
    {
        unload();
        
        socketList = SocketPayoutList(delegate: self);
        socketList.start(index, Payout.PAGE_SIZE)
    }
    
    func loadUI(_ active: Bool)
    {
        isLoading = active

        progress.animate(active)
        UI.dimView(tablePayouts, active);
        
        if(active)
        {
            last = DateTime.currentTimeMillis()
        }
        else
        {
            last = 0;
        }
    }
    
    //MARK: - SocketPayoutDelegate
    func payoutListStarted()
    {
        loadUI(true)
    }
    
    func payoutListSuccess(_ items: [PayoutItem], _ index: Int, _ total: Double)
    {
        loadUI(false)

        userPayoutItem.amount = total;

        isLoaded = true
        if(index == 0)
        {
            self.payouts.removeAll();
        }
        
        self.payouts.append(contentsOf: items);
        
        isInfinite = items.count == Payout.PAGE_SIZE
        self.index = index + Payout.PAGE_SIZE;

        tablePayouts.reloadData();
        
        
        if(index == 0 && self.payouts.count > 0)
        {
            tablePayouts.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }

        updateFooter()
    }
    
    func payoutListError(_ error: String)
    {
        loadUI(false)
        
        UI.toast(self.view, error)
    }

    //MARK: - Cancel
    func cancelAsk(_ id: Int)
    {
        UI.confirm(self, pageName, "Are you sure you want to cancel this cash out request?", accept: { [unowned self] in
            
            self.cancel(id)
            
        }, decline: nil)
    }

    func uncancel()
    {
        if(socketCancel != nil)
        {
            socketCancel.setCallback(delegate: nil)
            socketCancel.stop()
            socketCancel = nil
        }
    }
    
    func cancel(_ id: Int)
    {
        uncancel();
        
        socketCancel = SocketPayoutCancel(delegate: self);
        socketCancel.start(id)
    }
    
    func cancelUI(_ active: Bool)
    {
        isLoading = active
        
        progress.animate(active)
        UI.dimView(tablePayouts, active);
    }
    
    //MARK: - SocketPayoutCancelDelegate
    func payoutCancelStarted()
    {
        cancelUI(true)
    }
    
    func payoutCancelSuccess(_ message: String)
    {
        cancelUI(false)
        
        UI.alert(self, pageName, message, response: { [unowned self] in
            self.reload()
        })
    }
    
    func payoutCancelError(_ error: String)
    {
        cancelUI(false)
        
        UI.toast(self.view, error)
    }
}
