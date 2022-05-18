//
//  LoginVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 19/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import KeychainSwift
import AuthenticationServices

class LoginVC: UIViewController {

    @IBOutlet weak var txtFld_Email:UITextField!
    @IBOutlet weak var txtFld_Passowrd:UITextField!
    @IBOutlet weak var btn_Login:UIButton!
    @IBOutlet weak var btn_Forgot:UIButton!
    @IBOutlet weak var btn_Signup:UIButton!
    @IBOutlet weak var btn_TermsPolicy:UIButton!
    @IBOutlet weak var btn_FB:UIButton!
    @IBOutlet weak var viewOverlay:UIView!
    @IBOutlet weak var viewSignInAppleButton:UIView!
    
    @IBOutlet weak var viewBannerHideAppleID:UIView!

    var strName_FB:String = ""
    var strEmail_FB:String = ""
    var strID_FB:String = ""
    var check_ComingFromFB = false
    var heightButton:CGFloat = 20.0 // half of height of each button
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn_FB.isHidden = true
        
        self.txtFld_Email.text = ""
        self.txtFld_Passowrd.text = ""

        viewOverlay.isHidden = false
        
        checkInternetAvailable() // call First time when any first View loads, as to initiate network check class
        
        self.perform(#selector(self.checkBaseTabbarController), with: nil, afterDelay: 0.2)
                
        setOutlets()
        addSignInWithAppleIDButton()
        
        txtFld_Email.font = UIFont(name: "STHeitiTC-Light", size: 18)
        txtFld_Passowrd.font = UIFont(name: "STHeitiTC-Light", size: 18)
        
        txtFld_Email.keyboardType = .emailAddress
        
     //   txtFld_Email.text = "andxtorres22@gmail.com"  // Production
     //   txtFld_Passowrd.text = "hola"
        
  //      txtFld_Email.text = "mayela_beltran@yahoo.com"  // Production
//        txtFld_Passowrd.text = "Beau1504"
       
     //   txtFld_Email.text = "jair322@hotmail.com"  // Production
     //   txtFld_Passowrd.text = "1234"
        
//              txtFld_Email.text = "ios1a@mailinator.com"  // abhi Production
//              txtFld_Passowrd.text = "1234"

    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewBannerHideAppleID.alpha = 1.0
        viewBannerHideAppleID.isHidden = false
        self.perform(#selector(self.hideAppleIdBanner), with: nil, afterDelay: 2.0)
    }
    
    @objc func hideAppleIdBanner()
    {
        // Hide lblBannerHideAppleID
        
        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseIn, animations: {
            self.viewBannerHideAppleID.alpha = 0
        }) { _ in
            self.viewBannerHideAppleID.isHidden = true
        }
    }
    
    func addSignInWithAppleIDButton()
    {
        // Add Sign In Apple, programatically and add it to subview(UIView), NOTE: in addtarget, we need to set .touchDown instead of .touchUpInside
        
        // NOTE : once user successfully authenticate itself using apple id, then in all other calls in future, whether user have app install in device or in future reinstall app will always just receive Token no other detail like email id name or user id. on one time successfully login we receive email, username, userApple id and Token, i think if user successfully authenticate itself first time after Biometric, then only we ll receive all this detail so we can pass to our Api email, name and Token and in future if user again click apple login button, i ll just send token and email and name as empty, if token matches in ur DB u can return me valid user
        
        let signINAppleBtn = ASAuthorizationAppleIDButton()
        signINAppleBtn.frame = CGRect(x: 0, y: 0, width: viewSignInAppleButton.frame.size.width, height: viewSignInAppleButton.frame.size.height)
        signINAppleBtn.addTarget(self, action: #selector(self.appleButtonClick), for: .touchDown)
        viewSignInAppleButton.addSubview(signINAppleBtn)
    }
    
    @objc func appleButtonClick()
    {
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let request = appleIdProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
    
    @objc func checkBaseTabbarController()
    {
        viewOverlay.isHidden = true
        
        if let accessTokenAvailable:String = k_userDef.value(forKey: userDefaultKeys.AccessToken.rawValue) as? String
        {
            if accessTokenAvailable != ""
            {
                // DIRECTLY SHOW APP DASHBOARD
                bearerToken = accessTokenAvailable
                
                let tab: BaseTabbarController = AppStoryboards.BaseTabBar.instance.instantiateViewController(withIdentifier: "BaseTabbarController_ID") as! BaseTabbarController
                k_window.rootViewController = tab
            }
        }
    }
    
    func setOutlets()
    {
        hideKeyboardWhenTappedAround()
        
        addLeftPaddingTo(tf: txtFld_Email)
        addLeftPaddingTo(tf: txtFld_Passowrd)
        
        txtFld_Email.setPlaceHolderColorWith(strPH: "Correo")
        txtFld_Passowrd.setPlaceHolderColorWith(strPH: "Contraseña")
            
        txtFld_Email.delegate = self
        txtFld_Passowrd.delegate = self
        
        btn_Login.layer.cornerRadius = heightButton
        btn_Login.layer.masksToBounds = true
        btn_Signup.layer.cornerRadius = heightButton
        btn_Signup.layer.masksToBounds = true
        btn_FB.layer.cornerRadius = heightButton
        btn_FB.layer.masksToBounds = true
        
        setTextfieldsBorder(color: .white, tf: txtFld_Email)
        setTextfieldsBorder(color: .white, tf: txtFld_Passowrd)
        
        let yourAttributes : [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font : UIFont(name: CustomFont.GSLRegular, size: 13)!,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
        let attributeString = NSMutableAttributedString(string: "El inicio de sesión significa que usted acepta los Términos de uso, la Política de privacidad de Zertú.", attributes: yourAttributes)
        btn_TermsPolicy.setAttributedTitle(attributeString, for: .normal)

    }
    
    func setTextfieldsBorder(color:UIColor, tf:UITextField)
    {
        tf.layer.borderColor = color.cgColor
        tf.layer.borderWidth = 1.0
        tf.layer.cornerRadius = 5.0
        tf.layer.masksToBounds = true
    }
    
    @IBAction func btnSkipClick(btn:UIButton)
    {
        isUserTappedSkipButton = true
        let tab: BaseTabbarController = AppStoryboards.BaseTabBar.instance.instantiateViewController(withIdentifier: "BaseTabbarController_ID") as! BaseTabbarController
        k_window.rootViewController = tab
    }
    
}

extension LoginVC
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

// MARK: - Apple Signin Delegate
extension LoginVC: ASAuthorizationControllerDelegate
{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            self.showAlertWithTitle(title: "Alerta", message: "\(error.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
        {
            print("User Id - \(appleIDCredential.user)")
            print("User Name - \(appleIDCredential.fullName?.description ?? "N/A")")
            print("Family Name - \(appleIDCredential.fullName?.familyName ?? "N/A")")
            print("User Email - \(appleIDCredential.email ?? "N/A")")
            print("Real User Status - \(appleIDCredential.realUserStatus.rawValue)")

            if let identityTokenData = appleIDCredential.identityToken,
                let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
               
                print("Identity Token \(identityTokenString)")
                
                //   call same FB API
                   
                self.callServerToLoginWithFB(url: "\(serviceName.FBLogin.rawValue)", parameters: ["fbToken":identityTokenString, "email":appleIDCredential.email ?? "","name":appleIDCredential.fullName?.givenName ?? ""])
            }
            
        }
        
        if let applePasswordCredential = authorization.credential as? ASPasswordCredential
        {
            print("Password - ", applePasswordCredential.password)
        }
    }
}

extension LoginVC: ASAuthorizationControllerPresentationContextProviding
{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return view.window!
    }
}

extension LoginVC: UITextFieldDelegate
{
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setTextfieldsBorder(color: k_baseColor, tf: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setTextfieldsBorder(color: .white, tf: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        setTextfieldsBorder(color: .white, tf: textField)
        textField.resignFirstResponder()
        return true
    }
}

extension LoginVC
{
    // MARK: IB Actions
    
    @IBAction func btnLogin_Clicked(btn:UIButton)
    {
        self.view.endEditing(true)
        
        if k_helper.isNetworkAvailable ==  "Available"
        {
            print("- - - - - - -")
            print("call Web service")
            print("- - - - - - -")
            
            guard let email:String = txtFld_Email.text, email.isEmpty == false else {
                self.showAlertWithTitle(title: "Alerta", message: "Por favor introduzca una dirección de correo eléctronico", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
            guard let password:String = txtFld_Passowrd.text, password.isEmpty == false else
            {
                self.showAlertWithTitle(title: "Alerta", message: "Por favor, ingrese contraseña", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
            
            if self.isValidEmail(testStr: email) == false
            {
                self.showAlertWithTitle(title: "Alerta", message: "La dirección de correo electrónico es inválida", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
            else
            {
                self.callServerToLoginWith(email: email, password: password)
            }
        }
        else
        {
            DispatchQueue.main.async {
                self.showAlertWithTitle(title: "Alerta", message: "No hay conexión a internet disponible", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            }
        }
                            
    }
    
    @IBAction func btn_ForgotClicked(btn:UIButton)
    {
        let vc:ForgotVC = AppStoryboards.Login.instance.instantiateViewController(withIdentifier: "ForgotVC_ID") as! ForgotVC
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.modalPresentationCapturesStatusBarAppearance = true
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btn_RegisterClicked(btn:UIButton)
    {
        let vc:RegisterVC = AppStoryboards.Login.instance.instantiateViewController(withIdentifier: "RegisterVC_ID") as! RegisterVC
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.modalPresentationCapturesStatusBarAppearance = true
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnTermsPolicy_Clicked(btn:UIButton)
    {
        let vc:TermsPolicyVC = AppStoryboards.Login.instance.instantiateViewController(withIdentifier: "TermsPolicyVC_ID") as! TermsPolicyVC
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.modalPresentationCapturesStatusBarAppearance = true
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: FB Metohds
extension LoginVC
{
    @IBAction func btnFB_Clicked(btn:UIButton)
    {
        self.view.endEditing(true)
        getFacebookUserInfo()
    }
    
    func getFacebookUserInfo()
    {
        let fbLoginManager : LoginManager = LoginManager()
        //  "public_profile", "email", "user_friends"
        fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil)
            {
                let fbloginresult : LoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!
                {
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    print(fbloginresult.grantedPermissions)
                    print(fbloginresult.token)
                    self.getFBUserData()
                }
            }
            else
            {
                print("FB Error : \(String(describing: error))")
            }
        }
    }
    
    func getFBUserData()
    {
        if((AccessToken.current) != nil)
        {
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil)
                {
                    //everything works print the user data
                    print(result ?? "No FB Result")
                    let jsonResult:[String:Any] = result as! [String:Any]
                    if let email:String = jsonResult["email"] as? String
                    {
                        print(email)
                        self.strEmail_FB = email
                    }
                    if let name:String = jsonResult["name"] as? String
                    {
                        print(name)
                        self.strName_FB = name
                    }
                    if let id:String = jsonResult["id"] as? String
                    {
                        print(id)
                        self.strID_FB = id
                    }
                    
                    if self.strEmail_FB != ""
                    {
                        self.FBLoginSuccessNowDismiss()
                    }
                }
            })
        }
    }
    
    func FBLoginSuccessNowDismiss()
    {
        print("HERE CALL WEB SERVICE WITH FB INFO")
        let urlString:String = "\(serviceName.FBLogin.rawValue)"
                
        callServerToLoginWithFB(url: urlString, parameters: ["fbToken":"\(self.strID_FB)", "email":self.strEmail_FB,"name":self.strName_FB])
    }
}

extension LoginVC
{
    // MARK: WebService Calls
    
    func callServerToLoginWith(email:String, password:String)
    {
        let urlString:String = "\(serviceName.LoginAPIAndRefreshToken.rawValue)"

        let param :[String:String] = ["password":password,"username" : email, "grant_type":"password", "scope": "read write","client_secret":"zertu","client_id":"zertu"]
            
        let headers:[String:String] = ["Content-Type":"application/x-www-form-urlencoded", "Accept" : "application/json"]
            
        self.showSpinnerWith(title: "Cargando...")
            
        WebService.callApiWith(url: urlString, method: .post, parameter: param, header: headers, encoding: "URL", vcReff: self) { (json:[String:Any], jsonString:String, error:Error?) in
                
            self.hideSpinner()
          //   print(jsonString)
                
            if error != nil
            {
                self.showAlertWithTitle(title: "Alerta", message: "\(error!.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
                
            if let AcTok:String = json["access_token"] as? String
            {
                bearerToken = AcTok
                k_userDef.setValue(AcTok, forKey: userDefaultKeys.AccessToken.rawValue)
                
                let keychain = KeychainSwift()
                keychain.set(self.txtFld_Email.text!, forKey: "ZertuUserEmail")
                keychain.set(self.txtFld_Passowrd.text!, forKey: "ZertuUserPasscode")
                                    
                if let tok:String = json["refresh_token"] as? String
                {
                    k_userDef.setValue(tok, forKey: userDefaultKeys.RefreshToken.rawValue)
                    k_userDef.synchronize()
                        
                    DispatchQueue.main.async {
                        self.callServerToUpdateDeviceToken(bearer: AcTok)
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
    
    func callServerToLoginWithFB(url:String, parameters:[String:Any])
    {
        print(parameters)
        let headers:[String:String] = ["Content-Type":"application/json"]
        self.showSpinnerWith(title: "Cargando...")
            
        WebService.callApiWith(url: url, method: .post, parameter: parameters, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonString:String, error:Error?) in
                
            self.hideSpinner()
            print(jsonString)
                
            if error != nil
            {
                self.showAlertWithTitle(title: "Alerta", message: "\(error!.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
            
            print(json)
            
            if let dJson:[String:Any] = json["response"] as? [String:Any]
            {
                if let AcTok:String = dJson["access_token"] as? String
                {
                    bearerToken = AcTok
                    k_userDef.setValue(AcTok, forKey: userDefaultKeys.AccessToken.rawValue)
                        
                    if let tok:String = dJson["refresh_token"] as? String
                    {
                        k_userDef.setValue(tok, forKey: userDefaultKeys.RefreshToken.rawValue)
                        k_userDef.synchronize()
                            
                        DispatchQueue.main.async {
                            self.callServerToUpdateDeviceToken(bearer: AcTok)
                        }
                    }
                }
            }
                
            if let AcTok:String = json["access_token"] as? String
            {
                bearerToken = AcTok
                k_userDef.setValue(AcTok, forKey: userDefaultKeys.AccessToken.rawValue)
                    
                if let tok:String = json["refresh_token"] as? String
                {
                    k_userDef.setValue(tok, forKey: userDefaultKeys.RefreshToken.rawValue)
                    k_userDef.synchronize()
                        
                    DispatchQueue.main.async {
                        self.callServerToUpdateDeviceToken(bearer: AcTok)
                    }
                }
            }
        }
    }
    
    @objc func callServerToUpdateDeviceToken(bearer:String)
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let url2Pass = serviceName.SendPushDeviceToken.rawValue
        let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearer)"]
        let param:[String:Any] = ["token":devicePushToken]
        
        WebService.callApiWith(url: url2Pass, method: .post, parameter: param, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonString:String, error:Error?) in
            
             self.hideSpinner()
             print(jsonString)

            if error != nil
            {
                self.showAlertWithTitle(title: "Alerta", message: "\(error!.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
            
            if let code:Int = json["code"] as? Int
            {
                DispatchQueue.main.async {
                    
                    if code >= 200 && code < 300
                    {
                        isUserTappedSkipButton = false
                        let tab: BaseTabbarController = AppStoryboards.BaseTabBar.instance.instantiateViewController(withIdentifier: "BaseTabbarController_ID") as! BaseTabbarController
                        k_window.rootViewController = tab
                    }
                }
            }
        }
    }
}
