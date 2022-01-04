//
//  PhoneSendViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 02/06/2018.
//  Copyright © 2018 waltech. All rights reserved.
//

import UIKit

class PhoneSendViewController: UIViewController, RoundInputDelegate, KeyboarderDelegate, SocketPhoneSendDelegate
{    
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!

    @IBOutlet weak var viewBox: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var progress: Progress!
    
    @IBOutlet weak var inputPhone: RoundInput!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var buttonCode: UIButton!
    
    let pageName = "Sign in"
    
    var phone = "";
    var type = false;

    var socketSend: SocketPhoneSend! = nil;
    
    var keyboarder: Keyboarder!;

    static func instance() -> PhoneSendViewController
    {
        let vc = PhoneSendViewController(nibName: "PhoneSendViewController", bundle: nil)
        return vc;
    }
    
    deinit
    {
        unsend()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        keyboarder = Keyboarder(self.view, scrollView, delegate: self);
        
        menuBar.shadow();
        menuBar.titleText = pageName
        self.view.backgroundColor = Rewards.colorMain

        inputPhone.delegate = self;
        inputPhone.prefixText = "+234"
        inputPhone.rounded();
        
        //inputPhone.inputText = "8060553174"
        //inputPhone.inputText = "8080262006"
        inputPhone.inputText = Prefs.userPhone.hasPrefix("234") ? Prefs.userPhone.substr(start: 3) : Prefs.userPhone;
        

        buttonNext.rounded();
        //buttonNext.setActive(false);
        buttonNext.setActive(Phone.isValid(inputPhone.inputText!));
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

        buttonCode.isHidden = Prefs.userPhone.isEmpty
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
        }
        
        super.viewWillLayoutSubviews();
    }

    
    //MARK: - RoundInputDelegate
    func inputBegin(_ input: RoundInput!)
    {
        keyboarder.inputBegin(input)
    }
    
    func inputEnd(_ input: RoundInput!)
    {
        keyboarder.inputEnd(input)
    }

    func inputNext(_ input: RoundInput!)
    {
        next();
    }
    
    func inputChanged(_ input: RoundInput!)
    {
        buttonNext.setActive(Phone.isValid(input.inputText!));
    }

    //MARK: - KeyboarderDelegate
    func keyboarderResign(_ keyboarder: Keyboarder!)
    {
        self.inputPhone.resign();
    }
    
    //MARK: - Actions
    @IBAction func buttonCodeTap(_ sender: Any)
    {
        verify(true)
    }
    
    @IBAction func buttonNextTap(_ sender: Any)
    {
        next();
    }
    
    func next()
    {
        phone = inputPhone.inputText!.trim();
        if(phone.hasPrefix("0"))
        {
            phone = phone.substr(start: 1);
        }

        if(phone.isEmpty)
        {
            UI.alert(self, pageName, "Please enter your phone number!")
        }
        else if(!Phone.isValid(phone))
        {
            UI.alert(self, pageName, "Please enter a valid phone number!")
        }
        else if(!Server.isOnline())
        {
            UI.alert(self, pageName, ServerData.err_no_connection);
        }
        else
        {
            phone = "234" + phone;
            
            send();
        }
    }
    
    func verify(_ hasCode: Bool)
    {
        AppDelegate.pushController(PhoneVerifyViewController.instance(hasCode), animated: true)
    }
    
    func unsend()
    {
        if(socketSend != nil)
        {
            socketSend.setCallback(delegate: nil)
            socketSend.stop()
            socketSend = nil
        }
    }
    
    func send()
    {
        unsend();
        
        keyboarderResign(nil)
        
        socketSend = SocketPhoneSend(delegate: self);
        socketSend.start(phone, false)
    }
    
    func sendUI(_ active: Bool)
    {
        progress.animate(active)
        UI.dimViews(viewBox.subviews, active, [progress]);
    }
    
    //MARK: - SocketStartDelegate
    func phoneSendStarted()
    {
        sendUI(true)
    }
    
    func phoneSendSuccess(_ message: String)
    {
        sendUI(false)
        
        Prefs.userPhone = phone;
        
        UI.toast(self.navigationController!.view, message);
        
        verify(false);
    }
    
    func phoneSendError(_ error: String)
    {
        sendUI(false)

        if(error.length() > 0)
        {
            UI.alert(self, pageName, error, response: nil);
        }
        else
        {
            UI.toast(self.view, "An error occurred!")
        }
    }
}
