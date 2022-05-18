//
//  CellProductList.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 30/12/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit

class CellProductList: UITableViewCell {

    @IBOutlet weak var vBk:UIView!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var lblStrike:UILabel!
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var lbl_InStock:UILabel!
    @IBOutlet weak var btnViewDetail:UIButton!
    @IBOutlet weak var vCounter:UIView!
    @IBOutlet weak var btnMinus:UIButton!
    @IBOutlet weak var btnPlus:UIButton!
    @IBOutlet weak var lblCount:UILabel!
    @IBOutlet weak var btnAddToCart:UIButton!
    @IBOutlet weak var c_lblStrike_Ht:NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
