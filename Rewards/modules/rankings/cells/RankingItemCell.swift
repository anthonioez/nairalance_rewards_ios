//
//  RankingItemCell.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import SDWebImage

class RankingItemCell: UITableViewCell
{
    public static let cellHeight = CGFloat(60)
    public static let cellIdentifier = "RankingItemCell";

    @IBOutlet weak var labelRank: UILabel!

    @IBOutlet weak var viewHolder: UIView!
    @IBOutlet weak var imageHolder: UIImageView!
    @IBOutlet weak var imageLogo: UIImageView!
    

    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelRewards: UILabel!
    @IBOutlet weak var viewRewards: UIView!
    @IBOutlet weak var viewRewardsWidth: NSLayoutConstraint!

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
        
        self.contentView.backgroundColor = highlighted ? Rewards.colorHilite.withAlphaComponent(0.1) : .clear;
    }
    
    func setData(_ item: RankingItem)
    {
        labelRank.text = Utils.formatRanking(item.ranking)
        labelUsername.text = item.username

        labelRewards.text = Utils.formatPoints(item.rewards);
        labelRewards.sizeToFit()
        
        let rect = labelRewards.textRect(forBounds: self.frame, limitedToNumberOfLines: 1);
        
        viewRewardsWidth.constant = max(rect.width + 20, 22);
        viewRewards.layerBorder(radius: 11, border: 0, color: .clear);
        
        
        if(!item.image.isEmpty)
        {
            imageLogo.sd_setImage(with: URL(string: item.image), placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), completed: { [weak self] (img, err, type, url) in 
                if(err == nil && img != nil)
                {
                    self?.imageLogo.isHidden = false;
                    self?.imageHolder.isHidden = true;
                }
                else
                {
                    self?.imageLogo.isHidden = true;
                    self?.imageHolder.isHidden = false;
                }
            })
        }
        else
        {
            self.imageLogo.isHidden = true;
            self.imageHolder.isHidden = false;

        }

        viewHolder.rounded()
        viewDivider.backgroundColor = Rewards.colorDivider;

        selectionStyle = .none;
    }
}
