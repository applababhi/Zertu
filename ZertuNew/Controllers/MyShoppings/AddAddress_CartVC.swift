//
//  AddAddress_CartVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 12/16/21.
//  Copyright © 2021 Shalini Sharma. All rights reserved.
//

import UIKit

class AddAddress_CartVC: UIViewController {
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    var arrFields:[[String:Any]] = [["title":"Dirección", "value":"", "key":"direccion"], ["title":"Estado", "value":"", "key":"estado"], ["title":"Ciudad/Municipio", "value":"", "key":"ciudad"], ["title":"Código postal", "value":"", "key":"codigoPostal"], ["title":"Nombre de la persona que recibe", "value":"", "key":"nombre"], ["title":"Apellido de la persona que recibe", "value":"", "key": "apellido"], ["title":"Correo", "value":"", "key":"correo"], ["title":"Teléfono", "value":"", "key":"telefono"]]
    
    var token = ""
    var maskedCard = ""
    
    var finalDict:[String:Any] = [:]
    /*
    {
        "nombre": "ANDRES",
        "apellido": "TORRES",
        "": "14140",
        "": "CDMX",
        "": "CDMX",
        "products": [],
        "": "Fuente Cantos 25",
        "token": "src_2qr7y1Xrkp8sh1x7D",
        "": "andxtorres22@gmail.com",
        "": "5541302205"
    }
    */
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
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

extension AddAddress_CartVC
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

extension AddAddress_CartVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrFields.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == arrFields.count
        {
            // last row
            return 60
        }
        return 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == arrFields.count
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
        
        let dict:[String:Any] = arrFields[indexPath.row]
        let cell:CellAddAddress = tblView.dequeueReusableCell(withIdentifier: "CellAddAddress", for: indexPath) as! CellAddAddress
        cell.selectionStyle = .none

        cell.lblTitle.text = ""
        cell.tf.text = ""
        cell.tf.delegate = self
        cell.tf.tag = indexPath.row
        
        cell.tf.keyboardType = .default
        
        if indexPath.row == 3 || indexPath.row == 7
        {
            // POSTAL CODe
            cell.tf.keyboardType = .numberPad
        }
        
        if let str:String = dict["title"] as? String
        {
            cell.lblTitle.text = str
        }
        
        if let str:String = dict["value"] as? String
        {
            cell.tf.text = str
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @objc func ContinueClick()
    {
        var check_IfAnyFieldEmoty = false
        for d in arrFields
        {
            if let value:String = d["value"] as? String
            {
                if value == ""
                {
                    check_IfAnyFieldEmoty = true
                    break
                }
            }
        }
        
        if check_IfAnyFieldEmoty == false
        {
            // create final dict
            finalDict["token"] = token
            finalDict["products"] = k_helper.arrCart_products_InTiendaScreen
            
            for di in arrFields
            {
                if let ke:String = di["key"] as? String
                {
                    if let val:String = di["value"] as? String
                    {
                        finalDict[ke] = val
                    }
                }
            }
            
            print("Proceed to ORDER Summary......... ")
            let vc:CheckoutCartVC = AppStoryboards.More.instance.instantiateViewController(identifier: "CheckoutCartVC_ID") as! CheckoutCartVC
            vc.maskedCard = maskedCard
            vc.finalDict = finalDict
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            let alert = UIAlertController(title: "Zertú", message: "Algún campo está vacío", preferredStyle: .alert)
                
                 let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                     
                 })
                 alert.addAction(ok)
            
                 DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true)
            })
        }
    }
}

extension AddAddress_CartVC: UITextFieldDelegate
{
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        var dict:[String:Any] = arrFields[textField.tag]
        dict["value"] = textField.text!
        arrFields[textField.tag] = dict
        
        tblView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
