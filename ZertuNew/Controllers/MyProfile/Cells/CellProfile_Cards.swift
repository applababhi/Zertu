//
//  CellProfile_Cards.swift
//  profile
//
//  Created by Abhishek Visa on 28/11/19.
//  Copyright © 2019 Shalini. All rights reserved.
//

import UIKit

class CellProfile_Cards: UITableViewCell {

    @IBOutlet weak var imgViewCard:UIImageView!
    @IBOutlet weak var imgViewTickDefault:UIImageView!
    @IBOutlet weak var lblNumber:UILabel!
    @IBOutlet weak var btnFullRow:UIButton!
    @IBOutlet weak var btnDelete:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
