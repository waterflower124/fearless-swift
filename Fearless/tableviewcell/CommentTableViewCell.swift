//
//  CommentTableViewCell.swift
//  Fearless
//
//  Created by Water Flower on 2019/4/24.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    
    @IBOutlet weak var comment_avatarimageview: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var imageLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.comment_avatarimageview.layer.cornerRadius = 30
        self.commentTextView.scrollRangeToVisible(NSMakeRange(0, 1))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
