//
//  CategoryTableViewCell.swift
//  Fearless
//
//  Created by Water Flower on 2019/4/23.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var countTextField: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
