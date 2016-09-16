//
//  CustomHangoutCell.swift
//  TeamGraysonGo
//
//  Created by Graham Turbyne on 8/24/16.
//  Copyright © 2016 Graham Turbyne. All rights reserved.
//

import UIKit

class CustomHangoutCell: UITableViewCell {
    
    @IBOutlet weak var organizerLabel: UILabel!
    @IBOutlet weak var organizerImage: UIImageView!
    @IBOutlet weak var goingImage1: UIImageView!
    @IBOutlet weak var notGoingImage1: UIImageView!
    @IBOutlet weak var whenLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
