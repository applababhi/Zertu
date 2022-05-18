//
//  CellCourseDetail_FaqProgress.swift
//  Test
//
//  Created by Abhishek Visa on 4/12/19.
//  Copyright © 2019 Shalini. All rights reserved.
//

import UIKit
import GTProgressBar

class CellCourseDetail_FaqProgress: UITableViewCell {

    @IBOutlet weak var btnFaq:UIButton!
    @IBOutlet weak var lblProgress:UILabel!
    @IBOutlet weak var lblAvailableSession:UILabel!
 //   @IBOutlet weak var vProgress:UIView!
    @IBOutlet weak var progressBar: GTProgressBar!
    @IBOutlet weak var c_BtnFaq_Ht:NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
