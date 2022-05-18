//
//  CellCourseDetail_Videos.swift
//  Test
//
//  Created by Abhishek Visa on 4/12/19.
//  Copyright © 2019 Shalini. All rights reserved.
//

import UIKit

class CellCourseDetail_Videos: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var vVideoContainer:UIView!
    @IBOutlet weak var btnLock:UIButton!
    @IBOutlet weak var imgV_Thumbnail:UIImageView!
    @IBOutlet weak var imgV_Play:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
