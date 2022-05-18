
//
//  Cell_Course DetailDownload.swift
//  Zertu
//
//  Created by Shalini Sharma on 17/9/18.
//  Copyright © 2018 Abhishek Bhardwaj. All rights reserved.
//

import UIKit

class Cell_Course_DetailDownload: UITableViewCell {

  //  @IBOutlet weak var lbl_MastersTitle:UILabel!
    @IBOutlet weak var btnDownload:ButtonDownload!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class ButtonDownload:UIButton
{
    var downloadUrl:String = ""
}
