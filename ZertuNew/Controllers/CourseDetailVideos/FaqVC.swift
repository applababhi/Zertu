//
//  FaqVC.swift
//  Test
//
//  Created by Abhishek Visa on 4/12/19.
//  Copyright © 2019 Shalini. All rights reserved.
//

import UIKit
import WebKit
class FaqVC: UIViewController {
    
    @IBOutlet weak var vContainer:UIView!
    @IBOutlet weak var imgBK:UIImageView!
    @IBOutlet weak var btnBk:UIButton!
    
    var strHTML:String = ""
    var imgWindow:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgBK.image = imgWindow
        
        btnBk.layer.cornerRadius = 20.0
        btnBk.layer.borderColor = UIColor.white.cgColor
        btnBk.layer.borderWidth = 2.0
        btnBk.layer.masksToBounds = true
        vContainer.layer.cornerRadius = 3.0
        vContainer.layer.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpWebView()
    }
    
    func setUpWebView()
    {
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: vContainer.frame.size.width, height: vContainer.frame.size.height))
        webView.loadHTMLString(strHTML, baseURL: nil)
//        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        self.vContainer.addSubview(webView)
    }
    
    @IBAction func btnBackClick(btn:UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FaqVC
{
    // MARK: - Lock Orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return .portrait
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        print("--> iPAD Screen Orientation")
        if UIDevice.current.orientation.isLandscape {
            print("landscape")
        } else {
            print("portrait")
        }
    }
}
