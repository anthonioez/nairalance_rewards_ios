//
//  StopViewController.swift
//  nairalance
//
//  Created by Anthonio Ez on 05/08/2016.
//  Copyright © 2016 Anthonio Ez. All rights reserved.
//

import UIKit

class StopViewController: UIViewController {

    var message = "A new version of this app is available!"
    var button = true;
    
    @IBOutlet weak var textMessage: UITextView!
    @IBOutlet weak var buttonUpdate: UIButton!
    
    
    static func instance(_ msg: String, _ button: Bool) -> StopViewController
    {
        let vc = StopViewController(nibName: "StopViewController", bundle: nil)
        vc.message = msg;
        vc.button = button;
        return vc;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        textMessage.text = message
        
        buttonUpdate.rounded()
        buttonUpdate.isHidden = !button;
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    
    override var prefersStatusBarHidden : Bool
    {
        return false;
    }

    @IBAction func buttonUpdateTap(_ sender: AnyObject)
    {
        Rewards.openStoreUrl()
    }
}
