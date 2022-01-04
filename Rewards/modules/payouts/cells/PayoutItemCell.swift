//
//  PayoutItemCell.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import SDWebImage

class PayoutItemCell: UITableViewCell
{
    public static let cellHeight = CGFloat(80)
    public static let cellHeightShort = CGFloat(70)
    public static let cellIdentifier = "PayoutItemCell";

    @IBOutlet weak var imageLogo: UIImageView!
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var labelStamp: UILabel!
    
    @IBOutlet weak var labelPayouts: UILabel!
    @IBOutlet weak var viewPayouts: UIView!
    @IBOutlet weak var viewPayoutsWidth: NSLayoutConstraint!
    @IBOutlet weak var labelStatus: UILabel!
    
    @IBOutlet weak var labelDescVertical: NSLayoutConstraint!
    
    @IBOutlet weak var viewDivider: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code

        labelTitle.textColor = UIColor.white
        labelDesc.textColor = Rewards.colorAsh
        labelStamp.textColor = Rewards.colorAsh
        labelStatus.textColor = Rewards.colorAsh
        
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
        self.contentView.backgroundColor = highlighted ? Rewards.colorHilite.withAlphaComponent(0.1) : .clear;
    }
    
    func setData(_ item: PayoutItem)
    {
        labelTitle.text = item.title
        labelDesc.text = String(format: "%@%@", item.account, item.name.isEmpty ? "" : String(format: " - %@", item.name));

        labelStatus.text = item.getStatus().uppercased()
        labelStatus.textColor = item.getColor()
        
        labelStamp.text = item.datetime;

        imageLogo.image = item.type.isEmpty ? Rewards.logoWhite : Rewards.providerImage(item.type);
        
        labelPayouts.text = Utils.formatMoney(item.amount);
        labelPayouts.sizeToFit()
        
        let rect = labelPayouts.textRect(forBounds: self.frame, limitedToNumberOfLines: 1);
        
        viewPayoutsWidth.constant = max(rect.width + 20, 22);
        viewPayouts.layerBorder(radius: 11, border: 0, color: .clear);
        
        selectionStyle = .none;
    }
}
