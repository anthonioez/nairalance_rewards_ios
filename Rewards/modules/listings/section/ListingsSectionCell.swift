//
//  ListingsSectionCell.swift
//  nairalance
//
//  Created by Anthonio Ez on 06/08/2016.
//  Copyright © 2016 Anthonio Ez. All rights reserved.
//

import UIKit

class ListingsSectionCell: ListingsBaseCell
{
    static let cellIdentifier = "ListingsSectionCell"
    static let cellHeight: CGFloat = 30
    
    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        labelTitle.textColor = Listings.colorHeader;
        labelTitle.font = Listings.fontHeader;
        
        selectionStyle = .none
    }

    func setData(item: ListingsItem)
    {
        labelTitle.text = item.title
        
        selectionStyle = .none
    }
}
