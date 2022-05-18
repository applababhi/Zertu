//
//  CheckoutCartVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 12/16/21.
//  Copyright © 2021 Shalini Sharma. All rights reserved.
//

import UIKit

class CheckoutCartVC: UIViewController {
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    var arrFields:[[String:Any]] = []
    var finalDict:[String:Any] = [:]
    var maskedCard = ""
    var total_Price = 0
    var full_Address = ""
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupArray()
        setUpTopBar()
    }
    
    func setupArray()
    {
        // calculate total value
        // also create one address string \n
        
        for dict in k_helper.arrCart_products_InTiendaScreen
        {
            arrFields.append(["title":"Row"])
            
            if let str_Reg:String = dict["regular_price"] as? String
            {
                var strRegularPrice:String = str_Reg
                
                if let sale:String = dict["sale_price"] as? String
                {
                    if sale != ""
                    {
                        strRegularPrice = sale
                    }
                }
                
                total_Price = total_Price + Int(strRegularPrice)!
            }
        }
        
        arrFields.insert(["title":"header 2"], at: 0)
        arrFields.insert(["title":"header 1"], at: 0)
        arrFields.append(["title":"Total"])
        arrFields.append(["title":"Card"])
        arrFields.append(["title":"Address"])
        arrFields.append(["title":"Pay"])
        
        
        if let nombre:String = finalDict["nombre"] as? String
        {
            if let apellido:String = finalDict["apellido"] as? String
            {
                if let direccion:String = finalDict["direccion"] as? String
                {
                    if let estado:String = finalDict["estado"] as? String
                    {
                        if let ciudad:String = finalDict["ciudad"] as? String
                        {
                            if let codigoPostal:String = finalDict["codigoPostal"] as? String
                            {
                                if let correo:String = finalDict["correo"] as? String
                                {
                                    if let telefono:String = finalDict["telefono"] as? String
                                    {
                                        full_Address = "Dirección de entrega: \n \n" + nombre + "\n" + apellido + "\n" + direccion + "\n" + estado + "\n" + ciudad + "\n" + codigoPostal + "\n" + correo + "\n" + telefono + "\n"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        self.tblView.delegate = self
        self.tblView.dataSource = self
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

extension CheckoutCartVC
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

extension CheckoutCartVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrFields.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let dict:[String:Any] = arrFields[indexPath.row]
        var strType = ""
        if let str:String = dict["title"] as? String
        {
            strType = str
        }
        
        if strType == "header 1"
        {
            return 35
        }
        else if strType == "header 2"
        {
            return 35
        }
        else if strType == "Row"
        {
            return 40
        }
        else if strType == "Total"
        {
            return 35
        }
        else if strType == "Card"
        {
            return 35
        }
        else if strType == "Address"
        {
            return 185
        }
        else if strType == "Pay"
        {
            return 60
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict:[String:Any] = arrFields[indexPath.row]
        var strType = ""
        if let str:String = dict["title"] as? String
        {
            strType = str
        }
        
        if strType == "header 1"
        {
            let cell:CellCheckout_Header1 = tblView.dequeueReusableCell(withIdentifier: "CellCheckout_Header1", for: indexPath) as! CellCheckout_Header1
            cell.selectionStyle = .none
            
            return cell
        }
        else if strType == "header 2"
        {
            let cell:CellCheckout_Header2 = tblView.dequeueReusableCell(withIdentifier: "CellCheckout_Header2", for: indexPath) as! CellCheckout_Header2
            cell.selectionStyle = .none
            
            return cell
        }
        else if strType == "Row"
        {
            let cell:CellCheckout_Rows = tblView.dequeueReusableCell(withIdentifier: "CellCheckout_Rows", for: indexPath) as! CellCheckout_Rows
            cell.selectionStyle = .none
            let dict_Row:[String:Any] = k_helper.arrCart_products_InTiendaScreen[indexPath.row - 2]
            
            cell.lbl_1.text = ""
            cell.lbl_2.text = ""
            cell.lbl_3.text = ""
            
            if let str:String = dict_Row["name"] as? String
            {
                cell.lbl_1.text = str
            }
            if let str_Reg:String = dict_Row["regular_price"] as? String
            {
                
                let strRegularPrice = str_Reg
                
                if let str:String = dict_Row["sale_price"] as? String
                {
                    cell.lbl_3.text = "$\(str)"
                    //    strSalePrice = str
                    
                    if str == ""
                    {
                        cell.lbl_3.text = "$\(strRegularPrice)"
                    }
                }
                else
                {
                    cell.lbl_3.text = "$\(strRegularPrice)"
                }
            }
            
            if let count:Int = dict_Row["counter"] as? Int
            {
                cell.lbl_2.text = "\(count)"
            }
            
            return cell
        }
        else if strType == "Total"
        {
            let cell:CellCheckout_Total = tblView.dequeueReusableCell(withIdentifier: "CellCheckout_Total", for: indexPath) as! CellCheckout_Total
            cell.selectionStyle = .none
            
            cell.lblTitle.text = "Total:   $" + "\(total_Price)"
            return cell
        }
        else if strType == "Card"
        {
            let cell:CellCheckout_Card = tblView.dequeueReusableCell(withIdentifier: "CellCheckout_Card", for: indexPath) as! CellCheckout_Card
            cell.selectionStyle = .none
            
            cell.lblTitle.text = maskedCard
            return cell
        }
        else if strType == "Address"
        {
            let cell:CellCheckout_Address = tblView.dequeueReusableCell(withIdentifier: "CellCheckout_Address", for: indexPath) as! CellCheckout_Address
            cell.selectionStyle = .none
            
            cell.lblTitle.text = full_Address
            return cell
        }
        else if strType == "Pay"
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
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func ContinueClick()
    {
        callPayApi()
    }
}

extension CheckoutCartVC
{
    func callPayApi()
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.CheckoutStore.rawValue
        let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        
        WebService.callApiWith(url: urlStr, method: .post, parameter: finalDict, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
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
                    if let msg:String = json["response"] as? String
                    {
                        DispatchQueue.main.async {
                            self.showAlertWithTitle(title: "Zertu", message: msg, okButton: "Ok", cancelButton: "", okSelectorName: #selector(self.refresh))
                            return
                        }
                    }
                }
                else{
                    DispatchQueue.main.async {
                        if let msg:String = json["response"] as? String
                        {
                            self.showAlertWithTitle(title: "Error", message: msg, okButton: "Ok", cancelButton: "", okSelectorName: nil)
                            return
                        }
                    }
                }
            }
        }
    }
    
    @objc func refresh()
    {
        k_helper.arrCart_products_InTiendaScreen.removeAll()
        self.navigationController?.popToRootViewController(animated: true)
    }
}
