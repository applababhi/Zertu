//
//  Cell_RegisteredCard.swift
//  Zertu
//
//  Created by Abhishek Bhardwaj on 12/6/18.
//  Copyright © 2018 Abhishek Bhardwaj. All rights reserved.
//

import UIKit

class Cell_RegisteredCard: UITableViewCell {

    @IBOutlet weak var view_Bk: UIView!
    @IBOutlet weak var lbl_CardType: UILabel!
    @IBOutlet weak var lbl_CardNumber: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
