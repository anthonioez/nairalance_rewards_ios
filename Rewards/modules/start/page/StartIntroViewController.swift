import UIKit

class StartIntroViewController: UIViewController
{
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var imageLogo: UIImageView!
    
    var pageIndex : Int = 0
    var pageTab : StartItem!
    var pageCallback: ((Int) -> Void)?
    
    static func instance(_ index: Int, _ item: StartItem) -> StartIntroViewController
    {
        let vc = StartIntroViewController(nibName: "StartIntroViewController", bundle: nil)
        vc.pageTab = item;
        vc.pageIndex = index
        return vc;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        labelTitle.textColor = UIColor.white
        labelDesc.textColor = Rewards.colorAsh;
        
        labelTitle.text = pageTab.title;
        labelDesc.text = pageTab.desc;
        
        if(!pageTab.icon.isEmpty)
        {
            imageLogo.image = UIImage(named: pageTab.icon)
            imageLogo.isHidden = false;
        }
        else
        {
            imageLogo.isHidden = true;
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);

        pageCallback!(pageIndex);
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
