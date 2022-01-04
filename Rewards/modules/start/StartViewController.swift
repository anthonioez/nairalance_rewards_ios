//
//  StartViewController.swift
//  leaptv
//

import UIKit

class StartViewController: UIViewController, UIPageViewControllerDataSource, SocketStartDelegate
{
    @IBOutlet weak var viewMain: UIView!    
    @IBOutlet weak var viewStart: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var progress: Progress!
    
    var socketStart: SocketStart! = nil;
    
    var pageViewController : UIPageViewController!
    
    var pageList = [StartItem]()
    
    static func instance() -> StartViewController
    {
        let vc = StartViewController(nibName: "StartViewController", bundle: nil)
        return vc;
    }
    
    deinit
    {
        unload()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = Rewards.colorMain;
        self.viewMain.backgroundColor = Rewards.colorMain;

        pageList.append(StartItem("logo_white.png",          Strings.intro_welcome,     Strings.intro_welcome_desc));
        pageList.append(StartItem("intro_invite.png",        Strings.intro_invite,      Strings.intro_invite_desc));
        pageList.append(StartItem("intro_play.png",          Strings.intro_play,        Strings.intro_play_desc));
        
        pageList.append(StartItem("intro_earn.png",          Strings.intro_earn,        Strings.intro_earn_desc));
        pageList.append(StartItem("intro_cashout.png",       Strings.intro_cashout,     Strings.intro_cashout_desc));
        pageList.append(StartItem("logo_white.png",          Strings.intro_thanks,      Strings.blank));
        
        buttonStart.rounded()
        
        viewMain.isHidden = true;
        viewStart.isHidden = true;
        pageControl.isHidden = true;
        
        //TODO perform(#selector(preLoad), with: nil, afterDelay: 2.0);
        preLoad();        
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true;
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);
        
    }

    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews();
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! StartIntroViewController).pageIndex
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1

        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! StartIntroViewController).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        
        if (index == self.pageList.count) {
            return nil
        }
        
        return viewControllerAtIndex(index: index)
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController?
    {
        if self.pageList.count == 0 || index >= self.pageList.count
        {
            return nil
        }
        
        if(pageList[index].ctrl == nil)
        {
            let pageContentViewController = StartIntroViewController.instance(index, pageList[index]);
            pageContentViewController.pageCallback = pageCallback;
            
            pageList[index].ctrl = pageContentViewController;
        }
        else
        {
            pageList[index].ctrl.pageCallback = pageCallback;
        }

        pageList[index].ctrl.view.frame = CGRect(x: 0, y: 0, width: pageViewController.view.frame.size.width, height: pageViewController.view.frame.size.height);

        return pageList[index].ctrl
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return self.pageList.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
    
    //MARK: Funcs
    func pageCallback(index: Int) -> Void
    {
        if(index == pageList.count - 1)
        {
            if(Prefs.runCount <= 0)
            {
                Prefs.runCount = 1
            }

            showStart(true);
        }
        else
        {
            pageControl.isHidden = false;
            
            showStart(false)
        }
        
        pageControl.currentPage = index;
    }
    
    @IBAction func buttonStartTap(_ sender: Any)
    {
        startSignin();
        //startJoin();
    }
    
    @objc func preLoad()
    {
        if(ServerSocket.isConnected() && ServerSocket.isRegistered())
        {
            startApp();
        }
        else
        {
            load();
        }
    }
    
    @objc func showIntro()
    {
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.white;
        pageControl.backgroundColor = UIColor.clear
        pageControl.numberOfPages = pageList.count;
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        
        let startingViewController: UIViewController = viewControllerAtIndex(index: 0)!
        let viewControllers = [startingViewController]
        pageViewController.setViewControllers(viewControllers , direction: .forward, animated: false, completion: nil)
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: viewMain.frame.size.width, height: viewMain.frame.size.height);
        
        addChildViewController(pageViewController)
        viewMain.addSubview(pageViewController.view)
        
        pageViewController.didMove(toParentViewController: self)
        
        viewMain.isHidden = false;
        pageControl.isHidden = false;
    }
    
    func showStart(_ show: Bool)
    {
        if(show)
        {
            viewStart.isHidden = false;
        }
        let top = CGAffineTransform(translationX: 0, y: show ? -140 : 140)
        
        UIView.animate(withDuration: 0.5, delay: show ? 1.0 : 0.0, options: [], animations: {
            // Add the transformation in this block
            // self.container is your view that you want to animate
            self.viewStart.transform = top
        }, completion: { done in

            if(show)
            {
                self.pageControl.isHidden = true;
            }
            else
            {
                self.pageControl.isHidden = false;
                self.viewStart.isHidden = true;
            }
        })
    }

    @objc func startApp()
    {
        if (Rewards.isUser())
        {
            if(Prefs.userName.isEmpty)
            {
                startJoin();
            }
            else
            {
                startMain();
            }
        }
        else
        {
            if (Prefs.runCount == 0)
            {
                showIntro();
            }
            else
            {
                showStart(true);
            }
        }
    }
    
    func startSignin()
    {
        AppDelegate.setControllers([PhoneSendViewController.instance()], animated: false);
    }
    
    func startJoin()
    {
        AppDelegate.setControllers([ProfileJoinViewController.instance()], animated: false);
    }
    
    func startMain()
    {
        AppDelegate.setControllers([HomeViewController.instance()], animated: false);
    }
    
    func unload()
    {
        if(socketStart != nil)
        {
            socketStart.setCallback(delegate: nil)
            socketStart.stop()
            socketStart = nil
        }
    }
    
    func load()
    {
        unload();
        
        socketStart = SocketStart(delegate: self);
        socketStart.start()
    }
    
    //MARK: - SocketStartDelegate
    func startStarted()
    {
        progress.start()
    }
    
    func startSuccess(_ update: Int, _ message: String)
    {
        progress.stop()
        
        sendToken();
        
        Device.updateCheck(self, message: message, update: update, resume: {  [unowned self] in
                            
            self.startApp()
            
        }, pause: { [unowned self] in
                            
            self.startStore()
        })
    }
    
    func startError(_ error: String)
    {
        progress.stop()
        
        sendToken()
        
        if(error.length() > 0)
        {
            UI.alert(self, Rewards.appName, error, response: { [unowned self] in
                self.startApp()
            })
        }
        else
        {
            self.startApp();
        }
    }
    
    func startStore()
    {
        self.startApp()
        
        self.perform(#selector(openStore), with: nil, afterDelay: 1.0)
    }
    
    @objc func openStore()
    {
        Rewards.openStoreUrl();
    }
    
    func sendToken()
    {
        if(!Prefs.pushToken.isEmpty && !Prefs.pushTokenSent)
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.token();
        }
    }
}
