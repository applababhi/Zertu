//
//  CellTicket.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 23/4/20.
//  Copyright © 2020 Shalini Sharma. All rights reserved.
//

import UIKit

class CellTicket: UITableViewCell {

    @IBOutlet weak var vBk:UIView!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblReceipt:UILabel!
    @IBOutlet weak var lblAmount:UILabel!
    @IBOutlet weak var imgV:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
