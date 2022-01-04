//
//  ListingsLinkCell.swift
//  Rewards
//
//  Created by Anthonio Ez on 14/01/2017.
//  Copyright © 2017 Anthonio Ez. All rights reserved.
//

import UIKit

class ListingsLinkCell: ListingsBaseCell
{
    static let cellIdentifier = "ListingsLinkCell"
    static let cellHeight: CGFloat = 70

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var viewDivider: UIView!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var imageIconLeft: NSLayoutConstraint!
    
    var id: Int = 0
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        labelTitle.textColor = Listings.colorTitle;
        labelDesc.textColor = Listings.colorDesc;
        
        labelTitle.font = Listings.fontTitle;
        labelDesc.font = Listings.fontDesc;
        
        viewDivider.backgroundColor = Listings.colorDivider;
        
        selectionStyle = .none
    }

    func setData(item: ListingsItem, delegate: ListingsDelegate?)
    {
        id = item.id
        labelTitle.text = item.title
        labelDesc.text = item.descOn
        
        imageIconLeft.constant = (item.image == nil) ? (-1 * imageIcon.frame.width) : 15;
        imageIcon.isHidden = (item.image == nil);
        imageIcon.image = item.image;
        
        imageIcon.tintColor = item.imageColor
        
    }

}
