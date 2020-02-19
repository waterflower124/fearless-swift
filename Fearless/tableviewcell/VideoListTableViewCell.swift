//
//  VideoListTableViewCell.swift
//  Fearless
//
//  Created by Water Flower on 2019/4/24.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit

class VideoListTableViewCell: UITableViewCell {

    @IBOutlet weak var videoimageview: UIImageView!
    @IBOutlet weak var videotitleTextView: UITextView!
    @IBOutlet weak var favorButton: UIButton!
    
    var favorButtonAction: (() -> Void)? = nil
    @IBAction func favorButtonTap(_ sender: Any) {
        favorButtonAction?()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
