//
//  OnboardingScenes.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 19/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit

class OnboardingScenes: UIView {
    
    @IBOutlet var vwContent: UIView!
    @IBOutlet var txtDescription: UITextView!
    @IBOutlet var lblTitle: UILabel!
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    convenience init(titleText: String, strDesc: String) {
        self.init()
        lblTitle.text = titleText
        txtDescription.text = strDesc
    }
    
    fileprivate func initWithNib() {
        Bundle.main.loadNibNamed("OnboardingScenes", owner: self, options: nil)
        vwContent.frame = bounds
        vwContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(vwContent)
    }
}
