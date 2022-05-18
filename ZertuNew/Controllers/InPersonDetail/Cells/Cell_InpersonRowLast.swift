//
//  Cell_InpersonRowLast.swift
//  Zertu
//
//  Created by Abhishek Bhardwaj on 12/6/18.
//  Copyright © 2018 Abhishek Bhardwaj. All rights reserved.
//

import UIKit


class Cell_InpersonRowLast: UITableViewCell {

    @IBOutlet weak var view_PlusMinus: UIView!
    @IBOutlet weak var lbl_NumberOfPersons: UILabel!
    @IBOutlet weak var btn_Plus: UIButton!
    @IBOutlet weak var btn_Minus: UIButton!
    @IBOutlet weak var btn_Conekta: UIButton!
    @IBOutlet weak var btn_PayPal: UIButton!
    @IBOutlet weak var btn_Oxxo: UIButton!
  // @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var lbl_Price: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
