//
//  EarningsViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 03/06/2018.
//  Copyright © 2018 waltech. All rights reserved.
//

import UIKit
import SDWebImage

class EarningsViewController: AdViewController, UITableViewDelegate, UITableViewDataSource, MenuBarDelegate, SocketEarningsDelegate
{
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var progress: Progress!
    @IBOutlet weak var tableFooter: UITableView!
    @IBOutlet weak var tableEarnings: UITableView!
    @IBOutlet weak var tableFooterHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewFooter: UIView!
    @IBOutlet weak var viewFooterHeight: NSLayoutConstraint!
    @IBOutlet weak var viewFooterBottom: NSLayoutConstraint!
    
    @IBOutlet weak var viewAd: UIView!
    
    var index = 0;
    var last : Double = 0
    var selectedRow = -1;
    var socketEarning: SocketEarnings! = nil;
    
    var isLoaded = false;
    var isLoading = false;
    var isInfinite = true;
    var earnings = [EarningItem]();
    var userEarnItem = EarningItem();

    let pageName = "Earnings";
    
    static func instance() -> EarningsViewController
    {
        let vc = EarningsViewController(nibName: "EarningsViewController", bundle: nil)
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
        self.viewFooter.backgroundColor = Rewards.colorMain

        self.viewFooter.raiseShadow()
        
        menuBar.shadow();
        menuBar.delegate = self;
        menuBar.titleText = pageName
        
        self.tableEarnings.delegate = self
        self.tableEarnings.dataSource = self
        
        self.tableEarnings.separatorColor = UIColor.clear
        self.tableEarnings.register(UINib(nibName: EarningItemCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: EarningItemCell.cellIdentifier)
        
        self.tableFooter.delegate = self
        self.tableFooter.dataSource = self
        
        self.tableFooter.separatorColor = UIColor.clear
        self.tableFooter.register(UINib(nibName: EarningItemCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: EarningItemCell.cellIdentifier)
        
        self.viewFooterHeight.constant = EarningItemCell.cellHeight + 1;
        self.tableFooterHeight.constant = EarningItemCell.cellHeight;
    
        Ad.count(1);

        admobLoadBanner(viewAd, Ad.SLOT_EARNINGS, 5, 5)

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
        
        if(!isLoaded && earnings.count == 0)
        {
            load();
        }
        else
        {
            tableEarnings!.reloadData();
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
        dropDown.dataSource = ["Cash Out", "Reload"]
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if(index == 0)
            {
                AppDelegate.pushController(CashoutViewController.instance(), animated: true)
            }
            else if(index == 1)
            {
                self.reload()
            }
        }
        
        dropDown.show()

    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return EarningItemCell.cellHeight;
    }
    
    //MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(tableView == tableEarnings)
        {
            return earnings.count;
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        if(tableView == tableEarnings)
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
        if(self.shouldLoadNext(indexPath.row, count: earnings.count, last: last, loading: isLoading, infinite: isInfinite))
        {
            //Rewards.countInterstitial(count: 1)
            
            load()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: EarningItemCell.cellIdentifier, for: indexPath as IndexPath) as! EarningItemCell
        
        if(tableView == tableEarnings)
        {
            let data = earnings[indexPath.row];

            cell.labelTitleTop.constant = -9;
            cell.setData(data, indexPath.row == selectedRow)
            cell.labelDesc.isHidden = false;
            cell.viewDivider.isHidden = indexPath.row == (earnings.count - 1)
            return cell
        }
        else
        {
            cell.labelTitleTop.constant = 0;
            cell.labelDesc.isHidden = true;

            cell.setData(userEarnItem, false)
            cell.viewDivider.isHidden = true;
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(tableView == tableEarnings)
        {
            if(indexPath.row == selectedRow)
            {
                selectedRow = -1;
            }
            else
            {
                selectedRow = indexPath.row;
            }
                        
            tableEarnings.reloadData();
        }
    }
    
    //MARK: - Funcs
    func updateFooter()
    {
        userEarnItem.id         = 0;
        userEarnItem.points     = Prefs.userRewards;
        userEarnItem.title      = "Total Earnings (points)"
        userEarnItem.type       = "";
        
        tableFooter.reloadData()
    }
    
    func reload()
    {
        index = 0;
        isInfinite = true;
        
        Ad.count(1);

        load()
    }
    
    func unload()
    {
        if(socketEarning != nil)
        {
            socketEarning.setCallback(delegate: nil)
            socketEarning.stop()
            socketEarning = nil
        }
    }
    
    func load()
    {
        unload();
        
        socketEarning = SocketEarnings(delegate: self);
        socketEarning.start(index, Earning.PAGE_SIZE)
    }
    
    func loadUI(_ active: Bool)
    {
        isLoading = active

        progress.animate(active)
        UI.dimView(tableEarnings, active);
        
        if(active)
        {
            last = DateTime.currentTimeMillis()
        }
        else
        {
            last = 0;
        }
    }
    
    //MARK: - SocketEarningDelegate
    func earningStarted()
    {
        loadUI(true)
    }
    
    func earningSuccess(_ items: [EarningItem], _ index: Int)
    {
        loadUI(false)

        isLoaded = true
        if(index == 0)
        {
            self.earnings.removeAll();
        }
        
        self.earnings.append(contentsOf: items);
        
        isInfinite = items.count == Earning.PAGE_SIZE
        self.index = index + Earning.PAGE_SIZE;

        tableEarnings.reloadData();

        if(index == 0 && self.earnings.count > 0)
        {
            tableEarnings.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    func earningError(_ error: String)
    {
        loadUI(false)
        
        UI.toast(self.view, error)
    }

}
