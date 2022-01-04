//
//  CashoutItemCell.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import SDWebImage

class CashoutRateItemCell: UITableViewCell
{
    public static let cellHeight = CGFloat(70)
    public static let cellIdentifier = "CashoutRateItemCell";

    @IBOutlet weak var imageLogo: UIImageView!
    
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var labelPoints: UILabel!

    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var viewAmount: UIView!
    @IBOutlet weak var viewAmountWidth: NSLayoutConstraint!
    
    @IBOutlet weak var viewDivider: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code

        labelType.textColor = UIColor.white;
        labelPoints.textColor = Rewards.colorAsh;
        labelAmount.textColor = UIColor.white
        
        viewDivider.backgroundColor = Rewards.colorDivider;
        viewAmount.backgroundColor = Rewards.colorActive;
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
        self.contentView.backgroundColor = highlighted ? Rewards.colorHilite.withAlphaComponent(0.1) : .clear;
    }
    
    func setData(_ item: CashoutRateItem)
    {
        labelType.text = Rewards.payoutType(item.type);
        labelPoints.text = String(format: "%@ points", Utils.formatPoints(item.points));

        labelAmount.text = Utils.formatMoney(item.amount);
        labelAmount.sizeToFit()
        
        let rect = labelAmount.textRect(forBounds: self.frame, limitedToNumberOfLines: 1);
        
        viewAmountWidth.constant = max(rect.width + 20, 22);
        viewAmount.layerBorder(radius: 11, border: 0, color: .clear);
        
        imageLogo.image = Rewards.providerImage(item.type)

        selectionStyle = .none;
    }
}
