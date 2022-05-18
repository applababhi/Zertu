//
//  CellMusicList.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 31/12/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit

class CellMusicList: UITableViewCell {

    @IBOutlet weak var vBk:UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
