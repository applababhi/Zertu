//
//  RegisterVC.swift
//  Zertu
//
//  Created by Abhishek Bhardwaj on 16/5/18.
//  Copyright © 2018 Abhishek Bhardwaj. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtFld_Username:UITextField!
    @IBOutlet weak var txtFld_Email:UITextField!
    @IBOutlet weak var txtFld_Passowrd:UITextField!
    @IBOutlet weak var txtFld_ConfirmPassowrd:UITextField!
    @IBOutlet weak var btn_Register:UIButton!
    @IBOutlet weak var btn_Accept:UIButton!
    
//    @IBOutlet weak var c_Regis_Bt:NSLayoutConstraint!
//    @IBOutlet weak var c_vUser_Ht:NSLayoutConstraint!
//    @IBOutlet weak var c_vEmail_Ht:NSLayoutConstraint!
//    @IBOutlet weak var c_vPass_Ht:NSLayoutConstraint!
//    @IBOutlet weak var c_vconPass_Ht:NSLayoutConstraint!
    
    @IBOutlet weak var c_vUser_Tp:NSLayoutConstraint!
    @IBOutlet weak var c_vEmail_Tp:NSLayoutConstraint!
    @IBOutlet weak var c_vPass_Tp:NSLayoutConstraint!
    @IBOutlet weak var c_vconPass_Tp:NSLayoutConstraint!

    
   // var viewReff:FirstScreenVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    //    k_window.windowLevel = UIWindowLevelNormal
        
        txtFld_Email.delegate = self
        txtFld_ConfirmPassowrd.delegate = self
        txtFld_Passowrd.delegate = self
        txtFld_Username.delegate = self
        
        txtFld_Email.font = UIFont(name: "STHeitiTC-Light", size: 18)
        txtFld_ConfirmPassowrd.font = UIFont(name: "STHeitiTC-Light", size: 18)
        txtFld_Passowrd.font = UIFont(name: "STHeitiTC-Light", size: 18)
        txtFld_Username.font = UIFont(name: "STHeitiTC-Light", size: 18)

       // self.setViewBackgroundImage(name: "bk")
        
        let ph_Email = NSLocalizedString("Email", comment: "text")
        let ph_Password = "Contraseña" //NSLocalizedString("Password", comment: "text")
        let ph_ConPassword = "Confirmar contraseña" //NSLocalizedString("Confirm Password", comment: "text")
        let ph_Username = "NOMBRE" // "USUARIO" //NSLocalizedString("user", comment: "text")
        
        txtFld_Username.setPlaceHolderColorWith(strPH: ph_Username)
        txtFld_Passowrd.setPlaceHolderColorWith(strPH: ph_Password)
        txtFld_Email.setPlaceHolderColorWith(strPH: ph_Email)
        txtFld_ConfirmPassowrd.setPlaceHolderColorWith(strPH: ph_ConPassword)
        
        btn_Register.setTitle("Regístrate", for: .normal)
        btn_Register.layer.borderColor = UIColor.white.cgColor
        btn_Register.layer.borderWidth = 0.5
        btn_Register.layer.cornerRadius = 25.0
        btn_Register.layer.masksToBounds = true
        
        if UIDevice.current.model == "iPad"
        {
            /*
            c_Regis_Bt.constant = 20
            c_vUser_Ht.constant = 35
            c_vEmail_Ht.constant = 35
            c_vPass_Ht.constant = 35
            c_vconPass_Ht.constant = 35
            
            c_vUser_Tp.constant = 30
            c_vEmail_Tp.constant = 5
            c_vPass_Tp.constant = 5
            c_vconPass_Tp.constant = 5
            */
        }
        setupConstraints()
        btn_Accept.addTarget(self, action: #selector(self.btn_AcceptClicked(btn:)), for: .touchUpInside)
    }
    
    func setupConstraints()
    {
        let strModel = getDeviceModel()
        if strModel == "iPhone XS"
        {

        }
        else if strModel == "iPhone Max"
        {
            //c_vUser_Tp.constant = 30
            c_vEmail_Tp.constant = 10
            c_vPass_Tp.constant = 10
            c_vconPass_Tp.constant = 10

        }
        else if strModel == "iPhone 6+"
        {
            //c_vUser_Tp.constant = 30
            c_vEmail_Tp.constant = 10
            c_vPass_Tp.constant = 10
            c_vconPass_Tp.constant = 10

        }
        else if strModel == "iPhone 6"
        {

        }
        else if strModel == "iPhone 5"
        {

        }
        else
        {
            // UNKNOWN CASE - Like iPhone 11 or XR
            //c_vUser_Tp.constant = 30
            c_vEmail_Tp.constant = 10
            c_vPass_Tp.constant = 10
            c_vconPass_Tp.constant = 10
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func btn_AcceptClicked(btn:UIButton)
    {
        btn.isSelected = !btn.isSelected
        
        if btn.isSelected == true
        {
            btn.setImage(UIImage(named: "check")!, for: .normal)
        }
        else
        {
            btn.setImage(UIImage(named: "uncheck")!, for: .normal)
        }
    }
    
    @IBAction func btnRegister_Clicked(btn:UIButton)
    {
        if btn_Accept.isSelected == false
        {
            self.showAlertWithTitle(title: "Alerta", message: "Por favor, indique que acepta los términos y condiciones", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        
        guard let strUsername:String = txtFld_Username.text, strUsername.isEmpty == false else
        {
            self.showAlertWithTitle(title: "Alerta", message: "Por favor ingrese un nombre de usuario", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        
        guard let strEmail:String = txtFld_Email.text, strEmail.isEmpty == false else
        {
            self.showAlertWithTitle(title: "Alerta", message: "Por favor introduzca una dirección de correo eléctronico", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        
        guard let strPass:String = txtFld_Passowrd.text, strPass.isEmpty == false else
        {
            self.showAlertWithTitle(title: "Alerta", message: "Por favor, ingrese contraseña", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        
        guard let strConPass:String = txtFld_ConfirmPassowrd.text, strConPass.isEmpty == false else
        {
            self.showAlertWithTitle(title: "Alerta", message: "Por favor ingrese Confirmar contraseña", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        
        if self.isValidEmail(testStr: strEmail) == false
        {
            self.showAlertWithTitle(title: "Alerta", message: "La dirección de correo electrónico es inválida", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        else
        {
            if strPass != strConPass
            {
                self.showAlertWithTitle(title: "Alerta", message: "Las contraseñas no son las mismas", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
            
            let param :[String:String] = ["password":strConPass,"email" : strEmail, "username": strEmail, "name":strUsername, "address_line_1":"", "address_line_2":""]
            
            self.view.endEditing(true)
            callServerToRegisterWith(param: param)
        }
    }

    func callServerToRegisterWith(param:[String:String])
    {
        let urlString:String = "\(serviceName.Register.rawValue)"
        
        let headers:[String:String] = ["Content-Type":"application/json"]
        
        self.showSpinnerWith(title: "Cargando...")
            
        WebService.callApiWith(url: urlString, method: .post, parameter: param, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonString:String, error:Error?) in
                
            self.hideSpinner()
          //   print(jsonString)
                
            if error != nil
            {
                self.showAlertWithTitle(title: "Alerta", message: "\(error!.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
                
            if let code:Int = json["code"] as? Int
            {
                if code >= 200 || code < 300
                {
                    if let tok:String = json["response"] as? String
                    {
                        //  k_helper.saveLoginUserId(userId: tok)  // we need change this to UserID in Future
                        //  k_userDef.setValue(tok, forKey: userDefaultKeys.RefreshToken.rawValue)
                        //  k_userDef.synchronize()
                        self.txtFld_Email.text = ""
                        self.txtFld_ConfirmPassowrd.text = ""
                        self.txtFld_Passowrd.text = ""
                        self.txtFld_Username.text = ""

                        let sel:Selector = #selector(self.registerSuccess)
                        DispatchQueue.main.async {
                            self.showAlertWithTitle(title: "Zertu", message: "Registro exitoso", okButton: "Ok", cancelButton: "", okSelectorName: sel)
                            return
                        }
                    }
                }
            }
            
            if let msgErrorJSON:String = json["error500"] as? String
            {
                self.showAlertWithTitle(title: "Alerta", message: "Ocurrió algún error, intente nuevamente después de algún tiempo", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
            
            if let error:String = json["error_description"] as? String
            {
                self.showAlertWithTitle(title: "Alerta", message: error, okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
        }
    }
        
    @objc func registerSuccess()
    {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func btnBack_Clicked(btn:UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

extension RegisterVC
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
