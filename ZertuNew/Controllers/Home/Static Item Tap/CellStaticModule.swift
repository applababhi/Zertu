//
//  CellStaticModule.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 8/2/21.
//  Copyright © 2021 Shalini Sharma. All rights reserved.
//

import UIKit

class CellStaticModule: UITableViewCell {

    @IBOutlet weak var lblHeader:UILabel!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblSubTitle:UILabel!
    @IBOutlet weak var btn:UIButton!
    @IBOutlet weak var imgTick:UIImageView!
    @IBOutlet weak var vBK:UIView!
    @IBOutlet weak var lblViewDetail:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
