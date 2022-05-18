//
//  CellBusiness_TF.swift
//  Zertu
//
//  Created by Shalini Sharma on 7/11/19.
//  Copyright © 2019 Abhishek Bhardwaj. All rights reserved.
//

import UIKit

class CellBusiness_TF: UITableViewCell {

    @IBOutlet weak var lbl:UILabel!
    @IBOutlet weak var tf:UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func inCellAddLeftPaddingTo(TextField:UITextField)
    {
        let viewT = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        viewT.backgroundColor = .clear
        
        TextField.leftViewMode = UITextField.ViewMode.always
                
        TextField.leftView = viewT
    }
}
