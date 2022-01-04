//
//  CashoutViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 03/06/2018.
//  Copyright © 2018 waltech. All rights reserved.
//

import UIKit
import SDWebImage

class CashoutViewController: AdViewController, UITableViewDelegate, UITableViewDataSource, RoundInputDelegate, MenuBarDelegate, SocketCashoutRatesDelegate, SocketCashoutRequestDelegate, KeyboarderDelegate
{
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableRates: UITableView!
    @IBOutlet weak var tableFooter: UITableView!
    @IBOutlet weak var tableFooterHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewFooter: UIView!
    @IBOutlet weak var viewFooterHeight: NSLayoutConstraint!
    @IBOutlet weak var viewFooterBottom: NSLayoutConstraint!
    
    @IBOutlet weak var scrollInput: UIScrollView!
    @IBOutlet weak var scrollBox: UIView!
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelInfo: UILabel!

    @IBOutlet weak var inputType: RoundInput!
    @IBOutlet weak var inputPhone: RoundInput!
    @IBOutlet weak var inputName: RoundInput!
    @IBOutlet weak var inputAccount: RoundInput!

    @IBOutlet weak var buttonSubmitTop: NSLayoutConstraint!
    @IBOutlet weak var buttonSubmit: UIButton!
    
    @IBOutlet weak var progress: Progress!
    @IBOutlet weak var viewAd: UIView!
    
    var keyboarder: Keyboarder! = nil;
    
    var socketRates: SocketCashoutRates! = nil;
    var socketRequest: SocketCashoutRequest! = nil;
    
    var isLoaded = false;
    var isLoading = false;

    var rates = [CashoutRateItem]();
    var types = [CashoutTypeItem]();
    
    var activeRate: CashoutRateItem! = nil;
    var userEarnItem = EarningItem();
    var pageInfo = "";
    
    let pageName = "Cash Out";
    
    static func instance() -> CashoutViewController
    {
        let vc = CashoutViewController(nibName: "CashoutViewController", bundle: nil)
        return vc;
    }
    
    deinit
    {
        unload()
        unrequest()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = Rewards.colorMain
        self.viewFooter.backgroundColor = Rewards.colorMain

        self.viewFooter.raiseShadow()
        
        keyboarder = Keyboarder(self.view, scrollInput, delegate: self);

        menuBar.shadow();
        menuBar.delegate = self;
        menuBar.titleText = pageName
        
        self.tableRates.delegate = self
        self.tableRates.dataSource = self
        
        self.tableRates.separatorColor = UIColor.clear
        self.tableRates.register(UINib(nibName: CashoutRateItemCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: CashoutRateItemCell.cellIdentifier)
        
        self.tableFooter.delegate = self
        self.tableFooter.dataSource = self
        
        self.tableFooter.separatorColor = UIColor.clear
        self.tableFooter.register(UINib(nibName: EarningItemCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: EarningItemCell.cellIdentifier)
        
        self.viewFooterHeight.constant = EarningItemCell.cellHeight + 1;
        self.tableFooterHeight.constant = EarningItemCell.cellHeight;
        
        setupList()
        
        Ad.count(1);

        admobLoadBanner(viewAd, Ad.SLOT_CASHOUT, 5, 5)

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

        keyboarder.viewWillAppear();

        updateFooter();
        
        if(!isLoaded && rates.count == 0)
        {
            load();
        }
        else
        {
            tableRates!.reloadData();
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        keyboarder.viewWillDisappear();
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
    
    //MARK: - MenuBarDelegate
    func buttonLeftTapped(_ input: MenuBar!)
    {
        if(scrollInput.isHidden)
        {
            admobShowOrFinish()
        }
        else
        {
            self.scrollInput.isHidden = true;
            self.tableRates.isHidden = false;
            self.viewFooter.isHidden = false;
            menuBar.rightHidden = false;
        }
    }
    
    func buttonRightTapped(_ input: MenuBar!)
    {
        let dropDown = Rewards.dropDown()
        dropDown.anchorView = menuBar.buttonRight // UIView or UIBarButtonItem
        dropDown.dataSource = ["History", "Reload"]
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if(index == 0)
            {
                AppDelegate.pushController(PayoutsViewController.instance(), animated: true)
            }
            else if(index == 1)
            {
                self.load()
            }
        }
        
        dropDown.show()

    }
    
    //MARK: - RoundInputDelegate
    func inputBegin     (_ input: RoundInput!)
    {
    }
    
    func inputEnd       (_ input: RoundInput!)
    {
    
    }
        
    func inputNext      (_ input: RoundInput!)
    {
        if(input == inputPhone)
        {
            inputPhone.resign()
        }
        else if(input == inputName)
        {
            inputAccount.become()
        }
        else if(input == inputAccount)
        {
            inputAccount.resign()
        }
    }
        
    func inputChanged   (_ input: RoundInput!)
    {
        submitState();
    }
        
    func inputSuffix    (_ input: RoundInput!)
    {
    }

    //MARK: - Keyboarder
    func keyboarderResign(_ keyboarder: Keyboarder!)
    {
        inputType.resign();
        inputPhone.resign();
        inputName.resign();
        inputAccount.resign();
    }

    //MARK: - Actions
    @IBAction func buttonSubmitTap(_ sender: Any)
    {
        validate()
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if(tableView == tableRates)
        {
            return CashoutRateItemCell.cellHeight;
        }
        else
        {
            return EarningItemCell.cellHeight;
        }
    }
    
    //MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(tableView == tableRates)
        {
            return rates.count;
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        if(tableView == tableRates)
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
        if(tableView == tableRates)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: CashoutRateItemCell.cellIdentifier, for: indexPath as IndexPath) as! CashoutRateItemCell
            let data = rates[indexPath.row];
            cell.setData(data)
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: EarningItemCell.cellIdentifier, for: indexPath as IndexPath) as! EarningItemCell
            cell.labelTitleTop.constant = 0;
            cell.labelDesc.isHidden = true;

            cell.setData(userEarnItem, false)
            cell.viewDivider.isHidden = true;
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(tableView == tableRates)
        {
            tableView.deselectRow(at: indexPath, animated: false);
            
            activeRate = rates[indexPath.row];

            if(Prefs.userRewards < activeRate.points)
            {
                UI.alert(self, pageName, "You don't have enough points to cash out!");
                return;
            }
            
            setupInput();
        }
    }
    
    //MARK: - Funcs
    func setupList()
    {
        scrollInput.isHidden = true;
        menuBar.rightHidden = false;
        tableRates.isHidden = false;
        viewFooter.isHidden = false;

    }
    
    func setupInput()
    {
        scrollInput.isHidden = false;
        menuBar.rightHidden = true;
        tableRates.isHidden = true;
        viewFooter.isHidden = true;
                
        var providers = [[String : String]]();
        for type in types
        {
            if(type.type == activeRate.type)
            {
                providers.append(["title" : type.provider, "id" : "\(type.id)"]);
            }
        }
        
        labelTitle.text = String(format: "%@ (%@)", Rewards.payoutType(activeRate.type), Utils.formatMoney(activeRate.amount));
        labelInfo.text = pageInfo;
        labelInfo.textColor = Rewards.colorAsh;
        
        inputType.prefixText = " "
        inputType.delegate = self;
        inputType.setItemPicker(providers);
        inputType.rounded();
        
        if(activeRate.type == "bank")
        {
            inputType.inputPlaceholder = "Select bank";
            inputName.inputPlaceholder = "Your account name";
            inputAccount.inputPlaceholder = "Your account number";
            
            inputType.isHidden = false;
            
            inputName.isHidden = false;
            inputAccount.isHidden = false;
            
            inputPhone.isHidden = true;
            
            buttonSubmitTop.constant = 105;
        }
        else if(activeRate.type == "airtime")
        {
            inputType.inputPlaceholder = "Select network";
            inputPhone.inputPlaceholder = "Your phone number";
            
            inputType.isHidden = false;
            
            inputName.isHidden = true;
            inputAccount.isHidden = true;
            
            inputPhone.isHidden = false;
            
            buttonSubmitTop.constant = 30;
        }
        else
        {
            inputType.isHidden = false;
            inputName.isHidden = true
            inputAccount.isHidden = true
            inputPhone.isHidden = true
            
            buttonSubmit.isHidden = true
        }
        
        inputName.prefixText = " "
        inputName.delegate = self;
        inputName.rounded();
        
        inputAccount.prefixText = " "
        inputAccount.delegate = self;
        inputAccount.rounded();
        
        inputPhone.prefixText = "+234"
        inputPhone.delegate = self;
        inputPhone.rounded();
        
        buttonSubmit.setActive(false)
        buttonSubmit.rounded();        
    }
    
    func submitState()
    {
        let active = !inputType.inputText!.trim().isEmpty && (
                !inputPhone.isHidden && Phone.isValid(inputPhone.inputText!.trim()) ||
                (inputPhone.isHidden && !inputName.inputText!.trim().isEmpty && !inputAccount.inputText!.trim().isEmpty)
        )
        
        buttonSubmit.setActive(active)
    }
    
    func updateFooter()
    {
        userEarnItem.id         = 0;
        userEarnItem.points     = Prefs.userRewards;
        userEarnItem.title      = "Total Earnings (points)"
        userEarnItem.type       = "";
        
        tableFooter.reloadData()
    }
    
    //MARK: Rates
    func unload()
    {
        if(socketRates != nil)
        {
            socketRates.setCallback(delegate: nil)
            socketRates.stop()
            socketRates = nil
        }
    }
    
    func load()
    {
        unload();
        
        socketRates = SocketCashoutRates(delegate: self);
        socketRates.start()
    }
    
    func loadUI(_ active: Bool)
    {
        isLoading = active
        
        progress.animate(active)
        UI.dimView(self.tableRates, active, true);
    }
    
    //MARK: - SocketEarningDelegate
    func cashoutRatesStarted()
    {
        loadUI(true)
    }
    
    func cashoutRatesSuccess(_ info: String, _ rates: [CashoutRateItem], _ types: [CashoutTypeItem])
    {

        isLoaded = true
        
        self.pageInfo = info;
        
        self.rates.removeAll();
        self.rates.append(contentsOf: rates);
        
        self.types.removeAll();
        self.types.append(contentsOf: types);
        
        tableRates.reloadData();

        if(self.rates.count > 0)
        {
            tableRates.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
        
        loadUI(false)
    }
    
    func cashoutRatesError(_ error: String)
    {
        loadUI(false)
        
        UI.toast(self.view, error)
    }

    //MARK: - Request
    func validate()
    {
        let pindex = inputType.getPickerIndex();
        if(pindex == -1)
        {
            UI.toast(self.view, inputType.inputPlaceholder!);
        }
        else
        {
            let id = Utils.getInt(inputType.getPickerData("id"));
            if(id == -1)
            {
                UI.toast(self.view, inputType.inputPlaceholder!);
            }
            else if(!inputPhone.isHidden)
            {
                var phone: String = inputPhone.inputText!.trim();
                if(phone.hasPrefix("0"))
                {
                    phone = phone.substr(start: 1);
                }
                
                if(phone.count == 0 )
                {
                    UI.toast(self.view, "Please enter your phone number!");
                    inputPhone.become();
                }
                else if(!Phone.isValid(phone))
                {
                    UI.toast(self.view, "Please enter a valid phone number!");
                    inputPhone.become();
                }
                else
                {
                    request(id, "", "234" + phone);
                }
            }
            else
            {
                let name: String     = inputName.inputText!.trim();
                let account: String  = inputAccount.inputText!.trim();
                
                if(name.count == 0 )
                {
                    UI.toast(self.view, "Please enter your account name!");
                    inputName.become()
                }
                else if(account.length() == 0 )
                {
                    UI.toast(self.view, "Please enter your account number!");
                    inputAccount.become()
                }
                else
                {
                    request(id, name, account);
                }
            }
        }
    }

    func unrequest()
    {
        if(socketRates != nil)
        {
            socketRates.setCallback(delegate: nil)
            socketRates.stop()
            socketRates = nil
        }
    }
    
    func request(_ id: Int, _ name: String, _ account: String)
    {
        unrequest();
        
        socketRequest = SocketCashoutRequest(delegate: self);
        socketRequest.start(id, activeRate.points, name, account);
    }
    
    func requestUI(_ active: Bool)
    {
        isLoading = active
        
        progress.animate(active)
        UI.dimViews(self.scrollBox.subviews, active, [])
    }
    
    //MARK: - SocketEarningDelegate
    func cashoutRequestStarted()
    {
        requestUI(true)
    }
    
    func cashoutRequestSuccess(_ message: String)
    {
        isLoaded = true
        
        requestUI(false)

        UI.alert(self, pageName, message, response: {
            
            AppDelegate.popController(true)
        });
        
    }
    
    func cashoutRequestError(_ error: String, _ action: String)
    {
        requestUI(false)

        if(error.isEmpty)
        {
            return;
        }
        
        UI.alert(self, "Cash Out Error", error, response: {
            if(!action.isEmpty)
            {
                //TODO process action: update profile, email verify, password setup
                if(action == "profile")
                {
                    AppDelegate.pushController(ProfileEditViewController.instance(), animated: true)
                }
            }
        })
    }    
}
