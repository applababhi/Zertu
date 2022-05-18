//
//  EachProductDetailVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 12/14/21.
//  Copyright © 2021 Shalini Sharma. All rights reserved.
//

import UIKit
import SDWebImageWebPCoder

protocol UpdateTheTiendaListWithCounter
{
    func updateTheDictAtIndex(id:Int, dict:[String:Any])
}

class EachProductDetailVC: UIViewController {
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDesc:UITextView!
    @IBOutlet weak var imgV:UIImageView!
    @IBOutlet weak var btnLink:UIButton!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    var strTitle = ""
    var strDesc = ""
    
    var d_ToUpdate:[String:Any] = [:]
    var delegate:UpdateTheTiendaListWithCounter!
    
  //  var btnHTML:String = ""
 //   var isPDF = false
 //   var extensionStr = ""
    
    var strDescription:NSAttributedString!
    var RowHeightDescription:CGFloat = 0
    var strImgUrl = ""
 //   var bookIsFree = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // below 2 lines used because in this screen we are getting image extension as  webP
        let WebPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(WebPCoder)

        setUpTopBar()
        
        btnLink.layer.cornerRadius = 20.0
        btnLink.layer.borderWidth = 0.6
        btnLink.layer.masksToBounds = true
        
        lblTitle.text = strTitle
                
        if strImgUrl.contains("webp") == true{
            imgV.sd_setImage(with: NSURL(string: strImgUrl) as URL?)
        }
        else{
            imgV.setImageUsingUrl(strImgUrl)
        }
        
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
    
    @IBAction func btnAddToCartClick(btn:UIButton)
    {
        var count = 0
        var quantity_InStock = 0
        
        if let quant:Int = d_ToUpdate["stock_quantity"] as? Int
        {
            quantity_InStock = quant
            if quant == 0
            {
                self.showAlertWithTitle(title: "Alerta", message: "No hay artículos en stock", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
        }
        else{
            self.showAlertWithTitle(title: "Alerta", message: "No hay artículos en stock", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        
        if let cou:Int = d_ToUpdate["counter"] as? Int
        {
            count = cou
        }
        
        if count == quantity_InStock
        {
            self.showAlertWithTitle(title: "Alerta", message: "Cantidad máxima alcanzada", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        
        count = count + 1
        
        d_ToUpdate["counter"] = count
                
        // Adding to Cart here
        var selectedProduct_Id:Int = 0
        
        if let id: Int = d_ToUpdate["id"] as? Int
        {
            selectedProduct_Id = id
        }
                
        if k_helper.arrCart_products_InTiendaScreen.count > 0
        {
            var foundIndex:Int!
            var checkIfSameItemExistInCart = false
            for index in 0..<k_helper.arrCart_products_InTiendaScreen.count
            {
                let dic:[String:Any] = k_helper.arrCart_products_InTiendaScreen[index]
                if let idProd: Int = dic["id"] as? Int
                {
                    if idProd == selectedProduct_Id
                    {
                        foundIndex = index
                        checkIfSameItemExistInCart = true
                    }
                }
            }
            
            if checkIfSameItemExistInCart == false{
                k_helper.arrCart_products_InTiendaScreen.append(d_ToUpdate)
            }
            else
            {
                // repeated case
                k_helper.arrCart_products_InTiendaScreen[foundIndex] = d_ToUpdate
            }
        }
        else{
            k_helper.arrCart_products_InTiendaScreen.append(d_ToUpdate)
        }
        
        if let idFound:Int = d_ToUpdate["id"] as? Int
        {
            delegate.updateTheDictAtIndex(id: idFound, dict: d_ToUpdate)
        }

        
        let alert = UIAlertController(title: "Zertú", message: "Carrito actualizado con éxito", preferredStyle: .alert)
            
             let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                 self.navigationController?.popViewController(animated: true)
             })
             alert.addAction(ok)
        
             DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
        })
    }
}

extension EachProductDetailVC
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
