//
//  EarningItemCell.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import SDWebImage

class EarningItemCell: UITableViewCell
{
    public static let cellHeight = CGFloat(60)
    public static let cellIdentifier = "EarningItemCell";

    @IBOutlet weak var imageLogo: UIImageView!
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelTitleTop: NSLayoutConstraint!
    @IBOutlet weak var labelDesc: UILabel!
    
    @IBOutlet weak var labelEarnings: UILabel!
    @IBOutlet weak var viewEarnings: UIView!
    @IBOutlet weak var viewEarningsWidth: NSLayoutConstraint!
    
    @IBOutlet weak var viewDivider: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code

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
    
    func setData(_ item: EarningItem, _ selected: Bool)
    {
        labelTitle.text = item.title
        labelDesc.text = selected ? item.datetime : String(format: "%@%@%@", item.action.uppercased(), (item.info.isEmpty ? "" : " - "), item.info);
        
        imageLogo.image = item.type.isEmpty ? Rewards.logoWhite : Rewards.typeImage(item.type);
        
        labelEarnings.text = Utils.formatPoints(item.points);
        labelEarnings.sizeToFit()
        
        let rect = labelEarnings.textRect(forBounds: self.frame, limitedToNumberOfLines: 1);
        
        viewEarningsWidth.constant = max(rect.width + 20, 22);
        viewEarnings.layerBorder(radius: 11, border: 0, color: .clear);
        
        selectionStyle = .none;
    }
}
