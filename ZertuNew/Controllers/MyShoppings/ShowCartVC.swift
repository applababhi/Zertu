//
//  ShowCartVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 12/14/21.
//  Copyright © 2021 Shalini Sharma. All rights reserved.
//

import UIKit
import SDWebImageWebPCoder

class ShowCartVC: UIViewController {
        
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    var delegate:UpdateTheTiendaListWithCounter!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // below 2 lines used because in this screen we are getting image extension as  webP
        let WebPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(WebPCoder)

        self.tblView.delegate = self
        self.tblView.dataSource = self
        setUpTopBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    func setUpTopBar()
    {
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

        }
        else if strModel == "iPhone 6"
        {

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
}

extension ShowCartVC
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

extension ShowCartVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return k_helper.arrCart_products_InTiendaScreen.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == k_helper.arrCart_products_InTiendaScreen.count
        {
            // last row
            return 60
        }
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == k_helper.arrCart_products_InTiendaScreen.count
        {
            // last row
            let cell:Cell_AddNewCard = tblView.dequeueReusableCell(withIdentifier: "Cell_AddNewCard", for: indexPath) as! Cell_AddNewCard
            cell.selectionStyle = .none
            cell.btn_AddNewCard.layer.cornerRadius = 20.0
            cell.btn_AddNewCard.layer.borderWidth = 0.6
            cell.btn_AddNewCard.layer.masksToBounds = true
            
            cell.btn_AddNewCard.addTarget(self, action: #selector(self.ContinueClick), for: .touchUpInside)
            return cell
        }
        
        let dict:[String:Any] = k_helper.arrCart_products_InTiendaScreen[indexPath.row]
        let cell:CellProductList = tblView.dequeueReusableCell(withIdentifier: "CellProductList", for: indexPath) as! CellProductList
        cell.selectionStyle = .none

        cell.lblName.text = ""
        cell.lblPrice.text = ""
        cell.lblCount.text = ""
        cell.imgView.image = nil
        cell.imgView.contentMode = .scaleAspectFit
        
        cell.vCounter.layer.cornerRadius = 5.0
        cell.vCounter.layer.borderWidth = 0.5
        cell.vCounter.layer.borderColor = UIColor.black.cgColor
        cell.vCounter.layer.masksToBounds = true
                
        cell.btnMinus.tag = indexPath.row
        cell.btnPlus.tag = indexPath.row
        
        var strRegularPrice = ""
        
        if let str:String = dict["name"] as? String
        {
            cell.lblName.text = str
        }
        if let str_Reg:String = dict["regular_price"] as? String
        {
            strRegularPrice = str_Reg
                        
            if let str:String = dict["sale_price"] as? String
            {
                cell.lblPrice.text = "$\(str)"
                
                if str == ""
                {
                    cell.lblPrice.text = "$\(strRegularPrice)"
                }
            }
            else
            {
                cell.lblPrice.text = "$\(strRegularPrice)"
            }
        }
        
        if let count:Int = dict["counter"] as? Int
        {
            cell.lblCount.text = "\(count)"
        }
        
        if let arrImg:[[String:Any]] = dict["images"] as? [[String:Any]]
        {
            cell.imgView.image = UIImage(named: "ph")
            
            if arrImg.count > 0
            {
                let di:[String:Any] = arrImg.first!
               
                if let imgStr:String = di["src"] as? String
                {
                    if imgStr.contains("webp") == true{
                        cell.imgView.sd_setImage(with: NSURL(string: imgStr) as URL?)
                    }
                    else{
                        cell.imgView.setImageUsingUrl(imgStr)
                    }
                }
            }
        }
        
        cell.btnMinus.addTarget(self, action: #selector(self.btnMinus_Clicked(btn:)), for: .touchUpInside)
        cell.btnPlus.addTarget(self, action: #selector(self.btnPlus_Clicked(btn:)), for: .touchUpInside)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    @objc func btnPlus_Clicked(btn:UIButton)   // ADD TO CART
    {
        var count = 0
        var d_ToUpdate:[String:Any] = k_helper.arrCart_products_InTiendaScreen[btn.tag]
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
        k_helper.arrCart_products_InTiendaScreen[btn.tag] = d_ToUpdate
        
        if let idFound:Int = d_ToUpdate["id"] as? Int
        {
            delegate.updateTheDictAtIndex(id: idFound, dict: d_ToUpdate)
        }

        let indexPath = IndexPath(item: btn.tag, section: 0)
        tblView.reloadRows(at: [indexPath], with: .fade)
    }
    
    @objc func btnMinus_Clicked(btn:UIButton)
    {
        var count = 0
        var d:[String:Any] = k_helper.arrCart_products_InTiendaScreen[btn.tag]
        if let cou:Int = d["counter"] as? Int
        {
            count = cou
        }
        
        if count != 0
        {
            count = count - 1
            d["counter"] = count
                        
            if count == 0
            {
                k_helper.arrCart_products_InTiendaScreen.remove(at: btn.tag)
                tblView.reloadData()
                
                if let idFound:Int = d["id"] as? Int
                {
                    delegate.updateTheDictAtIndex(id: idFound, dict: d)
                }

                return
            }
                        
            k_helper.arrCart_products_InTiendaScreen[btn.tag] = d
            
            if let idFound:Int = d["id"] as? Int
            {
                delegate.updateTheDictAtIndex(id: idFound, dict: d)
            }
            
            let indexPath = IndexPath(item: btn.tag, section: 0)
            tblView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    @objc func ContinueClick()
    {
        if k_helper.arrCart_products_InTiendaScreen.count > 0
        {
            for index in 0..<k_helper.arrCart_products_InTiendaScreen.count
            {
                var di:[String:Any] = k_helper.arrCart_products_InTiendaScreen[index]
                
                if let cou:Int = di["counter"] as? Int
                {
                    di["quantity"] = cou
                }
                
                k_helper.arrCart_products_InTiendaScreen[index] = di
                
                if index == k_helper.arrCart_products_InTiendaScreen.count - 1
                {
                    self.callServerToGetLinkedCards()
                    
                    print("Proceed to Add Address.........")
                }
            }
        }
        else{
            let alert = UIAlertController(title: "Zertú", message: "Ningún producto en el carrito", preferredStyle: .alert)
                
                 let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                     self.navigationController?.popViewController(animated: true)
                 })
                 alert.addAction(ok)
            
                 DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true)
            })
        }
    }
}

// fetch deffault payment card
extension ShowCartVC
{
    func callServerToGetLinkedCards()
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.userCardList.rawValue
        let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        
        WebService.callApiWith(url: urlStr, method: .get, parameter: nil, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
            print(jsonStr)
            self.hideSpinner()
            
            if error != nil
            {
                self.showAlertWithTitle(title: "Alerta", message: "\(error!.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
                        
            if let code:Int = json["code"] as? Int
            {
                if code >= 200 && code < 300
                {
                    if let arr:[[String:Any]] = json["response"] as? [[String:Any]]
                    {
                        DispatchQueue.main.async {
                            var token:String = ""
                            var maskedCard = ""
                            
                            for index in 0..<arr.count
                            {
                                let dict:[String:Any] = arr[index]
                                if let check:Bool = dict["defaultMethod"] as? Bool
                                {
                                    if check == true
                                    {
                                        // Default Card ID
                                        if let str:String = dict["id"] as? String
                                        {
                                            token = str
                                        }
                                        if let str:String = dict["maskedNumber"] as? String
                                        {
                                            maskedCard = "**** " + str.components(separatedBy: "-").last!
                                        }
                                    }
                                    else
                                    {
                                    }
                                }
                            }
                            
                            let vc:AddAddress_CartVC = AppStoryboards.More.instance.instantiateViewController(identifier: "AddAddress_CartVC_ID") as! AddAddress_CartVC
                            vc.maskedCard = maskedCard
                            vc.token = token
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
        }
    }
}
