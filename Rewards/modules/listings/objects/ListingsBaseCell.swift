//
//  ListingsBaseCell.swift
//  Rewards
//
//  Created by Anthonio Ez on 08/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class ListingsBaseCell: UITableViewCell
{
    var shouldHilite = true;
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool)
    {
        super.setHighlighted(highlighted, animated: animated)
        
        self.contentView.backgroundColor = (shouldHilite && highlighted) ? Rewards.colorHilite : .clear;
    }
}
