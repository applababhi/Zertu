//
//  ForgotVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 19/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit

class ForgotVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtFld_Email:UITextField!
    @IBOutlet weak var btn_Done:UIButton!
    @IBOutlet weak var c_Pass_Bt:NSLayoutConstraint!
    @IBOutlet weak var c_Login_Bt:NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFld_Email.font = UIFont(name: "STHeitiTC-Light", size: 18)
                
        txtFld_Email.setPlaceHolderColorWith(strPH: "Correo")
        txtFld_Email.delegate = self
       
        btn_Done.setTitle("Submit", for: .normal)
        btn_Done.layer.borderColor = UIColor.white.cgColor
        btn_Done.layer.borderWidth = 0.5
        btn_Done.layer.cornerRadius = 25.0
        btn_Done.layer.masksToBounds = true
        
       // txtFld_Email.text = "andxtorres@hotmail.com"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func btnDone_Clicked(btn:UIButton)
    {
        guard let strEmail:String = txtFld_Email.text, strEmail.isEmpty == false else
        {
            self.showAlertWithTitle(title: "Alerta", message: "Por favor introduzca una dirección de correo eléctronico", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        
        if self.isValidEmail(testStr: strEmail) == false
        {
            self.showAlertWithTitle(title: "Alerta", message: "La dirección de correo electrónico es inválida", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        else
        {
            txtFld_Email.text = ""
            txtFld_Email.resignFirstResponder()
            callServerToRecoverWith(email: strEmail)
        }
    }

    func callServerToRecoverWith(email:String)
    {
        let urlString:String = "\(serviceName.ForgotPassword.rawValue)"
        
        let param :[String:String] = ["email" : email]
        
        let headers:[String:String] = ["Content-Type":"application/json; charset=utf-8"]
        
        self.showSpinnerWith(title: "Cargando...")
            
        WebService.callApiWith(url: urlString, method: .post, parameter: param, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonString:String, error:Error?) in
                
            self.hideSpinner()
            // print(jsonString)
                
            if error != nil
            {
                self.showAlertWithTitle(title: "Alerta", message: "\(error!.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
                
            if let str:String = json["message"] as? String
            {
                self.showAlertWithTitle(title: "Alerta", message: str, okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
            
            if let str:String = json["response"] as? String
            {
                let sel:Selector = #selector(self.dismissVC)
                self.showAlertWithTitle(title: "Alerta", message: str, okButton: "Ok", cancelButton: "", okSelectorName: sel)
                return
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
    
    @IBAction func btnBack_Clicked(btn:UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissVC()
    {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ForgotVC
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
