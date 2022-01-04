//
//  HomeItemCell.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
//import WebImage

class HomeItemCell: UITableViewCell
{
    public static let cellHeight = CGFloat(80)
    public static let cellIdentifier = "HomeItemCell";

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var labelCount: UILabel!
    @IBOutlet weak var viewCount: UIView!
    @IBOutlet weak var viewCountWidth: NSLayoutConstraint!
    
    @IBOutlet weak var viewDivider: UIView!
    @IBOutlet weak var imageLogo: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        
        viewDivider.backgroundColor = Rewards.colorDividerDark;
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool)
    {
        super.setHighlighted(highlighted, animated: animated)
        
        self.viewDivider.isHidden = highlighted;
        self.contentView.backgroundColor = highlighted ? Rewards.colorHilite : .clear;
    }
    
    func setData(_ item: RewardTypeItem)
    {
        if(item.titleAttr != nil)
        {
            labelTitle.attributedText = item.titleAttr;
        }
        else
        {
            labelTitle.text = item.title;
        }
        
        if(item.titleAttr != nil)
        {
            labelDesc.attributedText = item.descAttr;
        }
        else
        {
            labelDesc.text = item.desc;
        }
        
        imageLogo.image = Rewards.typeImage(item.type);
        
        labelCount.text = "\(item.available)";
        labelCount.sizeToFit()
        
        let rect = labelCount.textRect(forBounds: self.frame, limitedToNumberOfLines: 1);
        
        viewCountWidth.constant = max(rect.width + 10, 20);

        viewCount.isHidden = (item.available <= 0);
        viewCount.layerBorder(radius: 10, border: 0, color: .clear);

        selectionStyle = .none;
    }
}
