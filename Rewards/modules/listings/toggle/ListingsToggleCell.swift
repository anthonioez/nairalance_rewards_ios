//
//  ListingsToggleCell.swift
//  nairalance
//
//  Created by Anthonio Ez on 06/08/2016.
//  Copyright © 2016 Anthonio Ez. All rights reserved.
//

import UIKit

class ListingsToggleCell: ListingsBaseCell
{
    static let cellIdentifier = "ListingsToggleCell"
    static let cellHeight: CGFloat = 80

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    
    @IBOutlet weak var switchToggle: UISwitch!
    @IBOutlet weak var viewDivider: UIView!
    
    var id: Int = 0
    weak var delegate: ListingsDelegate? = nil
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        shouldHilite = false;
        
        labelTitle.textColor = Listings.colorTitle;
        labelDesc.textColor = Listings.colorDesc;
        
        labelTitle.font = Listings.fontTitle;
        labelDesc.font = Listings.fontDesc;
        
        switchToggle.onTintColor = Listings.colorHeader;
        
        viewDivider.backgroundColor = Listings.colorDivider;
        
        selectionStyle = .none

    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func switchToggleChanged(_ sender: Any) 
    {
        if(self.delegate != nil)
        {
            self.delegate?.switchChanged(id: id, value: switchToggle.isOn)
        }
    }
    
    func setData(item: ListingsItem, delegate: ListingsDelegate?)
    {
        id = item.id
        labelTitle.text = item.title
        
        if(delegate != nil)
        {
            switchToggle.isOn = (delegate?.switchValue(id: id))!
        }
        
        labelDesc.text = (switchToggle.isOn == false && item.descOff.count > 0) ? item.descOff : item.descOn;

        self.delegate = delegate
    }

}
