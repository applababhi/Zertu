//
//  InPersonDetailVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 6/12/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit
import Braintree

class InPersonDetailVC: UIViewController {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!

    var dict_InPerson:[String:Any]!
    var numberofPersons:Int = 1
    var courseID:Int = 0
    var int_PricePerPerson:Double = 0
    var strCourseName:String = ""
    var seatsAvailable:Int = 0
    var braintreeClient:BTAPIClient!
  //  var view_White:UIView!
    
    var mapLat:Double = 0.0
    var mapLong:Double = 0.0
    
    var check_MapLoadedOnce:Bool = false
    var arrPersons = Array<Dictionary<String,Any>>()
    var arrTable:[String] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let idT:Int = dict_InPerson["id"] as? Int
        {
            courseID = idT
        }
        if let seat:Int = dict_InPerson["maxCapacity"] as? Int
        {
            seatsAvailable = seat
        }
        
        if let lat:Double = dict_InPerson["latitude"] as? Double
        {
            mapLat = lat
        }
        
        if let long:Double = dict_InPerson["longitude"] as? Double
        {
            mapLong = long
        }
        
        if let strTitle:String = dict_InPerson["title"] as? String
        {
            strCourseName = strTitle
            self.lblTitle.text = strTitle
        }
        
        tblView.delegate = self
        tblView.dataSource = self
        tblView.estimatedRowHeight = 50
        tblView.rowHeight = UITableView.automaticDimension
        tblView.reloadData()
        
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
}

extension InPersonDetailVC
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

extension InPersonDetailVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? UITableView.automaticDimension : 270
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0
        {
            let cell:Cell_InpersonRowFirst = tblView.dequeueReusableCell(withIdentifier: "Cell_InpersonRowFirst", for: indexPath) as! Cell_InpersonRowFirst
            cell.selectionStyle = .none
            
            cell.imgView.contentMode = .scaleAspectFill
            cell.imgView.clipsToBounds = true
            
            cell.btn_Conekta.addTarget(self, action: #selector(self.btnConekta_Clicked(btn:)), for: .touchUpInside)

            if let imgUrl:String = dict_InPerson["coverImageUrl"] as? String
            {
                cell.imgView.setImageUsingUrl(imgUrl)
            }
            else
            {
                cell.imgView.image = UIImage(named: "ph.png")!
            }
            
            if let strDesc:String = dict_InPerson["description"] as? String
            {
                    /*
                let attributedString = NSMutableAttributedString(string: strDesc.htmlToString)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 10
                attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
                cell.lbl_Description.attributedText = attributedString
                */
                
                let attributes = [NSAttributedString.Key.font: UIFont(name: CustomFont.GSLRegular, size: 20)!,
                                  NSAttributedString.Key.foregroundColor: UIColor.darkGray]

                cell.lbl_Description.attributedText = NSAttributedString(string: strDesc.htmlToString, attributes: attributes)
                
               // print(attributedString)
            }
            return cell
        }
        else
        {
            let cell:Cell_InpersonRowLast = tblView.dequeueReusableCell(withIdentifier: "Cell_InpersonRowLast", for: indexPath) as! Cell_InpersonRowLast
            cell.selectionStyle = .none
            
            cell.lbl_NumberOfPersons.text = "\(numberofPersons)"
            
            cell.btn_Oxxo.isHidden = true
            
            if self.seatsAvailable >= 100
            {
                cell.btn_Oxxo.isHidden = false
            }
            
            cell.view_PlusMinus.layer.borderColor = UIColor.lightGray.cgColor
            cell.view_PlusMinus.layer.borderWidth = 1.0
            cell.view_PlusMinus.layer.cornerRadius = 5.0
            cell.view_PlusMinus.layer.masksToBounds = true
            
            cell.btn_Minus.addTarget(self, action: #selector(self.btnMinus_Clicked(btn:)), for: .touchUpInside)
            cell.btn_Plus.addTarget(self, action: #selector(self.btnPlus_Clicked(btn:)), for: .touchUpInside)
            cell.btn_Conekta.addTarget(self, action: #selector(self.btnConekta_Clicked(btn:)), for: .touchUpInside)
            cell.btn_PayPal.addTarget(self, action: #selector(self.btnPayPal_Clicked(btn:)), for: .touchUpInside)
            cell.btn_Oxxo.addTarget(self, action: #selector(self.btnOxxo_Clicked(btn:)), for: .touchUpInside)
            
            if let price:Double = dict_InPerson["price"] as? Double
            {
                // print(price)
                int_PricePerPerson = price
                let strPrice = "Precio: $\(Int(price)) Por Persona"
                
                cell.lbl_Price.attributedText = self.setAttributedString(str: strPrice)
            }

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func btnPlus_Clicked(btn:UIButton)
    {
        let indexPath = IndexPath(item: 1, section: 0)
        numberofPersons = numberofPersons + 1
        tblView.reloadRows(at: [indexPath], with: .fade)
    }
    
    @objc func btnMinus_Clicked(btn:UIButton)
    {
        if numberofPersons != 1
        {
            let indexPath = IndexPath(item: 1, section: 0)
            numberofPersons = numberofPersons - 1
            tblView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    func showAlertWithTextFields(numberOfFields count:Int, completionArrayCount:@escaping (Int)->())
    {
        arrPersons.removeAll()
        
        let alertController = UIAlertController(title: "Zertu", message: "Ingresa el nombre de los participantes", preferredStyle: .alert)
        
        for index in 0..<count
        {
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Nombre del participante" + " \(index + 1)"
                textField.delegate = self
            }
        }
        
        let saveAction = UIAlertAction(title: "Salvar", style: .default, handler: { alert -> Void in
            
            for txtFld in alertController.textFields!
            {
                if txtFld.text!.isEmpty == false
                {
                    let dictPersons = ["name":txtFld.text!]
                    self.arrPersons.append(dictPersons)
                }
            }
            completionArrayCount(self.arrPersons.count)
        })
        
        alertController.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .destructive, handler: { alert -> Void in
            print("Cancel")
        })
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func btnConekta_Clicked(btn:UIButton)
    {
        if numberofPersons == 0
        {
            self.showAlertWithTitle(title: "Zertu", message: "El número de persona es 0", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        else
        {
            showAlertWithTextFields(numberOfFields: self.numberofPersons) { (NamesCount) in
                
                if self.numberofPersons == self.arrPersons.count
                {
                    // call Regular Flow now & add Array in JSON Parameter
                    self.initiateConekta()
                }
                else
                {
                    self.btnConekta_Clicked(btn: UIButton())
                }
            }
        }
    }
    
    func initiateConekta()
    {
        /*
         use below link for Conekta
         https://github.com/conekta/conekta-ios
         */
        
        callServerToGetLinkedCards(){
            (arrCards:[[String:Any]]) in
            
            if arrCards.count == 0
            {
                // User has no cards so Add Card
                let vc:AddCardConektaVC = AppStoryboards.MyProfile.instance.instantiateViewController(identifier: "AddCardConektaVC_ID") as! AddCardConektaVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                let conkDetVC:ConektaPayDetailVC = AppStoryboards.InPerson.instance.instantiateViewController(identifier: "ConektaPayDetailVC_ID") as! ConektaPayDetailVC
                let numPer:Double = Double(self.numberofPersons)
                conkDetVC.strPrice = "\(numPer * self.int_PricePerPerson)"
                conkDetVC.strCourse = self.strCourseName
                if let idT:Int = self.dict_InPerson["id"] as? Int
                {
                    conkDetVC.CourseID = idT
                }
                conkDetVC.strPricePerPerson = "\(self.int_PricePerPerson)"
                conkDetVC.numberofPersons = self.numberofPersons
                
                self.navigationController?.pushViewController(conkDetVC, animated: true)
            }
        }
    }
    
    @objc func btnPayPal_Clicked(btn:UIButton)
    {
        if numberofPersons == 0
        {
            self.showAlertWithTitle(title: "Zertu", message: "El número de persona es 0", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        else
        {
            showAlertWithTextFields(numberOfFields: self.numberofPersons) { (NamesCount) in

                if self.numberofPersons == self.arrPersons.count
                {
                    // call Regular Flow now & add Array in JSON Parameter
                    self.initiatePayPal()
                }
                else
                {
                    self.btnPayPal_Clicked(btn: UIButton())
                }
            }
        }
    }
    
    func initiatePayPal()
    {
        /*
         Links use to Integrate Express Checkout Braintree :
         https://github.com/braintree/braintree_ios#installation - just to add CocoaPod, no bridging needed
         Try to look in for code from below 3 links and integrate the right code
         https://developer.paypal.com/docs/accept-payments/express-checkout/ec-braintree-sdk/client-side/ios/v4/
         https://developers.braintreepayments.com/guides/paypal/client-side/ios/v4
         https://developers.braintreepayments.com/guides/paypal/checkout-with-paypal/ios/v4
         */
        
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.GetPayPalToken.rawValue
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
                    if let tokenPaypal:String = json["response"] as? String
                    {
                        DispatchQueue.main.async {
                            self.initiatePaypalProcessWith(token: tokenPaypal)
                        }
                    }
                }
            }
        }
    }
    
    @objc func btnOxxo_Clicked(btn:UIButton)
    {
        if numberofPersons == 0
        {
            self.showAlertWithTitle(title: "Zertu", message: "El número de persona es 0", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        else
        {
            showAlertWithTextFields(numberOfFields: self.numberofPersons) { (NamesCount) in
                
                if self.numberofPersons == self.arrPersons.count
                {
                    // call Regular Flow now & add Array in JSON Parameter
                    self.initiateOxxo()
                }
                else
                {
                    self.btnOxxo_Clicked(btn: UIButton())
                }
            }
        }
    }
    
    func initiateOxxo()
    {
        /*
        self.showSpinnerWith(title: "Cargando...")
        
        callRefreshToken { (tokenT:String) in
            
            let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(tokenT)"]
            self.callServerFor(method: "POST", urlStr: serviceName.PayByOXXO.rawValue, param: ["inPersonCourseId":self.courseID, "numberOfPeople":self.numberofPersons, "people":self.arrPersons], header: headers, encoding: "JSON") { (dictFetched:[String:Any], err:Error?) in
                //      print(dictFetched)
                self.hideSpinner()
                
                if err != nil
                {
                    print("An error came - ", err!)
                    return
                }
                
                if let dictRes:[String:Any] = dictFetched["response"] as? [String:Any]
                {
                    DispatchQueue.main.async {
                        
                        let oxxoVC = k_storyBoard.instantiateViewController(withIdentifier: "OXXOSuccessVC_ID") as! OXXOSuccessVC
                        
                        let numPer:Double = Double(self.numberofPersons)
                        oxxoVC.strPrice = "\(numPer * self.int_PricePerPerson)"
                        oxxoVC.strCourse = self.strCourseName
                        oxxoVC.strPricePerPerson = "\(self.int_PricePerPerson)"
                        oxxoVC.strNumOfPerson = "\(self.numberofPersons)"
                        
                        if let ref:String = dictRes["reference"] as? String
                        {
                            oxxoVC.strReferenceNumber = ref
                        }
                        
                        self.navigationController?.pushViewController(oxxoVC, animated: true)
                    }
                }
            }
        }
        */
    }
    
    func setAttributedString(str:String) -> NSMutableAttributedString
    {
        let arrStr = str.components(separatedBy: ":")
        //     print(arrStr)
        let str1 = "\(arrStr.first!):"
        
        var str2 = ""
        if arrStr.count != 1
        {
            str2 = "\(arrStr.last!)"
        }
        
        // print(str1, str2)
        let attrs1 = [NSAttributedString.Key.font : UIFont(name: CustomFont.GSLRegular, size: 18), NSAttributedString.Key.foregroundColor : UIColor.black]
        let attrs2 = [NSAttributedString.Key.font :  UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.black]
        
        let attributedString1 = NSMutableAttributedString(string:str1, attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:" \(str2)", attributes:attrs2)
        
        attributedString1.append(attributedString2)
        
        return attributedString1
    }
    
    func callServerToGetLinkedCards(completionhandler:@escaping ([[String:Any]]) -> ())
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.userCardList.rawValue
        let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        
        WebService.callApiWith(url: urlStr, method: .get, parameter: nil, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
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
                    if let arr:[[String:Any]] = json["response"] as? [[String:Any]]
                    {
                        completionhandler(arr)
                    }
                }
            }
        }
    }
    
    func initiatePaypalProcessWith(token:String)
    {
        self.showSpinnerWith(title: "Cargando...")
        self.perform(#selector(self.hideLoader), with: nil, afterDelay: 7.0)
        
        // Example: Initialize BTAPIClient, if you haven't already
        braintreeClient = BTAPIClient(authorization: token)!
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self // Optional
        
        // Specify the transaction amount here. "2.32" is used in this example.
        let numPer:Double = Double(self.numberofPersons)
        let totalPrice = "\(numPer * self.int_PricePerPerson)"
        let request = BTPayPalRequest(amount: totalPrice)
        request.currencyCode = "MXN" // Optional; see BTPayPalRequest.h for more options
        
        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                
                DispatchQueue.main.async {
                    self.callServerForpaypalPaymentWith(nonce: "\(tokenizedPayPalAccount.nonce)")
                }
                
                /*
                // Access additional information
                let email = tokenizedPayPalAccount.email
                let firstName = tokenizedPayPalAccount.firstName
                let lastName = tokenizedPayPalAccount.lastName
                let phone = tokenizedPayPalAccount.phone
                
                // See BTPostalAddress.h for details
                let billingAddress = tokenizedPayPalAccount.billingAddress
                let shippingAddress = tokenizedPayPalAccount.shippingAddress
                */
            } else if let error = error
            {
                // Handle error here...
                self.showAlertWithTitle(title: "Zertu", message: "\(error.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return

            } else
            {
                // Buyer canceled payment approval
                print("Abhi, Screen Canceled by User")
            }
        }
    }
    
    @objc func hideLoader()
    {
        self.hideSpinner()
    }
}

extension InPersonDetailVC: BTViewControllerPresentingDelegate, BTAppSwitchDelegate
{
    // MARK: - BTViewControllerPresentingDelegate
    
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - BTAppSwitchDelegate
    // Optional - display and hide loading indicator UI
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        // Show Loading indicator here
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        // hide Loading indicator here
    }
    
    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
        
    }
    
    func callServerForpaypalPaymentWith(nonce:String)
    {
        self.showSpinnerWith(title: "Cargando...")
                
        let urlStr = serviceName.MakePayPalPayment.rawValue
        let param:[String:Any] = ["inPersonCourseId":self.courseID, "numberOfPeople":self.numberofPersons, "cardToken":nonce, "people":self.arrPersons]
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
                            // its a success
                            if let dictRes:[String:Any] = json["response"] as? [String:Any]
                            {
                                DispatchQueue.main.async {
                                    // take to Result Conekta Screen
                                    
                                    let conResVC:ConektaResultStatusVC = AppStoryboards.InPerson.instance.instantiateViewController(identifier: "ConektaResultStatusVC_ID") as! ConektaResultStatusVC
                                    
                                    let numPer:Double = Double(self.numberofPersons)
                                    conResVC.strPrice = "\(numPer * self.int_PricePerPerson)"
                                    conResVC.strCourse = self.strCourseName
                                    if let checkSt:Bool = dictRes["status"] as? Bool
                                    {
                                        conResVC.paymentStatus = checkSt
                                    }
                                    
                                    conResVC.strPricePerPerson = "\(self.int_PricePerPerson)"
                                    conResVC.numberofPersons = self.numberofPersons
                                    conResVC.ref_InPersonDetailVC = self
                                    
                                    self.navigationController?.pushViewController(conResVC, animated: true)
                                }
                            }
                        }
                        else if code >= 500
                        {
                            // its a failure
                            DispatchQueue.main.async {
                                // take to Result Conekta Screen
                                let conResVC:ConektaResultStatusVC = AppStoryboards.InPerson.instance.instantiateViewController(identifier: "ConektaResultStatusVC_ID") as! ConektaResultStatusVC

                                let numPer:Double = Double(self.numberofPersons)
                                conResVC.strPrice = "\(numPer * self.int_PricePerPerson)"
                                conResVC.strCourse = self.strCourseName
                                conResVC.paymentStatus = false
                                conResVC.strPricePerPerson = "\(self.int_PricePerPerson)"
                                conResVC.numberofPersons = self.numberofPersons
                                conResVC.ref_InPersonDetailVC = self
                                self.navigationController?.pushViewController(conResVC, animated: true)
                            }
                        }
                    }
            
        }
    }
}

extension InPersonDetailVC: UITextFieldDelegate
{
    // Allow only Alphabets no Numbers
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let characterSet = CharacterSet.letters
        
        if string.rangeOfCharacter(from: characterSet.inverted) != nil {
            return false
        }
        return true
    }
    
    /*
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    */
}
