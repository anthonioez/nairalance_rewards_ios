//
//  FAQQuestionCell.swift
//  nairalance
//
//  Created by Anthonio Ez on 06/08/2016.
//  Copyright © 2016 Anthonio Ez. All rights reserved.
//

import UIKit

class FAQQuestionCell: UITableViewCell
{
    static let cellIdentifier = "FAQQuestionCell"
    static let cellHeight: CGFloat = 50
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageArrow: UIImageView!
    
    weak var delegate: FAQQuestionDelegate? = nil;
    
    var index = -1;
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        labelTitle.textColor = Rewards.colorTitle;
        labelTitle.font = Rewards.fontBold;
        
        selectionStyle = .none
    }

    func setData(index: Int, item: FAQItem, delegate: FAQQuestionDelegate?)
    {
        self.index = index;
        self.delegate = delegate;
        
        labelTitle.text = item.question
        
        imageArrow.image = UIImage(named: item.expanded ? "ic_keyboard_arrow_up_48pt" : "ic_keyboard_arrow_down_48pt");
        
        selectionStyle = .none
    }
}


protocol FAQQuestionDelegate : NSObjectProtocol
{
    func questionToggle(index: Int);
}
