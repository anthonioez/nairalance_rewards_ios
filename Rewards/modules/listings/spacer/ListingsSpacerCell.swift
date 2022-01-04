//
//  ListingsSpacerCell.swift
//  Nairalance
//
//  Created by Anthonio Ez on 12/09/2016.
//  Copyright © 2016 Anthonio Ez. All rights reserved.
//

import UIKit

class ListingsSpacerCell: ListingsBaseCell
{
    static let cellIdentifier = "ListingsSpacerCell"
    static let cellHeight: CGFloat = 25
    
    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
