//
//  ProfileJoinViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 03/06/2018.
//  Copyright © 2018 waltech. All rights reserved.
//

import UIKit

class ProfileJoinViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, RoundInputDelegate, KeyboarderDelegate, SearchUsernameDelegate, SocketProfileJoinDelegate
{
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!

    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var imageHolder: UIImageView!
    @IBOutlet weak var buttonAdd: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewBox: UIView!
    @IBOutlet weak var viewHolder: UIView!
    
    @IBOutlet weak var inputUsername: RoundInput!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var inputReferral: RoundInput!
    @IBOutlet weak var progress: Progress!
    
    var keyboarder: Keyboarder!;
    var searchUsername: SearchUsername! = nil;
    var searchReferral: SearchUsername! = nil

    var socketJoin: SocketProfileJoin! = nil;
    
    var userOK = false;
    var refOK = true;
    var isReady = false;
    var username = "";
    var referral = "";
    
    var imageData: Data! = nil;
    
    let pageName = "Create Profile"
    
    deinit
    {
        unjoin();

        if(searchUsername != nil)
        {
            searchUsername.stop()
        }

        if(searchReferral != nil)
        {
            searchReferral.stop()
        }
    }
    
    static func instance() -> ProfileJoinViewController
    {
        let vc = ProfileJoinViewController(nibName: "ProfileJoinViewController", bundle: nil)
        return vc;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        keyboarder = Keyboarder(self.view, scrollView, delegate: self);
        
        self.view.backgroundColor = Rewards.colorMain

        menuBar.shadow();
        menuBar.titleText = pageName

        viewHolder.rounded();        
        buttonAdd.rounded();
        
        inputUsername.prefixText = " "
        inputUsername.delegate = self;
        inputUsername.rounded();
        
        inputReferral.prefixText = " "
        inputReferral.delegate = self;
        inputReferral.rounded();

        refHelp();
        
        buttonNext.rounded();
        
        searchUsername = SearchUsername(inputUsername, true, delegate: self)
        searchReferral = SearchUsername(inputReferral, false, delegate: self)
        
        referralState(false);
        updateNext();

        isReady = true;
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
    
    //MARK: - KeyboarderDelegate
    func keyboarderResign(_ keyboarder: Keyboarder!)
    {
        inputUsername.resign();
        inputReferral.resign();
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
        if(input == inputUsername)
        {
            inputReferral.become();
        }
        else if(input == inputReferral)
        {
            inputReferral.resign()
        }
    }
    
    func inputChanged(_ input: RoundInput!)
    {
        if(!isReady)
        {
            return;
        }
        
        let text = input.inputText!;
        if(input == inputUsername)
        {
            searchUsername.start(text)
        }
        else if(input == inputReferral)
        {
            searchReferral.start(text)
        }
    }
    
    func inputSuffix(_ input: RoundInput!)
    {
        UI.alert(self, "Referral code", "Enter the username of the user that invited you.", response: nil)
    }
    
    
    //MARK: - Actions
    @IBAction func buttonAddTap(_ sender: Any)
    {
        let dropDown = DropDown()

        dropDown.direction = .bottom
        dropDown.anchorView = buttonAdd // UIView or UIBarButtonItem
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.dataSource = ["Take Picture", "Choose from Photos"]
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if(index == 0)
            {
                self.getPhoto(.camera)
            }
            else if(index == 1)
            {
                self.getPhoto(.photoLibrary)
            }
        }
        
        dropDown.show()        
    }

    @IBAction func buttonNextTap(_ sender: Any)
    {
        username = inputUsername.inputText!.trim()
        referral = inputReferral.inputText!.trim()
                
        if(username.isEmpty)
        {
            UI.alert(self, pageName, "Please enter your username!")
        }
        else if(username.length() < 3 || username.length() > 15)
        {
            UI.alert(self, pageName, "Please enter a valid username!")
        }
        else if(!referral.isEmpty && (referral.length() < 3 || username.length() > 15))
        {
            UI.alert(self, pageName, "Please enter a valid referral username!")
        }
        else if(!Server.isOnline())
        {
            UI.alert(self, pageName, ServerData.err_no_connection);
        }
        else
        {
            join();
        }
    }
    
    //MARK: - SearchUsernameDelegate
    func searchDone(_ target: SearchUsername, _ found: Bool)
    {
        if(target == searchUsername)
        {
            userOK = !found;

            inputUsername.setSuffixIcon(userOK ? "ic_done_white_48pt" : "ic_close_white_48pt", userOK ? Rewards.colorActive : Rewards.colorAlert);

            if(inputReferral.inputText!.trim().isEmpty)
            {
                referralState(!found);
            }
        }
        else if(target == searchReferral)
        {
            refOK = found;
    
            inputReferral.setSuffixIcon(refOK ? "ic_done_white_48pt" : "ic_close_white_48pt", refOK ? Rewards.colorActive : Rewards.colorAlert);
        }
        
        updateNext();
    }
    
    func searchFailed(_ target: SearchUsername, _ error: String)
    {
        UI.toast(self.view, error);
        
        if(target == searchUsername)
        {
            userOK = true;
        }
        else if(target == searchReferral)
        {
            refOK = true;
            if(inputReferral.inputText!.trim().isEmpty)
            {
                refHelp()
            }
        }
 
        updateNext()
        
    }
    
    func searchCanceled(_ target: SearchUsername)
    {
        if(target == searchUsername)
        {
            userOK = false;
            referralState(false);
        }
        else if(target == searchReferral)
        {
            refOK = inputReferral.inputText!.trim().isEmpty
            refHelp()
        }
        
        updateNext()
    }
    

    //MARK: - Funcs
    func referralState(_ state: Bool)
    {
        inputReferral.setActive(state);
    }
    
    func refHelp()
    {
        inputReferral.setSuffixIcon("ic_help_white_48pt", UIColor.lightGray);
    }
    
    func isValidUser() -> Bool
    {
        let user = inputUsername.inputText!.trim();
        return (user!.length() > 2 && user!.length() < 15);
    }
    
    func isValidRef() -> Bool
    {
        let ref = inputReferral.inputText!.trim();
        return ref!.isEmpty || (ref!.length() > 2 && ref!.length() < 15);
    }
    
    func updateNext()
    {
        let active = (userOK && isValidUser() && refOK && isValidRef())
        
        buttonNext.setActive(active);
    }
    
    func unjoin()
    {
        if(socketJoin != nil)
        {
            socketJoin.setCallback(delegate: nil)
            socketJoin.stop()
            socketJoin = nil
        }
    }
    
    func join()
    {
        unjoin();
        
        keyboarderResign(nil)
        
        socketJoin = SocketProfileJoin(delegate: self);
        socketJoin.start(username, referral, imageData)
    }
    
    func joinUI(_ active: Bool)
    {
        progress.animate(active)
        UI.dimViews(viewBox.subviews, active, [progress]);
    }
    
    //MARK: - SocketStartDelegate
    func profileJoinStarted()
    {
        joinUI(true)
    }
    
    func profileJoinSuccess(_ message: String)
    {
        joinUI(false)
        
        //UI.toast(self.navigationController!.view, message);
        
        AppDelegate.setControllers([HomeViewController.instance()], animated: false)
    }
    
    func profileJoinError(_ error: String)
    {
        joinUI(false)
        
        if(error.length() > 0)
        {
            UI.alert(self, pageName, error, response: nil);
        }
        else
        {
            UI.toast(self.view, "An error occurred!")
        }
    }
    
    func getPhoto(_ from: UIImagePickerControllerSourceType)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        imagePicker.sourceType = from
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        dismiss(animated: true, completion: nil)
        
        print("picked info", info)
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            ResizeImage.start(pickedImage) { [unowned self] (err, image, data) in
                
                if(err != nil)
                {
                    UI.alert(self, pageName, err ?? "Picture not available!")
                }
                else
                {
                    imageProfile.image = image
                    imageProfile.isHidden = false;
                    imageHolder.isHidden = true;

                    imageData = data;
                }
            }
        }
        else
        {
            UI.alert(self, pageName, "Picture not available!")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }

}


