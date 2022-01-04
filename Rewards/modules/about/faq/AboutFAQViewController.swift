//
//  AboutFAQViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 03/06/2018.
//  Copyright © 2018 waltech. All rights reserved.
//

import UIKit

class AboutFAQViewController: AdViewController, UITableViewDelegate, UITableViewDataSource, MenuBarDelegate, SocketFAQDelegate, FAQQuestionDelegate
{
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var progress: Progress!
    
    var isLoaded = false;
    var isLoading = false;
    var isInfinite = true;

    var items = [FAQItem]();
    var index = 0;
    var last = Double(0)
    
    var socketFAQ: SocketFAQ! = nil;
    
    deinit
    {
        unload()
    }
    
    static func instance() -> AboutFAQViewController
    {
        let vc = AboutFAQViewController(nibName: "AboutFAQViewController", bundle: nil)
        return vc;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        menuBar.titleText = "Frequently Asked Questions"
        menuBar.delegate = self;
        menuBar.shadow();

        tableList.delegate = self
        tableList.dataSource = self
        
        tableList.separatorColor = UIColor.clear
        
        tableList.register(UINib(nibName: FAQQuestionCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: FAQQuestionCell.cellIdentifier)
        tableList.register(UINib(nibName: FAQAnswerCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: FAQAnswerCell.cellIdentifier)

        reload();            

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
        
        if(!isLoaded && items.count == 0)
        {
            load();
        }
        else
        {
            tableList!.reloadData();
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
        }
        
        tableList.contentInset.bottom = inset.bottom

        super.viewWillLayoutSubviews();
    }
    
    //MARK: - MenuBarDelegate
    func buttonLeftTapped(_ input: MenuBar!)
    {
        AppDelegate.popController(true)
    }
    
    func buttonRightTapped(_ input: MenuBar!)
    {
        Rewards.popupTell(menuBar.buttonRight)
    }
    
    
    //MARK: UITableViewDelegate
    func tableView(_ heightForRowAttableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let item = items[indexPath.row];
        if(item.parent == 0)
        {
            return FAQQuestionCell.cellHeight;
        }
        else
        {
            if(item.height == 0)
            {
                if(item.answerAttr != nil)
                {
                    let rect = item.answerAttr!.boundingRect(with: CGSize(width: tableList.frame.width - 40, height: 1000), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil);
                    
                    item.height = rect.height + 10
                    
                    return item.height
                }

                return FAQAnswerCell.cellHeight;    
            }
            else
            {
                return item.height;
            }
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        let item = items[indexPath.row];
        if(item.parent == 0)
        {
            return true;
        }
        return false
    }
    
    //MARK: UITableViewDataSource
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let item = items[indexPath.row];
        if(item.parent == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: FAQQuestionCell.cellIdentifier, for: indexPath) as! FAQQuestionCell
            cell.setData(index: indexPath.row, item: item, delegate: self)
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: FAQAnswerCell.cellIdentifier, for: indexPath) as! FAQAnswerCell
            cell.setData(item: item)
            return cell
        }
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if(self.shouldLoadNext(indexPath.row, count: items.count, last: last, loading: isLoading, infinite: isInfinite))
        {
            //Rewards.countInterstitial(count: 1)
            
            load()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        questionToggle(index: indexPath.row);

        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    //MARK: - FAQQuestionDelegate
    func questionToggle(index: Int)
    {
        let item = items[index];
        
        toggleMenu(index, item)
    }
    
    //MARK: - Funcs
    func toggleMenu(_ index: Int, _ question: FAQItem)
    {
        var insertPaths = [IndexPath]();
        var deletePaths = [IndexPath]();
        
        let answer = FAQItem(parent: question.id, answer: question.answer);
        let indexPath = IndexPath.init(row: index, section: 0);
        
        var pos = 0;
        if(question.expanded)
        {
            var newMenu = [FAQItem]();
            for m in items
            {
                if(m.parent == question.id)
                {
                    let path = IndexPath.init(row: pos, section: 0)
                    deletePaths.append(path);
                }
                else
                {
                    newMenu.append(m);
                }
                pos += 1;
            }
            
            items.removeAll();
            items.append(contentsOf: newMenu)
            
            question.expanded = false;
        }
        else
        {
            pos = index + 1;
            
            items.insert(answer, at: pos);
            
            let path = IndexPath.init(row: pos, section: 0)
            insertPaths.append(path);
            pos+=1;
            
            question.expanded = true;
        }
        
        tableList.beginUpdates()
        tableList.insertRows(at: insertPaths, with: .fade)
        tableList.deleteRows(at: deletePaths, with: .fade)
        tableList.reloadRows(at: [indexPath], with: .fade)
        tableList.endUpdates()
        
        tableList.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
        tableList.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
    }

    func reload()
    {
        index = 0;
        isInfinite = true;
        
        load()
    }
    
    func unload()
    {
        if(socketFAQ != nil)
        {
            socketFAQ.setCallback(delegate: nil)
            socketFAQ.stop()
            socketFAQ = nil
        }
    }
    
    func load()
    {
        unload();
        
        socketFAQ = SocketFAQ(delegate: self);
        socketFAQ.start(index, Support.PAGE_SIZE)
    }
    
    func loadUI(_ active: Bool)
    {
        isLoading = active
        
        progress.animate(active)
        UI.dimView(tableList, active);
        
        if(active)
        {
            last = DateTime.currentTimeMillis()
        }
        else
        {
            last = 0;
        }
    }
    
    //MARK: - SocketFAQDelegate
    func faqStarted()
    {
        loadUI(true)
    }
    
    func faqSuccess(_ items: [FAQItem], _ index: Int)
    {
        loadUI(false)
        
        isLoaded = true
        if(index == 0)
        {
            self.items.removeAll();
        }
        
        self.items.append(contentsOf: items);
        
        isInfinite = items.count == Support.PAGE_SIZE
        self.index = index + Support.PAGE_SIZE;
        
        tableList.reloadData();
        
        if(index == 0)
        {
            tableList.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    func faqError(_ error: String)
    {
        loadUI(false)
        
        UI.toast(self.view, error)
    }
}
