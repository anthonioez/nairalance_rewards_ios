//
//  RewardItemCell.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import SDWebImage

class RewardItemCell: UITableViewCell
{
    public static let cellHeight = CGFloat(90)
    public static let cellIdentifier = "RewardItemCell";

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    
    @IBOutlet weak var viewDivider: UIView!
    @IBOutlet weak var imageLogo: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        
        labelTitle.textColor = Rewards.colorTitle;
        labelDesc.textColor = Rewards.colorDetail;
        
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
    
    func setData(_ item: RewardItem, _ placeholder: UIImage)
    {
        labelTitle.text = item.title;
        labelDesc.text = item.desc;
        
        if(!item.image.isEmpty)
        {
            imageLogo.sd_setImage(with: URL(string: item.image), placeholderImage: placeholder, options: SDWebImageOptions(rawValue: 0), completed: { [weak self] (img, err, type, url) in 
                if(err == nil && img != nil)
                {
                }
                else
                {
                    self?.imageLogo.image = Rewards.typeImage(item.type);
                }
            })
        }
        else
        {
            imageLogo.image = Rewards.typeImage(item.type);
        }
        
        selectionStyle = .none;
    }
}
