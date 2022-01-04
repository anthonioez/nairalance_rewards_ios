//
//  ProfileEditViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 03/06/2018.
//  Copyright © 2018 waltech. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileEditViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MenuBarDelegate, RoundInputDelegate, DigitInputDelegate, KeyboarderDelegate, SocketProfileGetDelegate, SocketProfileSetDelegate, SocketProfileEmailDelegate, SocketProfileVerifyDelegate
{
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var inputEmail: RoundInput!
    @IBOutlet weak var inputPassword: RoundInput!
    @IBOutlet weak var inputPassword2: RoundInput!
    @IBOutlet weak var buttonEmail: UIButton!
    
    @IBOutlet weak var viewVerify: UIView!
    @IBOutlet weak var labelVerify: UILabel!
    @IBOutlet weak var inputCode: DigitInput!
    @IBOutlet weak var buttonVerify: UIButton!
    
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var imageHolder: UIImageView!
    @IBOutlet weak var buttonAdd: UIButton!
    @IBOutlet weak var viewHolder: UIView!
    
    @IBOutlet weak var inputUsername: RoundInput!
    @IBOutlet weak var inputPhone: RoundInput!
    @IBOutlet weak var inputGender: RoundInput!
    @IBOutlet weak var inputCity: RoundInput!
    @IBOutlet weak var inputState: RoundInput!

    @IBOutlet weak var buttonProfile: UIButton!
    @IBOutlet weak var progress: Progress!
    
    var keyboarder: Keyboarder!;

    var socketSet: SocketProfileSet! = nil;
    var socketGet: SocketProfileGet! = nil;
    var socketEmail: SocketProfileEmail! = nil;
    var socketVerify: SocketProfileVerify! = nil;
    
    var imageData: Data! = nil;
    
    var pageName = "Edit Profile"
    
    deinit
    {
        unget();
        unset();
        unemail()
        unverify()
    }
    
    static func instance() -> ProfileEditViewController
    {
        let vc = ProfileEditViewController(nibName: "ProfileEditViewController", bundle: nil)
        return vc;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        keyboarder = Keyboarder(self.view, scrollView, delegate: self);
        
        self.view.backgroundColor = Rewards.colorMain

        menuBar.shadow();
        menuBar.delegate = self;
        menuBar.titleText = pageName

        viewHolder.rounded();        
        buttonAdd.rounded();
        
        setupEmail();
        setupVerify()
        setupProfile();

        showSection(nil);
        
        get()
        
        Ad.count(1);
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
    
    //MARK: - MenuBarDelegate
    func buttonLeftTapped(_ input: MenuBar!)
    {
        AppDelegate.popController(true)
    }
    
    func buttonRightTapped(_ input: MenuBar!)
    {
        
    }
    
    //MARK: - KeyboarderDelegate
    func keyboarderResign(_ keyboarder: Keyboarder!)
    {
        if(!viewEmail.isHidden)
        {
            inputEmail.resign()
            inputPassword.resign()
            inputPassword2.resign()
        }
        
        if(!viewVerify.isHidden)
        {
            inputCode.resign()
        }
        
        if(!viewProfile.isHidden)
        {
            inputUsername.resign();
            inputPhone.resign();
            inputGender.resign();
            inputCity.resign();
            inputState.resign();
        }
    }
    
    //MARK: - DigitInputDelegate
    func inputBegin(_ input: DigitInput!)
    {
        keyboarder.inputBegin(input)
    }
    
    func inputEnd(_ input: DigitInput!)
    {
        keyboarder.inputEnd(input)
    }
    
    func inputChanged(_ input: DigitInput!)
    {
        updateSubmit()
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
        if(!viewEmail.isHidden)
        {
            if(input == inputEmail)
            {
                inputPassword.become()
            }
            else if(input == inputPassword)
            {
                inputPassword2.become()
            }
            else if(input == inputPassword2)
            {
                buttonEmailTap("")
            }
        }
        else if(!viewVerify.isHidden)
        {
            if(input == inputCode)
            {
                buttonVerifyTap("")
            }
        }
    }
    
    func inputChanged(_ input: RoundInput!)
    {
        updateSubmit()
    }
    
    func inputSuffix(_ input: RoundInput!)
    {
    }
    
    //MARK: - Actions
    @IBAction func buttonEmailTap(_ sender: Any)
    {
        let email: String  = inputEmail.inputText!.trim()
        let password: String  = inputPassword.inputText!.trim()
        let password2: String  = inputPassword2.inputText!.trim()

        if(email.isEmpty)
        {
            UI.alert(self, pageName, "Please enter your email address!")
        }
        else if(email.length() < 4 || !Utils.isValidEmail(email))
        {
            UI.alert(self, pageName, "Please enter a valid email address!");
        }
        else if(password.length() < 8)
        {
            UI.alert(self, pageName, "Please enter a valid password, at least 8 characters!");
        }
        else if(password2.length() < 8)
        {
            UI.alert(self, pageName, "Please re-enter a valid password, at least 8 characters!");
        }
        else if(password != password2)
        {
            UI.alert(self, pageName, "Passwords not the same, please re-enter a valid password, at least 8 characters!");
        }
        else if(!Server.isOnline())
        {
            UI.alert(self, pageName, ServerData.err_no_connection);
        }
        else
        {
            self.email(email, password);
        }
    }
    
    @IBAction func buttonVerifyTap(_ sender: Any)
    {
        let code: String  = inputCode.inputText!.trim()
        
        if(code.isEmpty || code.length() != 4)
        {
            UI.alert(self, pageName, "Please enter the 4 digit code sent to your email address!")
        }
        else if(!Server.isOnline())
        {
            UI.alert(self, pageName, ServerData.err_no_connection);
        }
        else
        {
            self.verify(Prefs.userEmail, code);
        }
    }
    
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

    @IBAction func buttonProfileTap(_ sender: Any) 
    {
        let username: String  = inputUsername.inputText!.trim()
        let gender: String  = inputGender.inputText!.trim()
        let city: String    = inputCity.inputText!.trim()
        let state: String   = inputState.inputText!.trim()

        if(gender.isEmpty)
        {
            UI.alert(self, pageName, "Please select your gender!")
        }
        else if(city.isEmpty)
        {
            UI.alert(self, pageName, "Please enter your city!")
        }
        else if(city.length() > 20)
        {
            UI.alert(self, pageName, "Please enter a valid city, maximum of 20 characters!")
        }
        else if(state.isEmpty)
        {
            UI.alert(self, pageName, "Please select your state!")
        }
        else if(!Server.isOnline())
        {
            UI.alert(self, pageName, ServerData.err_no_connection);
        }
        else
        {
            set(username, gender == "Male" ? 1 : 2, city, state);
        }
    }
    
    
    //MARK: - Funcs
    func setupEmail()
    {
        inputEmail.prefixText = " "
        inputEmail.delegate = self;
        inputEmail.rounded();
        
        inputPassword.prefixText = " "
        inputPassword.delegate = self;
        inputPassword.rounded();
        
        inputPassword2.prefixText = " "
        inputPassword2.delegate = self;
        inputPassword2.rounded();
        
        buttonEmail.rounded();
    }
    
    func setupVerify()
    {
        labelVerify.text = "Please enter the verification code sent to your email address"  
        inputCode.delegate = self;
        
        buttonVerify.rounded();
    }
    
    func setupProfile()
    {
        inputUsername.prefixText = " "
        inputUsername.delegate = self;
        inputUsername.rounded();
        inputUsername.setActive(false)
        
        inputPhone.prefixText = " "
        inputPhone.delegate = self;
        inputPhone.rounded();
        inputPhone.setActive(false)
        
        inputGender.prefixText = " "
        inputGender.delegate = self;
        inputGender.setItemPicker(getGenders());
        inputGender.rounded();
        
        inputCity.prefixText = " "
        inputCity.delegate = self;
        inputCity.rounded();
        
        inputState.prefixText = " "
        inputState.delegate = self;
        inputState.rounded();
        inputState.setItemPicker(getStates());
        
        buttonProfile.rounded();
    }
    
    func showSection(_ view: UIView!)
    {
        for subview in scrollView.subviews
        {
            subview.isHidden = (subview != view);
        }
        
        if(view == viewEmail)
        {
            pageName = "Setup Account"
        }
        else if(view == viewVerify)
        {
            pageName = "Verify Email Address"
        }
        else //if(view == viewProfile)
        {
            pageName = "Edit Profile"
        }
        
        menuBar.titleText = pageName;
    }
    
    func updateSubmit()
    {
        var active = false;
        if(!viewEmail.isHidden)
        {
            active = !inputEmail.inputText!.trim().isEmpty &&
                !inputPassword.inputText!.trim().isEmpty &&
                !inputPassword2.inputText!.trim().isEmpty

            buttonEmail.setActive(active);
        }
        
        if(!viewVerify.isHidden)
        {
            active = inputCode.inputText!.trim().length() == 4
            
            buttonVerify.setActive(active);
        }
        
        if(!viewProfile.isHidden)
        {
            active = !inputGender.inputText!.trim().isEmpty &&
                !inputCity.inputText!.trim().isEmpty &&
                !inputState.inputText!.trim().isEmpty
            
            buttonProfile.setActive(active);
        }
    }
    
    func profileUI(_ active: Bool)
    {
        progress.animate(active)
        UI.dimViews(scrollView.subviews, active, [progress, inputEmail, inputPassword, inputPassword2, inputUsername, inputPhone]);
    }
    
    //MARK: - Get
    func unget()
    {
        if(socketGet != nil)
        {
            socketGet.setCallback(delegate: nil)
            socketGet.stop()
            socketGet = nil
        }
    }
    
    func get()
    {
        unget();
        
        keyboarderResign(nil)
        
        socketGet = SocketProfileGet(delegate: self);
        socketGet.start()
    }
    
    //MARK: - SocketProfileGetDelegate
    func profileGetStarted()
    {
        profileUI(true)
    }
    
    func profileGetSuccess(_ item: ProfileItem)
    {
        profileUI(false)

        if(!item.thumb.isEmpty)
        {
            imageProfile.sd_setImage(with: URL(string: item.thumb + "?stamp=\(Prefs.profileStamp)"), placeholderImage: nil, options: SDWebImageOptions.refreshCached, completed: { [weak self] (img, err, type, url) in
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
        }
        else
        {
            imageProfile.isHidden = true;
            imageHolder.isHidden = false;
        }

        inputEmail.inputText = item.email;
        inputUsername.inputText = item.username;
        inputPhone.inputText = item.phone;
        inputGender.setPickerIndex(item.gender > 1 ? item.gender - 1 : 0);

        inputCity.inputText = item.city;
        inputState.inputText = item.state;
        
        if(item.email.isEmpty || !item.passed)
        {
            showSection(viewEmail)
        }
        else
        {
            showSection(viewProfile)
        }
        
        updateSubmit()
    }
    
    func profileGetError(_ error: String)
    {
        profileUI(false)
        
        UI.alert(self, pageName, error.isEmpty ? "An error occurred!" : error, response: { [unowned self] in
            self.buttonLeftTapped(nil);
        });
    }
    
    //MARK: - Email
    func unemail()
    {
        if(socketEmail != nil)
        {
            socketEmail.setCallback(delegate: nil)
            socketEmail.stop()
            socketEmail = nil
        }
    }
    
    func email(_ email: String, _ password: String)
    {
        unemail();
        
        keyboarderResign(nil)
        
        socketEmail = SocketProfileEmail(delegate: self);
        socketEmail.start(email, password)
    }
    
    //MARK: - SocketProfileEmailDelegate
    func profileEmailStarted()
    {
        profileUI(true)
    }
    
    func profileEmailSuccess(_ message: String)
    {
        profileUI(false)

        UI.alert(self, pageName, message, response: { [unowned self] in
            
            self.showSection(self.viewVerify)
        })
    }
    
    func profileEmailError(_ error: String)
    {
        profileUI(false)
        
        if(error.length() > 0)
        {
            UI.alert(self, pageName, error, response: nil);
        }
        else
        {
            UI.toast(self.view, "An error occurred!")
        }
    }
    
    //MARK: - Verify
    func unverify()
    {
        if(socketVerify != nil)
        {
            socketVerify.setCallback(delegate: nil)
            socketVerify.stop()
            socketVerify = nil
        }
    }
    
    func verify(_ email: String, _ code: String)
    {
        unverify();
        
        keyboarderResign(nil)
        
        socketVerify = SocketProfileVerify(delegate: self);
        socketVerify.start(email, code)
    }
    
    //MARK: - SocketProfileVerifyDelegate
    func profileVerifyStarted()
    {
        profileUI(true)
    }
    
    func profileVerifySuccess(_ message: String)
    {
        profileUI(false)
        
        UI.alert(self, pageName, message, response: { [unowned self] in
            
            self.showSection(self.viewProfile)
        })
    }
    
    func profileVerifyError(_ error: String)
    {
        profileUI(false)
        
        if(error.length() > 0)
        {
            UI.alert(self, pageName, error, response: nil);
        }
        else
        {
            UI.toast(self.view, "An error occurred!")
        }
    }
    
    //MARK: - Set
    func unset()
    {
        if(socketSet != nil)
        {
            socketSet.setCallback(delegate: nil)
            socketSet.stop()
            socketSet = nil
        }
    }
    
    func set(_ username: String, _ gender: Int, _ city: String, _ state: String)
    {
        unset();
        
        keyboarderResign(nil)
        
        socketSet = SocketProfileSet(delegate: self);
        socketSet.start(username, gender, city, state, imageData)
    }
    
    //MARK: - SocketStartDelegate
    func profileSetStarted()
    {
        profileUI(true)
    }
    
    func profileSetSuccess(_ message: String)
    {
        profileUI(false)
                
        UI.alert(self, pageName, message, response: {
            
            AppDelegate.popController(true)
        });
    }
    
    func profileSetError(_ error: String)
    {
        profileUI(false)
        
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
    
    func getGenders() -> [[String: String]]
    {
        var genders = [[String : String]]();
        genders.append(["title" : "Male"]);
        genders.append(["title" : "Female"]);
        return genders;
    }
    
    func getStates() -> [[String: String]]
    {
        var states = [[String: String]]();
        
        states.append(["title" : "Abia"]);
        states.append(["title" : "Abuja"]);
        states.append(["title" : "Adamawa"]);
        states.append(["title" : "Anambra"]);
        states.append(["title" : "Akwa Ibom"]);
        states.append(["title" : "Bauchi"]);
        states.append(["title" : "Bayelsa"]);
        states.append(["title" : "Benue"]);
        states.append(["title" : "Borno"]);
        states.append(["title" : "Cross River"]);
        states.append(["title" : "Delta"]);
        states.append(["title" : "Ebonyi"]);
        states.append(["title" : "Enugu"]);
        states.append(["title" : "Edo"]);
        states.append(["title" : "Ekiti"]);
        states.append(["title" : "Gombe"]);
        states.append(["title" : "Imo"]);
        states.append(["title" : "Jigawa"]);
        states.append(["title" : "Kaduna"]);
        states.append(["title" : "Kano"]);
        states.append(["title" : "Katsina"]);
        states.append(["title" : "Kebbi"]);
        states.append(["title" : "Kogi"]);
        states.append(["title" : "Kwara"]);
        states.append(["title" : "Lagos"]);
        states.append(["title" : "Nasarawa"]);
        states.append(["title" : "Niger"]);
        states.append(["title" : "Ogun"]);
        states.append(["title" : "Ondo"]);
        states.append(["title" : "Osun"]);
        states.append(["title" : "Oyo"]);
        states.append(["title" : "Plateau"]);
        states.append(["title" : "Rivers"]);
        states.append(["title" : "Sokoto"]);
        states.append(["title" : "Taraba"]);
        states.append(["title" : "Yobe"]);
        states.append(["title" : "Zamfara"]);

        return states;
    }
}


