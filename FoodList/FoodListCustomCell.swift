//
//  FoodListCustomCell.swift
//  KFoodMenuScan
//
//  Created by yyjweber on 2022/08/21.
//

import UIKit


class FoodListCustomCell: UITableViewCell {
    
    @IBOutlet weak var fdNameKR: UILabel!
    @IBOutlet weak var fdNameENP: UILabel!
    @IBOutlet weak var fdNameEN: UILabel!
    @IBOutlet weak var fdImage: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

        if selected {
            
            contentView.backgroundColor = UIColor.systemGray6
            
        } else {
            
            contentView.backgroundColor = UIColor.white
        }
        
        self.fdImage.layer.cornerRadius = self.fdImage.frame.width/8.0
        self.fdImage.layer.masksToBounds = true
        
    }
}
