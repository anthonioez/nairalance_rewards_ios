//
//  HelpItemCell.swift
//  Rewards
//
//  Created by Anthonio Ez on 14/01/2017.
//  Copyright © 2017 Anthonio Ez. All rights reserved.
//

import UIKit

class HelpItemCell: UITableViewCell
{
    static let cellIdentifier = "HelpItemCell"
    static let cellHeight: CGFloat = 260

    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        labelTitle.textColor = Rewards.colorTitle
        labelDesc.textColor = Rewards.colorDetail;
        
        //labelTitle.font = Listings.fontTitle;
        //labelDesc.font = Listings.fontDesc;
        
        selectionStyle = .none
    }

    func setData(item: HelpItem)
    {
        labelTitle.text = item.title
        labelDesc.text = item.desc
        imageIcon.image = item.image;        
    }

}
