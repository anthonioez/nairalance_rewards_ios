//
//  ListingViewController.swift
//  Rewards
//
//  Created by Anthonio Ez on 09/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class ListingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    weak var listingDelegate: ListingsDelegate? = nil;
    var listings: Array<ListingsItem> = []

    func setupTable(_ tableList: UITableView)
    {
        tableList.delegate = self
        tableList.dataSource = self
        
        tableList.separatorColor = UIColor.clear
        
        tableList.register(UINib(nibName: ListingsLinkCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: ListingsLinkCell.cellIdentifier)
        tableList.register(UINib(nibName: ListingsToggleCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: ListingsToggleCell.cellIdentifier)
        tableList.register(UINib(nibName: ListingsSpacerCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: ListingsSpacerCell.cellIdentifier)
        tableList.register(UINib(nibName: ListingsSectionCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: ListingsSectionCell.cellIdentifier)
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ heightForRowAttableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if( listings[indexPath.row].type == SettingsType.section)
        {
            return ListingsSectionCell.cellHeight;
        }
        else if( listings[indexPath.row].type == SettingsType.spacer)
        {
            return ListingsSpacerCell.cellHeight;
        }
        else if( listings[indexPath.row].type == SettingsType.toggle)
        {
            return ListingsToggleCell.cellHeight;
        }
        else if( listings[indexPath.row].type == SettingsType.link)
        {
            return ListingsLinkCell.cellHeight;
        }
        else
        {
            return 44;
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        let type = listings[indexPath.row].type
        if( type == SettingsType.toggle || type == SettingsType.link )  
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
        return listings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let item = listings[indexPath.row];
        if(item.type == .spacer)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: ListingsSpacerCell.cellIdentifier, for: indexPath) as! ListingsSpacerCell
            return cell
        }
        else if(item.type == .section)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: ListingsSectionCell.cellIdentifier, for: indexPath) as! ListingsSectionCell
            cell.setData(item: item)
            return cell
        }
        else if(item.type == .toggle)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: ListingsToggleCell.cellIdentifier, for: indexPath) as! ListingsToggleCell
            cell.setData(item: item, delegate: listingDelegate)
            return cell
        }
        else if(item.type == .link)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: ListingsLinkCell.cellIdentifier, for: indexPath) as! ListingsLinkCell
            cell.setData(item: item, delegate: listingDelegate)
            return cell
        }
        
        return UITableViewCell()
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let item = listings[indexPath.row];
        
        listingSelect(item);
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        
    }
    
    //MARK: - Funcs
    func listingSelect(_ item: ListingsItem)
    {
    }
}
