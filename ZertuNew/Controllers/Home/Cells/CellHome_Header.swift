//
//  CellHome_Header.swift
//  home
//
//  Created by Abhishek Visa on 28/11/19.
//  Copyright © 2019 Shalini. All rights reserved.
//

import UIKit

class CellHome_Header: UITableViewCell {

    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet var carousel:iCarousel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
