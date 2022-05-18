//
//  TermsPolicyVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 19/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit
import WebKit

class TermsPolicyVC: UIViewController {

    @IBOutlet weak var viewBk:UIView!
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBk.layer.cornerRadius = 6.0
        viewBk.layer.masksToBounds = true
        
        do {
            guard let filePath = Bundle.main.path(forResource: "policy", ofType: "docx")
                else {
                    // File Error
                    print ("File reading error")
                    return
            }
            
            let baseUrl = URL(fileURLWithPath: filePath)
    
            webView = WKWebView(frame: CGRect(x: 0, y: 0, width: viewBk.frame.size.width, height: viewBk.frame.size.height))
            webView.loadFileURL(baseUrl, allowingReadAccessTo: baseUrl)
            let request = URLRequest(url: baseUrl)
            webView.load(request)
            self.viewBk.addSubview(webView)
        }
        catch {
            print ("File HTML error")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    @IBAction func btn_BackClicked(btn:UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

extension TermsPolicyVC
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
