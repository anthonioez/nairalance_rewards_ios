//
//  RewardActionCell.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import SDWebImage

class RewardActionCell: UITableViewCell
{
    public static let cellHeight = CGFloat(50)
    public static let cellIdentifier = "RewardActionCell";

    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var labelPoints: UILabel!
    @IBOutlet weak var viewPoints: UIView!
    @IBOutlet weak var viewPointsWidth: NSLayoutConstraint!
    
    @IBOutlet weak var viewDivider: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code

        labelTitle.textColor = UIColor.white;
        viewDivider.backgroundColor = Rewards.colorDivider;
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool)
    {
        super.setHighlighted(highlighted, animated: animated)
        
        //self.viewDivider.isHidden = highlighted;
        //self.contentView.backgroundColor = highlighted ? Rewards.colorHilite.withAlphaComponent(0.1) : .clear;
    }
    
    func setData(_ item: RewardActionItem)
    {
        if(item.claimed)
        {
            let attr: NSMutableAttributedString =  NSMutableAttributedString(string: item.title)
            
            let range = NSMakeRange(0, attr.length);
            attr.addAttributes([NSAttributedStringKey.strikethroughStyle: 1], range: range)
            attr.addAttributes([NSAttributedStringKey.strikethroughColor: Rewards.colorClaimed], range: range)
            attr.addAttributes([NSAttributedStringKey.foregroundColor: Rewards.colorClaimed], range: range);
            attr.addAttributes([NSAttributedStringKey.font: labelTitle.font], range: range);

            labelTitle.attributedText = attr;
            viewPoints.backgroundColor = Rewards.colorClaimed
        }
        else
        {
            labelTitle.text = item.title
            labelTitle.textColor = UIColor.white
            viewPoints.backgroundColor = Rewards.colorActive
        }
        
        labelPoints.text = Utils.formatPoints(item.points);
        labelPoints.sizeToFit()
        
        let rect = labelPoints.textRect(forBounds: self.frame, limitedToNumberOfLines: 1);
        
        viewPointsWidth.constant = max(rect.width + 20, 22);
        viewPoints.layerBorder(radius: 11, border: 0, color: .clear);
        
        selectionStyle = .none;
    }
}
