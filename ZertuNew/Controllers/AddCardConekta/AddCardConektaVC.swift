//
//  AddCardConektaVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 6/12/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit
import PayCardsRecognizer

class AddCardConektaVC: UIViewController {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!

    @IBOutlet weak var cardNumber1TextField: UITextField!
    @IBOutlet weak var cardNameTextField: UITextField!
    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var btn_Scan: UIButton!
    @IBOutlet weak var btn_AddCard: UIButton!

    var scanner: PayCardsRecognizer!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        cardNumber1TextField.font = UIFont(name: "STHeitiTC-Light", size: 18)
        cardNameTextField.font = UIFont(name: "STHeitiTC-Light", size: 18)
        monthTextField.font = UIFont(name: "STHeitiTC-Light", size: 18)
        cvvTextField.font = UIFont(name: "STHeitiTC-Light", size: 18)
        
        hideKeyboardWhenTappedAround()
        self.lblTitle.text = "AGREGAR TARJETA"
        cardNumber1TextField.placeholder = "Número de tarjeta"
        cardNameTextField.placeholder = "Nombre del titular de la tarjeta"
        btn_Scan.setTitle("Escanee su tarjeta", for: .normal)
        btn_AddCard.setTitle("AGREGAR TARJETA", for: .normal)
        self.btn_AddCard.isUserInteractionEnabled = false
        self.btn_AddCard.backgroundColor = UIColor.init(red: 93.0/255.0, green: 93.0/255.0, blue: 93.0/255.0, alpha: 1.0) // gray
        
        self.btn_AddCard.layer.cornerRadius = 22.5
        self.btn_AddCard.layer.masksToBounds = true
        
        setUpTopBar()
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
    
    @IBAction func btn_ScanClicked(btn:UIButton)
    {
        scanner = PayCardsRecognizer(delegate: self, resultMode: .async, container: self.view, frameColor: .green)
        scanner.startCamera()
    }
}

extension AddCardConektaVC
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

extension AddCardConektaVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        
        switch textField
        {
        case cardNumber1TextField:
            if newString.count < 17
            {
                if newString.count == 0
                {
                    self.btn_AddCard.isEnabled = false
                    self.btn_AddCard.backgroundColor = UIColor.init(red: 93.0/255.0, green: 93.0/255.0, blue: 93.0/255.0, alpha: 1.0) // gray
                    return true
                }
                self.btn_AddCard.isEnabled = true
                self.btn_AddCard.backgroundColor = UIColor(named: "TabCircleColor")
            }
            else
            {
                return false
            }
            
        case cardNameTextField:
            self.btn_AddCard.isUserInteractionEnabled = true
            return true
        case monthTextField:
            if newString.count < 6
            {
                if newString.count == 0
                {
                    self.btn_AddCard.isUserInteractionEnabled = true
                    return true
                }
                
                if newString.count == 3
                {
                    if string.count == 0
                    {
                        // for backspace
                        self.btn_AddCard.isUserInteractionEnabled = true
                        return true
                    }
                    let str:String = textField.text! + "/"
                    // print(str)
                    monthTextField.text = str
                    self.btn_AddCard.isUserInteractionEnabled = true
                    return true
                }
                self.btn_AddCard.isUserInteractionEnabled = true
                return true
            }
            else{
                return false
            }
            
        case cvvTextField:
            if newString.count < 5
            {
                /*
                if newString.count == 0
                {
                    // lbl_CardCVV.text = "XXXX"
                    return true
                }
                */
                self.btn_AddCard.isUserInteractionEnabled = true
            }
            else
            {
                return false
            }
            
        default:
            return false
        }
        
        return true
    }
    
    @IBAction func btn_AddCardClicked(btn:UIButton)
    {
        self.view.endEditing(true)
        btn_AddCard.isEnabled = false
        
        var strMonth:String = ""
        var strYear:String = ""
        
        if monthTextField.text != ""
        {
            let str:String = monthTextField.text!
            let arr:NSArray = str.components(separatedBy: "/") as NSArray
            strMonth = arr[0] as! String
            strYear = arr[1] as! String
            strYear = "20" + strYear
        }
        
        if let card1 = cardNumber1TextField.text, let name = cardNameTextField.text, let cvv = cvvTextField.text
        {
            let month = strMonth
            
            if card1.localizedStandardContains("*") || month.localizedStandardContains("X")
            {
                DispatchQueue.main.async {
                    self.showAlertWithTitle(title: "Alerta", message: "Por favor edite el texto en el formato correcto", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                    self.btn_AddCard.isEnabled = true
                    self.btn_AddCard.backgroundColor = UIColor(named: "TabCircleColor")
                    return
                }
            }
            if (!card1.isEmpty)
            {
                if (!name.isEmpty)
                {
                    if (!cvv.isEmpty)
                    {
                        if (!month.isEmpty && !strYear.isEmpty)
                        {
                            if let monthInt = Int(month), let yearInt = Int(strYear) {
                                if (monthInt >= 1 && monthInt <= 12) {
                                    let currentYear = (Calendar.current as NSCalendar).component(.year, from: Date()) % 2000
                                    
                                    if yearInt >= currentYear {
                                        
                                        let cleanCard = "\(cleanString(card1))"
                                        
                                        if (cleanCard.count == 15 || cleanCard.count == 16) {
                                            
                                            if cvv.count == 3 || cvv.count == 4
                                            {
                                                print("Call Conekta Service to Add Card")
                                                self.showSpinnerWith(title: "Cargando...")

                                                let conekta = Conekta()
                                                conekta.delegate = self
                                                
                                             //   conekta.publicKey = "key_FhqRqi5zcPKEazj9nHtDVuw" // Conekta DEVELOPMENT KEY
                                                
                                                conekta.publicKey = "key_TU1bZXk61hUd94Ud4mcLskQ"  // Conekta PRODUCTION KEY
                                                                                                
                                                conekta.collectDevice()
                                                
                                                let card = conekta.card()
                                                
                                               // card?.setNumber("4242424242424242", name: "Julian Ceballos", cvc: "123", expMonth: "10", expYear: "2018")
                                                
                                                card?.setNumber(card1, name: name, cvc: cvv, expMonth: strMonth, expYear: strYear)
                                                
                                                let token = conekta.token()
                                                
                                                token?.card = card
                                                
                                                token?.create(success: { (tokenDict) -> Void in
                                                    print("Conekta Dict Fetched-->", tokenDict)
                                                    self.hideSpinner()
                                                    
                                                    if tokenDict != nil
                                                    {
                                                        let dict:[String:Any] = tokenDict as! [String:Any]
                                                        if let tokenID:String = dict["id"] as? String
                                                        {
                                                            self.callServerToAddCardWith(token: tokenID)
                                                        }
                                                        else if let msg:String = dict["message"] as? String
                                                        {
                                                            DispatchQueue.main.async {
                                                                self.showAlertWithTitle(title: "Zertu", message: msg, okButton: "Ok", cancelButton: "", okSelectorName: nil)
                                                                return
                                                            }
                                                        }

                                                    }
                                                }, andError: { (error) -> Void in
                                                    print(error)
                                                    
                                                    DispatchQueue.main.async {
                                                        self.showAlertWithTitle(title: "Zertu", message: (error?.localizedDescription)!, okButton: "Ok", cancelButton: "", okSelectorName: nil)
                                                        return
                                                    }
                                                    
                                                })
                                            }
                                            else
                                            {
                                                self.showAlertWithTitle(title: "Alerta", message: "CVV solo puede tener 3 o 4 caracteres (AMEX) de largo.", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                                                self.btn_AddCard.isEnabled = true
                                                self.btn_AddCard.backgroundColor = UIColor(named: "TabCircleColor")
                                                return
                                            }
                                        }
                                        else {
                                            self.showAlertWithTitle(title: "Alerta", message: "El número de tarjeta solo puede ser 15 (AMEX) o 16 caracteres de largo.", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                                            self.btn_AddCard.isEnabled = true
                                            self.btn_AddCard.backgroundColor = UIColor(named: "TabCircleColor")
                                            return
                                        }
                                    } else {
                                        self.showAlertWithTitle(title: "Alerta", message: "Year debería ser dos números mayor o igual que el actual", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                                        self.btn_AddCard.isEnabled = true
                                        self.btn_AddCard.backgroundColor = UIColor(named: "TabCircleColor")
                                        return
                                    }
                                }
                                else {
                                    self.showAlertWithTitle(title: "Alerta", message: "El mes debe ser dos números entre 01 y 12.", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                                    self.btn_AddCard.isEnabled = true
                                    self.btn_AddCard.backgroundColor = UIColor(named: "TabCircleColor")
                                    return
                                }
                            }
                        }
                        else
                        {
                            self.showAlertWithTitle(title: "Alerta", message: "El campo de fecha de caducidad está incompleto.", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                            self.btn_AddCard.isEnabled = true
                            self.btn_AddCard.backgroundColor = UIColor(named: "TabCircleColor")
                            return
                        }
                    }
                    else
                    {
                        self.showAlertWithTitle(title: "Alerta", message: "El campo CVV está vacío.", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                        self.btn_AddCard.isEnabled = true
                        self.btn_AddCard.backgroundColor = UIColor(named: "TabCircleColor")
                        return
                    }
                }
                else
                {
                    self.showAlertWithTitle(title: "Alerta", message: "El campo de nombre está vacío.", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                    self.btn_AddCard.isEnabled = true
                    self.btn_AddCard.backgroundColor = UIColor(named: "TabCircleColor")
                    return
                }
            }
            else
            {
                self.showAlertWithTitle(title: "Alerta", message: "El campo de número de tarjeta está incompleto.", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                self.btn_AddCard.isEnabled = true
                self.btn_AddCard.backgroundColor = UIColor(named: "TabCircleColor")
                return
            }
        }
    }
    
    func cleanString(_ string: String) -> String
    {
        return string.trimmingCharacters(in: CharacterSet.decimalDigits.inverted).replacingOccurrences(of: " ", with: "")
    }

}

extension AddCardConektaVC: PayCardsRecognizerPlatformDelegate
{
    func payCardsRecognizer(_ payCardsRecognizer: PayCardsRecognizer, didRecognize result: PayCardsRecognizerResult) {
//        print("Card number ->",result.recognizedNumber)
//        print("Card holder ->",result.recognizedHolderName)
//        print("Expire month ->",result.recognizedExpireDateMonth)
//        print("Expire year ->",result.recognizedExpireDateYear)
        
        if result.recognizedNumber != nil
        {
            cardNumber1TextField.text = result.recognizedNumber!
        }
        if result.recognizedHolderName != nil
        {
            cardNameTextField.text = result.recognizedHolderName!
        }
        if result.recognizedExpireDateMonth != nil
        {
            if result.recognizedExpireDateYear != nil
            {
                monthTextField.text = "\(result.recognizedExpireDateMonth!) / \(result.recognizedExpireDateYear!)"
            }
        }
        
        scanner.stopCamera()
    }
}

extension AddCardConektaVC
{
    func callServerToAddCardWith(token:String)
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.AddCardConekta.rawValue
        let param:[String:Any] = ["paymentToken":token]
        let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        
        WebService.callApiWith(url: urlStr, method: .post, parameter: param, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
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
                    if let msg:String = json["response"] as? String
                    {
                        DispatchQueue.main.async {
                            self.showAlertWithTitle(title: "Zertu", message: msg, okButton: "Ok", cancelButton: "", okSelectorName: #selector(self.back))
                            return
                        }
                    }
                }
            }
        }
    }
    
    @objc func back()
    {
        self.navigationController?.popViewController(animated: true)
    }
}
