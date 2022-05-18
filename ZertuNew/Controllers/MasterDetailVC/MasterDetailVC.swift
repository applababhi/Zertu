//
//  MasterDetailVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 10/1/20.
//  Copyright © 2020 Shalini Sharma. All rights reserved.
//

import UIKit

class MasterDetailVC: UIViewController {
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDesc:UITextView!
    @IBOutlet weak var imgV:UIImageView!
    @IBOutlet weak var btnLink:UIButton!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    var strTitle = ""
    var strDesc = ""
    
    var btnHTML:String = ""
    var isPDF = false
    var extensionStr = ""
    
    var strDescription:NSAttributedString!
    var RowHeightDescription:CGFloat = 0
    var strImgUrl = ""
    var bookIsFree = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if btnHTML == ""
        {
            btnLink.isHidden = true
        }
        else
        {
            if isPDF == true
            {
                // change button title and navigate to show pdf
                btnLink.setTitle("Descargar", for: .normal)
            }
            else
            {
                // change button title and navigate to external browser
                
                
                if bookIsFree == true
                {
                    btnLink.setTitle("Descargar", for: .normal)
                }
                else
                {
                    // Not free
                    btnLink.setTitle("Ir al sitio de compra", for: .normal)
                }
                
                
            }
        }
        
        setUpTopBar()
        
        btnLink.layer.cornerRadius = 10.0
        btnLink.layer.masksToBounds = true
        
        lblTitle.text = strTitle
        
        imgV.setImageUsingUrl(strImgUrl)
        
        let attributes = [NSAttributedString.Key.font: UIFont(name: CustomFont.GSLRegular, size: 20)!,
                          NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        
        self.strDescription = NSAttributedString(string: strDesc.htmlToString, attributes: attributes)
        
        let height = strDesc.heightWithConstrainedWidth(UIScreen.main.bounds.width - 15, font: UIFont.boldSystemFont(ofSize: 17.0))
        RowHeightDescription = height! + 40
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lblDesc.attributedText = self.strDescription
        // c_lDesc_Ht.constant = RowHeightDescription
    }
    
    func setUpTopBar()
    {
        lblTitle.font = UIFont(name: CustomFont.GSLRegular, size: 19.0)
        
        let strModel = getDeviceModel()
        if strModel == "iPhone XS"
        {
            c_TopBar_Ht.constant = 90
        }
        else if strModel == "iPhone Max"
        {
            c_TopBar_Ht.constant = 90
        }
        else if strModel == "iPhone 5"
        {
            lblTitle.font = UIFont(name: CustomFont.GSLRegular, size: 17.0)
        }
        else if strModel == "iPhone 6"
        {
            lblTitle.font = UIFont(name: CustomFont.GSLRegular, size: 18.0)
        }
        else
        {
            // UNKNOWN CASE - Like iPhone 11 or XR
            c_TopBar_Ht.constant = 90
        }
    }
    
    @IBAction func btnBackClick(btn:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnLinkClick(btn:UIButton)
    {
        let encodedPath = btnHTML.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        if let url = URL(string: encodedPath ?? "") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
        /*
        if isPDF == true
        {
            // change button title and navigate to show pdf
            let vc:ShowPDFVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "ShowPDFVC_ID") as! ShowPDFVC
            vc.strTitle = self.strTitle
            vc.pdfFilePath = self.btnHTML
            vc.strExtension = self.extensionStr
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            // change button title and navigate to external browser
            if let url = URL(string: btnHTML) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
        }
        */
    }
}

extension MasterDetailVC
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
