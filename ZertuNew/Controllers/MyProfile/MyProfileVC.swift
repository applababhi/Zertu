//
//  MyProfileVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 22/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit
import Floaty

class MyProfileVC: UIViewController {

    @IBOutlet weak var txtFld_Name:UITextField!
    @IBOutlet weak var txtFld_Email:UITextField!
    @IBOutlet weak var txtFld_Password:UITextField!
    @IBOutlet weak var txtFld_ConPassword:UITextField!
    @IBOutlet weak var btnUpdate:UIButton!
    @IBOutlet weak var tblView:UITableView!

    var floaty = Floaty()
    
    var arrCards:[[String:Any]] = []
    var dictProfile:[String:Any] = [:]
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFloatingButton()
        hideKeyboardWhenTappedAround()
        setTFs()
        
        btnUpdate.layer.cornerRadius = 20.0
        btnUpdate.layer.masksToBounds = true
        
        tblView.delegate = self
        tblView.dataSource = self
        
        checkSkipCase()
    }
    
    func checkSkipCase()
    {
        if isUserTappedSkipButton == true
        {
            // SHOW PopUp and ask to Login
            let alert = UIAlertController(title: "Zertú", message: "Estimado invitado, inicie sesión o regístrese para usar esta función de la aplicación Zertú", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Iniciar sesión", style: .default, handler: { action in
                DispatchQueue.main.async(execute: {
                    let vc:LoginVC = AppStoryboards.Login.instance.instantiateViewController(withIdentifier: "LoginVC_ID") as! LoginVC
                    k_window.rootViewController = vc
                    
                })
            })
            alert.addAction(ok)
            let cancel = UIAlertAction(title: "Cancelar", style: .default, handler: { action in
                self.tabBarController?.selectedIndex = 1
            })
            alert.addAction(cancel)
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
        }
    }
    
    func setTFs(){
        
        txtFld_Name.backgroundColor = .clear
        txtFld_Email.backgroundColor = .clear
        txtFld_Password.backgroundColor = .clear
        txtFld_ConPassword.backgroundColor = .clear

        txtFld_Password.isSecureTextEntry = true
        txtFld_ConPassword.isSecureTextEntry = true
        
        txtFld_Name.delegate = self
        txtFld_Email.delegate = self
        txtFld_Password.delegate = self
        txtFld_ConPassword.delegate = self
        addLeftPaddingTo(tf: txtFld_Name)
        addLeftPaddingTo(tf: txtFld_Email)
        addLeftPaddingTo(tf: txtFld_Password)
        addLeftPaddingTo(tf: txtFld_ConPassword)
        
        txtFld_Name.placeholder = "Nombre"
        txtFld_Email.placeholder = "Correo"
        txtFld_Password.placeholder = "Nueva contraseña"
        txtFld_ConPassword.placeholder = "Confirmar nueva conraseña"
        
        txtFld_Name.font = UIFont(name: "STHeitiTC-Light", size: 18)
        txtFld_Email.font = UIFont(name: "STHeitiTC-Light", size: 18)
        txtFld_Password.font = UIFont(name: "STHeitiTC-Light", size: 18)
        txtFld_ConPassword.font = UIFont(name: "STHeitiTC-Light", size: 18)

        setTextfieldsBorder(color: k_baseColor, tf: txtFld_Name)
        setTextfieldsBorder(color: k_baseColor, tf: txtFld_Password)
        setTextfieldsBorder(color: k_baseColor, tf: txtFld_ConPassword)
        setTextfieldsBorder(color: k_baseColor, tf: txtFld_Email)
    }
    
    func setTextfieldsBorder(color:UIColor, tf:UITextField)
    {
        tf.layer.borderColor = color.cgColor
        tf.layer.borderWidth = 1.0
        tf.layer.cornerRadius = 5.0
        tf.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.floaty.isHidden = false
        
        if k_helper.isNetworkAvailable == "Available"
        {
            callServerToGetLinkedCards()
        }
        else
        {
            DispatchQueue.main.async {
                self.showAlertWithTitle(title: "Alerta", message: "No hay conexión a internet disponible", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            }
        }
    }
    
    @IBAction func btn_UpdateProfileClicked(btn:UIButton)
    {
        print("Update Profile")
        self.view.endEditing(true)
        
        guard let strName:String = txtFld_Name.text, strName.isEmpty == false else
        {
            self.showAlertWithTitle(title: "Alerta", message: "Por favor ingrese un nombre", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        
        guard let strPass:String = txtFld_Password.text, strPass.isEmpty == false else
        {
            self.showAlertWithTitle(title: "Alerta", message: "Por favor, ingrese contraseña", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        if txtFld_Password.text != txtFld_ConPassword.text
        {
            self.showAlertWithTitle(title: "Alerta", message: "Las contraseñas introducidas no coinciden", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        else
        {
            callServerToUpdateWith(name: strName, password: strPass)
        }
    }
    
}

extension MyProfileVC
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

extension MyProfileVC: FloatyDelegate
{
    func floatyWillOpen(_ floaty: Floaty) {
      print("Floaty Will Open")
    }
    
    func floatyDidOpen(_ floaty: Floaty) {
      print("Floaty Did Open")
    }
    
    func floatyWillClose(_ floaty: Floaty) {
      print("Floaty Will Close")
    }
    
    func floatyDidClose(_ floaty: Floaty) {
      print("Floaty Did Close")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("- - here Dismiss the Floating Button - -")
        floaty.close()
    }
    
// MARK: - Floaty Button Method
    
    func setupFloatingButton()
    {
        let item1 = FloatyItem()
        item1.buttonColor = k_baseColor
        item1.circleShadowColor = UIColor.white
        item1.titleShadowColor = UIColor.white
        item1.title = "Tienda"
        item1.icon = UIImage(named: "cartWhite")
        item1.handler = { item in
            print("- open Tienda VC -")
            DispatchQueue.main.async {
                self.floaty.isHidden = true
                self.callGetProducts_Tienda()
            }
        }
        let item2 = FloatyItem()
        item2.buttonColor = k_baseColor
        item2.circleShadowColor = UIColor.white
        item2.titleShadowColor = UIColor.white
        item2.title = "EMPRESAS"
        item2.icon = UIImage(named: "business")
        item2.handler = { item in
            print("- open EMPRESAS VC -")
            DispatchQueue.main.async {
                
                self.floaty.isHidden = true
                
                let vc:BusinessVC = AppStoryboards.More.instance.instantiateViewController(identifier: "BusinessVC_ID") as! BusinessVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        let item3 = FloatyItem()
        item3.buttonColor = k_baseColor
        item3.circleShadowColor = UIColor.white
        item3.titleShadowColor = UIColor.white
        item3.title = "Música"
        item3.icon = UIImage(named: "music")
        item3.handler = { item in
            print("- open Música VC -")
            DispatchQueue.main.async {
            self.floaty.isHidden = true
            let vc:MusicListVC = AppStoryboards.More.instance.instantiateViewController(identifier: "MusicListVC_ID") as! MusicListVC
            self.navigationController?.pushViewController(vc, animated: true)
            }
        }
                
        floaty.hasShadow = true
        floaty.buttonColor = UIColor(named: "CyanGreenBackground")!
        floaty.plusColor = UIColor.white
        
        floaty.addItem(item: item1)
//        floaty.addItem(item: item2)
        floaty.addItem(item: item3)
        
        floaty.paddingX = 20
        floaty.paddingY = 70
        
        floaty.fabDelegate = self
        
        self.navigationController?.view.addSubview(floaty)
    }
}

extension MyProfileVC: UITextFieldDelegate
{
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setTextfieldsBorder(color: .gray, tf: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setTextfieldsBorder(color: k_baseColor, tf: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        setTextfieldsBorder(color: k_baseColor, tf: textField)
        textField.resignFirstResponder()
        return true
    }
}

extension MyProfileVC: UITableViewDelegate, UITableViewDataSource
{
    // MARK: TableView protocols

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.arrCards.count + 1 // 1 for Add Card Footer
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == arrCards.count
        {
            // footer
            return 50
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == arrCards.count
        {
            // footer
            let footer:CellProfile_Footer = self.tblView.dequeueReusableCell(withIdentifier: "CellProfile_Footer") as! CellProfile_Footer
            footer.selectionStyle = .none
            
            footer.btnAddNewCard.layer.cornerRadius = 20.0
            footer.btnAddNewCard.layer.masksToBounds = true
            
            footer.btnAddNewCard.addTarget(self, action: #selector(self.addCard_Clicked(btn:)), for: .touchUpInside)
            
            return footer
        }

        let dict:[String:Any] = arrCards[indexPath.row]
        
        let cell:CellProfile_Cards = self.tblView.dequeueReusableCell(withIdentifier: "CellProfile_Cards") as! CellProfile_Cards
        cell.selectionStyle = .none
        
        cell.lblNumber.text = ""
        cell.imgViewTickDefault.isHidden = true
        cell.btnDelete.isHidden = true
        
        if let str:String = dict["maskedNumber"] as? String
        {
            cell.lblNumber.text = str
        }
        
        if let check:Bool = dict["defaultMethod"] as? Bool
        {
            if check == true
            {
                // show tick
                cell.imgViewTickDefault.isHidden = false
            }
            else
            {
                // show delete
                cell.btnDelete.isHidden = false
            }
        }
        
        cell.btnFullRow.tag = indexPath.row
        cell.btnFullRow.addTarget(self, action: #selector(self.fullRow_Clicked(btn:)), for: .touchUpInside)
        
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(self.deleteCard_Clicked(btn:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){}
    
    
    @objc func fullRow_Clicked(btn:UIButton)
    {
        var selectedID:String = ""
        let dictSel = arrCards[btn.tag]
        if let check:Bool = dictSel["defaultMethod"] as? Bool
        {
            if check == true
            {
                // just return as this is already a selected card
                return
            }
            
            if let cardId:String = dictSel["id"] as? String
            {
                selectedID = cardId
            }
        }
        
        let alertController = UIAlertController(title: "Zertu", message: "¿Quieres eliminar la tarjeta seleccionada?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "sí", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("Yes set default card -")
            self.callServerToSetDefaultCard(id: selectedID)
        }
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel- ")
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func deleteCard_Clicked(btn:UIButton)
    {
        var selectedID:String = ""
        let dictSel = arrCards[btn.tag]
        if let check:Bool = dictSel["defaultMethod"] as? Bool
        {
            if check == true
            {
                // means we do not need to uncheck the already true value
                return
            }
            
            if let cardId:String = dictSel["id"] as? String
            {
                selectedID = cardId
            }
        }
        
        let alertController = UIAlertController(title: "Zertu", message: "¿Desea configurar la tarjeta seleccionada como tarjeta predeterminada?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "sí", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("Yes Delete card")
            self.callServerToDeleteCard(id: selectedID)
        }
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel- -")
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func addCard_Clicked(btn:UIButton)
    {
        print("Navigate to Add Card")
        
        self.floaty.isHidden = true
        
        let vc:AddCardConektaVC = AppStoryboards.MyProfile.instance.instantiateViewController(identifier: "AddCardConektaVC_ID") as! AddCardConektaVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MyProfileVC
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
            
            self.arrCards.removeAll()
            self.tblView.reloadData()
            
            if let code:Int = json["code"] as? Int
            {
                if code >= 200 && code < 300
                {
                    if let arr:[[String:Any]] = json["response"] as? [[String:Any]]
                    {
                        self.arrCards = arr
                        
                        self.perform(#selector(self.callServerToGetProfile), with: nil, afterDelay: 0.1)
                        DispatchQueue.main.async {
                            self.tblView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @objc func callServerToGetProfile()
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.getUserProfile.rawValue
        let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        
        WebService.callApiWith(url: urlStr, method: .get, parameter: nil, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
          //  print(jsonStr)
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
                    if let d:[String:Any] = json["response"] as? [String:Any]
                    {
                        self.dictProfile = d
                        
                        DispatchQueue.main.async {
                            if let strName:String = self.dictProfile["name"] as? String
                            {
                                self.txtFld_Name.text = strName
                            }
                            if let strEmail:String = self.dictProfile["email"] as? String
                            {
                                self.txtFld_Email.text = strEmail
                            }
                        }
                    }
                }
            }
        }
    }
    
    func callServerToSetDefaultCard(id:String)
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.MakeCardDefault.rawValue
        let param:[String:Any] = ["paymentToken":id]
        let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        
        WebService.callApiWith(url: urlStr, method: .post, parameter: param, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
           // print(jsonStr)
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
                        self.viewWillAppear(true)
                        DispatchQueue.main.async {
                            self.showAlertWithTitle(title: "Zertu", message: msg, okButton: "Ok", cancelButton: "", okSelectorName: nil)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func callServerToDeleteCard(id:String)
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.DeleteCardDefault.rawValue
        let param:[String:Any] = ["paymentToken":id]
        print(param)
        let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        
        WebService.callApiWith(url: urlStr, method: .post, parameter: param, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
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
                        self.viewWillAppear(true)
                        DispatchQueue.main.async {
                            self.showAlertWithTitle(title: "Zertu", message: msg, okButton: "Ok", cancelButton: "", okSelectorName: nil)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func callServerToUpdateWith(name:String, password:String)
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.UpdateProfile.rawValue
        let param:[String:Any] = ["newPassword":password,"name" : name]
      //  print(param)
        let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        
        WebService.callApiWith(url: urlStr, method: .post, parameter: param, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
          //  print(jsonStr)
            self.hideSpinner()
            
            if error != nil
            {
                self.showAlertWithTitle(title: "Alerta", message: "\(error!.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
            
            DispatchQueue.main.async {
                self.txtFld_Password.text = ""
                self.txtFld_ConPassword.text = ""
            }
            
            if let code:Int = json["code"] as? Int
            {
                if code >= 200 || code < 300
                {
                    if let resp:String = json["response"] as? String
                    {
                        self.showAlertWithTitle(title: "Zertu", message: resp, okButton: "Ok", cancelButton: "", okSelectorName: nil)
                        return
                    }
                }
                else
                {
                    self.showAlertWithTitle(title: "Zertu", message: "Se produjo un error, por favor intente más tarde", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                    return
                }
            }
        }
        /*
        callRefreshToken { (token:String) in
            
            let urlString:String = "\(serviceName.UpdateProfile.rawValue)"
            
            let param :[String:String] = ["newPassword":password,"name" : name]
            
           // let headers:[String:String] = ["Content-Type":"application/json"]
            let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(token)"]
            
            self.showSpinnerWith(title: "Cargando...")
            self.callServerFor(method: "POST", urlStr: urlString, param: param, header: headers, encoding: "JSON") { (dictFetched:[String:Any], err:Error?) in
                // print(dictFetched)
                self.hideSpinner()
                
                if err != nil
                {
                    print("An error came - ", err!)
                    return
                }
                
                if let code:Int = dictFetched["code"] as? Int
                {
                    if code >= 200 || code < 200
                    {
                        if let resp:String = dictFetched["response"] as? String
                        {
                            self.showAlertWithTitle(title: "Zertu", message: resp, okButton: "Ok", cancelButton: "", okSelectorName: nil)
                            return
                        }
                    }
                    else
                    {
                        self.showAlertWithTitle(title: "Zertu", message: "Se produjo un error, por favor intente más tarde", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                        return
                    }
                }
            }
        }
        */
    }
}

extension MyProfileVC
{
    func callGetProducts_Tienda()
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.GetProductsList.rawValue
        let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        
        WebService.callApiWith(url: urlStr, method: .get, parameter: nil, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
//            print(jsonStr)
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
                    var arrPd: [[String:Any]] = []
                    var arrCat:[[String:Any]] = [["title":"All", "selected":true]]
                    if let arrItems:[[String:Any]] = json["response"] as? [[String:Any]]
                    {
                        for iind in 0..<arrItems.count
                        {
                            var d:[String:Any] = arrItems[iind]
                            d["counter"] = 0
                            
                            if let ar:[[String:Any]] = d["categories"] as? [[String:Any]]
                            {
                                if ar.count > 0
                                {
                                    let dp:[String:Any] = ar.first!
                                    if let strCat:String = dp["name"] as? String
                                    {
                                        d["Category_Updated_InCode"] = strCat  // we will use this key to filter the products
                                        
                                        let dCompare:[String:Any] = ["title":strCat, "selected":false]

                                        let foundItems = arrCat.filter{$0["title"] as! String == strCat}
                                        
                                        if foundItems.count == 0
                                        {
                                            arrCat.append(dCompare)
                                        }
                                    }
                                }
                            }
                            
                            arrPd.append(d)
                        }
                        
                        DispatchQueue.main.async {
                            
                            let vc:TiendaVC = AppStoryboards.More.instance.instantiateViewController(identifier: "TiendaVC_ID") as! TiendaVC
                            vc.arrProducts = arrPd
                            vc.arrCategories = arrCat
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
        }
    }
}
