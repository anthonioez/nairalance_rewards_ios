//
//  PhoneVerifyViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 02/06/2018.
//  Copyright © 2018 waltech. All rights reserved.
//

import UIKit
import MessageUI

class PhoneVerifyViewController: UIViewController, DigitInputDelegate, SocketPhoneSendDelegate, SocketPhoneVerifyDelegate, KeyboarderDelegate, MenuBarDelegate, MFMessageComposeViewControllerDelegate
{    
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewBox: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var progress: Progress!
    
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var inputCode: DigitInput!

    @IBOutlet weak var buttonCall: UIButton!
    
    @IBOutlet weak var buttonNext: UIButton!
    
    var timer: Timer! = nil;
    var socketSend: SocketPhoneSend! = nil;
    var socketVerify: SocketPhoneVerify! = nil;
    
    var code = "";
    var pageName = "Verification"
    var keyboarder: Keyboarder!;

    let countMax = 10;
    let countStep = 1;
    var countTotal = 10;
    var stage = "text"
    var hasCode = false;

    static func instance(_ hasCode: Bool) -> PhoneVerifyViewController
    {
        let vc = PhoneVerifyViewController(nibName: "PhoneVerifyViewController", bundle: nil)
        vc.hasCode = hasCode;
        return vc;
    }
    
    deinit
    {
        unsend()
        unverify()
        untimer();
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        keyboarder = Keyboarder(self.view, scrollView, delegate: self);
        
        menuBar.delegate = self;
        menuBar.titleText = pageName;
        menuBar.shadow();
        
        inputCode.delegate = self;
        
        self.view.backgroundColor = Rewards.colorMain

        labelTitle.text = "Please enter the verification code sent to +\(Prefs.userPhone)"
        
        buttonNext.rounded();

        if(hasCode)
        {
            labelStatus.isHidden = true;
            buttonCall.isHidden = true;
        }
        else
        {
            timerStart();
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
        
        keyboarder.viewWillAppear();
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

    //MARK: - DigitInputDelegate
    public func inputBegin(_ input: DigitInput!)
    {
        keyboarder.inputBegin(input)
    }
    
    public func inputEnd(_ input: DigitInput!)
    {
        keyboarder.inputEnd(input)
    }

    func inputChanged(_ input: DigitInput!)
    {
        let length = input.input()!.length()
        buttonNext.setActive(length >= 4);
        
        untimer()
        showOption();
        
        buttonCall.isHidden = length != 0;
    }
    
    //MARK: - KeyboarderDelegate
    func keyboarderResign(_ keyboarder: Keyboarder!)
    {
        self.inputCode.resign();
    }
    
    //MARK: - MenuBarDelegate
    func buttonLeftTapped   (_ input: MenuBar!)
    {
        AppDelegate.popController(true);
    }

    func buttonRightTapped  (_ input: MenuBar!)
    {
        
    }

    //MARK: - Actions
    @IBAction func buttonCallTap(_ sender: Any)
    {
        if(stage == "call")
        {
            send();
        }
        else if(stage == "manual")
        {
            UI.confirm(self, "Text Verification", "Text 'VERIFY' to \(Rewards.appPhone) to get a verification code.", accept: {
                self.sendSMS()
            }, decline: {
                
            })
        }
    }
    
    @IBAction func buttonNextTap(_ sender: Any)
    {
        next();
    }
    
    //MARK: - Funcs
    func untimer()
    {
        if(timer != nil)
        {
            timer.invalidate();
            timer = nil;
        }
    }
    
    func timerStart()
    {
        countTotal = 30;

        buttonCall.isHidden = true;
        buttonCall.setTitle("", for: .normal)

        labelStatus.isHidden = false;
        labelStatus.text = " ";

        timer = Timer.scheduledTimer(timeInterval: TimeInterval(countStep), target: self, selector: #selector(timerText), userInfo: nil, repeats: true);
    }
    
    @objc func timerText()
    {
        countTotal -= countStep;
        if(countTotal <= 0)
        {
            untimer()
            changeOption();
            return;
        }
        else
        {
            DispatchQueue.main.async {
                
                if(self.stage == "text")
                {
                    self.labelStatus.text = String(format: "You will receive a text in %@", DateTime.formatDuration(self.countTotal / self.countStep));
                }
                else if(self.stage == "call")
                {
                    self.labelStatus.text = String(format: "You will receive a call in %@", DateTime.formatDuration(self.countTotal / self.countStep));
                }
                else
                {
                    self.labelStatus.text = "";
                }

                //self.labelStatus.text = String(format: "You will receive a \(self.stage) in %d", self.countTotal / self.countStep);
            }
        }
    }
    
    func showOption()
    {
        if(stage == "text")
        {
            buttonCall.isHidden = true;
            labelStatus.isHidden = true;
            buttonCall.setTitle("", for: .normal);
            return;
        }
        else if(stage == "call")
        {
            buttonCall.setTitle("Call me instead", for: .normal);
        }
        else if(stage == "manual")
        {
            buttonCall.setTitle("Try manual", for: .normal);
        }

        labelStatus.isHidden = true;
        buttonCall.isHidden = false;
    }
    
    func changeOption()
    {
        if(stage == "text")
        {
            stage = "call";
            showOption()
            return
        }
        else if(stage == "call")
        {
            stage = "manual";
            showOption()
            return
        }

        showOption()
    }
    
    func next()
    {
        //AppDelegate.setControllers([ProfileJoinViewController.instance()], animated: false);
        
        code = inputCode.input()!;
        if(code.isEmpty || code.length() != 4)
        {
            UI.alert(self, pageName, "Please enter the 4 digit code sent to you!")
        }
        else if(!Server.isOnline())
        {
            UI.alert(self, pageName, ServerData.err_no_connection);
        }
        else
        {
            verify();
        }
    }
    
    func unverify()
    {
        if(socketVerify != nil)
        {
            socketVerify.setCallback(delegate: nil)
            socketVerify.stop()
            socketVerify = nil
        }
    }
    
    func verify()
    {
        untimer()
        unverify();
        
        keyboarderResign(nil)
        
        socketVerify = SocketPhoneVerify(delegate: self);
        socketVerify.start(Prefs.userPhone, code)
    }
    
    func verifyUI(_ active: Bool)
    {
        progress.animate(active)
        UI.dimViews(viewBox.subviews, active, [progress]);
    }
    
    //MARK: - SocketStartDelegate
    func phoneVerifyStarted()
    {
        verifyUI(true)
    }
    
    func phoneVerifySuccess(_ message: String)
    {
        verifyUI(false)

        //UI.toast(self.navigationController!.view, message);

        if(Prefs.userName.isEmpty)
        {
            AppDelegate.setControllers([ProfileJoinViewController.instance()], animated: true);
        }
        else
        {
            AppDelegate.setControllers([HomeViewController.instance()], animated: true);
        }
    }
    
    func phoneVerifyError(_ error: String)
    {
        verifyUI(false)
        
        if(error.length() > 0)
        {
            UI.alert(self, pageName, error, response: nil);
        }
        else
        {
            UI.toast(self.view, "An error occurred!")
        }
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
        socketSend.start(Prefs.userPhone, true)
    }
    
    func sendUI(_ active: Bool)
    {
        progress.animate(active)
        UI.dimViews(viewBox.subviews, active, [progress]);
    }
    
    //MARK: - SocketPhoneSendDelegate
    func phoneSendStarted()
    {
        sendUI(true)
    }
    
    func phoneSendSuccess(_ message: String)
    {
        sendUI(false)
        
        timerStart();
        
        UI.toast(self.navigationController!.view, message);
    }
    
    func phoneSendError(_ error: String)
    {
        sendUI(false)
        
        showOption();
        
        if(error.length() > 0)
        {
            UI.alert(self, pageName, error, response: nil);
        }
        else
        {
            UI.toast(self.view, "An error occurred!")
        }
    }

    //MARK: - SMS
    func sendSMS()
    {
        if (MFMessageComposeViewController.canSendText())
        {
            let controller = MFMessageComposeViewController()
            controller.body = "VERIFY"
            controller.recipients = [Rewards.appPhone];
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else
        {
            UI.alert(self, "Error", "Device cannot send SMS!")
            //UI.toast(self.view, "Device cannot send SMS!")
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult)
    {
        self.dismiss(animated: true, completion: nil)
    }}
