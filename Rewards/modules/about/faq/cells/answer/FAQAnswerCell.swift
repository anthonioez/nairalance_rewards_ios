//
//  FAQAnswerCell.swift
//  Rewards
//
//  Created by Anthonio Ez on 14/01/2017.
//  Copyright © 2017 Anthonio Ez. All rights reserved.
//

import UIKit

class FAQAnswerCell: UITableViewCell
{
    static let cellIdentifier = "FAQAnswerCell"
    static let cellHeight: CGFloat = 70

    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        labelTitle.textColor = Rewards.colorDetail;
        
        labelTitle.font = Rewards.font.withSize(14);
        
        selectionStyle = .none
    }

    func setData(item: FAQItem)
    {
        if(item.answerAttr != nil)
        {
            labelTitle.attributedText = item.answerAttr;
        }
        else
        {
            labelTitle.text = item.answer        
        }
    }

}
