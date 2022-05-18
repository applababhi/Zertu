//
//  StaticItemTapDetailVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 8/2/21.
//  Copyright © 2021 Shalini Sharma. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import StoreKit

class StaticItemTapDetailVC: UIViewController {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnBack:UIImageView!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    var strTitle = ""
    var isModulesPaid = false
    var price = 0
    var arr_ModuleID:[String] = []
    
    var ID_MainModule = "Zertu_StaticModule_"
    var IAP_SharedSecret = "68c39ba984974c7a86df6db0efa91137"
    
    var arrTableModules:[[String:Any]] = []
    var strDescription:NSAttributedString!
    var RowHeightDescription:CGFloat = 0
    
    var briefVideoUrl_URL:URL!
    var briefVideoUrl_Thumbnail:String = ""
//    var check_briefVideoUrl = false
//    var videoCount:Int = 0 // this ll not be more than 1, as v just show briefVideoUrl if available
    
    var check_IfWindowRotated = false
    var check_SetRotateWindow = false
    var portraitFrame:CGRect!        
    var playerViewController:LandscapePlayer!
    
    var numberOfModuleShowEvaluateButton = 0

    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        portraitFrame = self.view.frame
        
        setUpTopBar()
        
        lblTitle.text = ""
        btnBack.setImageColor(color: UIColor.black)
        
        addIAPtransactionQueue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callGetCertifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if check_SetRotateWindow == true
        {
            check_SetRotateWindow = false
            check_IfWindowRotated = true
            self.view.rotate(angle: 90)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("- > > > > Handle FORCE ROTATION - - - - - - - ")
        if check_IfWindowRotated == true
        {
            self.view.rotate(angle: -90)
            check_IfWindowRotated = false
            self.view.frame = portraitFrame
        }
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
    
    func extractLinkFromVimeo(vidID:String)
    {
        VimeoVideoExtractor.extractVideoFromVideoID(videoID: vidID, thumbQuality: .eVimeoThumb640, videoQuality: .eVimeoVideo540) { (success, videoObj) in
            //
            if success
            {
                if videoObj != nil
                {
                    if let url = URL(string: videoObj!.videoURL)
                    {
                        self.briefVideoUrl_URL = url
                    }
                    self.briefVideoUrl_Thumbnail = videoObj!.thumbnailURL
                    DispatchQueue.main.async {
                        self.tblView.reloadData()
                    }
                }
                else
                {
                    print("some error occured while extraction")
                }
            }
            else
            {
                print("some error occured while extraction")
            }
        }
    }
}

extension StaticItemTapDetailVC
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

extension StaticItemTapDetailVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isModulesPaid
        {
            return 3 + arrTableModules.count  // 3 is for Title row, video row & Desc row
        }
        else
        {
            return 4 + arrTableModules.count  // 4 is for Title row, video row & Desc row & last show price row
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        if isModulesPaid == false
        {
            if indexPath.row == (3 + arrTableModules.count)
            {
                // last Row For Price
                
                return 90
            }
        }
        
        if indexPath.row == 0
        {
            // title
            return 60
        }
        else if indexPath.row == 1
        {
            // Video
            return 210
        }
        else if indexPath.row == 2
        {
            // Description
            return RowHeightDescription
        }
        else
        {
            let index = indexPath.row - 3
            let dicP:[String:Any] = arrTableModules[index]
            
            if let check:Bool = dicP["aprobado"] as? Bool
            {
                if check == false
                {
                    return 150
                }
            }
            
            return 200
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if isModulesPaid == false
        {
            if indexPath.row == (3 + arrTableModules.count)
            {
                        // last Row For Price
                        let cell:CellPaidDetail_PriceBuy = self.tblView.dequeueReusableCell(withIdentifier: "CellPaidDetail_PriceBuy") as! CellPaidDetail_PriceBuy
                        cell.selectionStyle = .none
                        cell.lblPrice.text = "Precio Preventa $\(self.price)"
                        
                        cell.btnBuy_1.isHidden = false
                        cell.btnBuy_1.layer.cornerRadius = 5.0
                        cell.btnBuy_1.layer.masksToBounds = true
                        
                        cell.btnBuy_1.setTitle("Comprar Preventa", for: .normal)
                                                                      
                        cell.btnBuy_1.addTarget(self, action: #selector(self.buyModule_IAP(btn:)), for: .touchUpInside)

                        return cell
                    }
        }
        
        if indexPath.row == 0
        {
            // title
            let cell:CellShoppingDetail_Label = self.tblView.dequeueReusableCell(withIdentifier: "CellShoppingDetail_Label") as! CellShoppingDetail_Label
            cell.selectionStyle = .none
            cell.lblTitle.text = ""
            cell.lblTitle.textColor = .darkGray

            cell.lblTitle.text = strTitle
            return cell
        }
        else if indexPath.row == 1
        {
            // Video
            let cell:CellCourseDetail_Videos = self.tblView.dequeueReusableCell(withIdentifier: "CellCourseDetail_Videos") as! CellCourseDetail_Videos
            cell.selectionStyle = .none
            
            cell.imgV_Thumbnail.image = nil
            cell.imgV_Play.isHidden = false
            cell.vVideoContainer.layer.cornerRadius = 5.0
            cell.vVideoContainer.layer.masksToBounds = true
            cell.imgV_Play.image = nil
            cell.imgV_Play.image = UIImage(named: "play")
                        
            DispatchQueue.main.async {
                cell.imgV_Thumbnail.setImageUsingUrl(self.briefVideoUrl_Thumbnail)
            }
            
            return cell
        }
        else if indexPath.row == 2
        {
            // Description
            let cell:CellCourseDetail_Description = self.tblView.dequeueReusableCell(withIdentifier: "CellCourseDetail_Description") as! CellCourseDetail_Description
            cell.selectionStyle = .none
            cell.lblDesc.attributedText = strDescription
            return cell
        }
        else
        {
            // Modules
            let index = indexPath.row - 3
            let dicP:[String:Any] = arrTableModules[index]
            let cell:CellStaticModule = self.tblView.dequeueReusableCell(withIdentifier: "CellStaticModule") as! CellStaticModule
            cell.selectionStyle = .none
            
            cell.lblViewDetail.layer.cornerRadius = 5.0
            cell.lblViewDetail.layer.masksToBounds = true
            
            cell.vBK.layer.cornerRadius = 6.0
            cell.vBK.layer.borderColor = UIColor.gray.cgColor
            cell.vBK.layer.borderWidth = 0.8
            cell.vBK.layer.masksToBounds = true
            
            cell.lblTitle.text = ""
            cell.lblHeader.text = ""
            cell.lblSubTitle.text = "Evaluación: Completado"
            
            cell.lblViewDetail.isHidden = false
            cell.lblSubTitle.isHidden = false
            cell.imgTick.isHidden = false
            cell.btn.isHidden = false
            
            if let str:String = dicP["nombre"] as? String
            {
                cell.lblTitle.text = str
            }
            if let str:String = dicP["titulo"] as? String
            {
                cell.lblHeader.text = str
            }
            
            cell.btn.tag = index
            cell.btn.addTarget(self, action: #selector(self.takeToModuleDetail(btn:)), for: .touchUpInside)

            if let check:Bool = dicP["aprobado"] as? Bool
            {
                print("- - - - - > > > > : : : : > ")
                print(dicP)
                if check == false
                {
                    cell.lblSubTitle.isHidden = true
                  //  cell.lblViewDetail.isHidden = true
                  //  cell.btn.isHidden = true
                    cell.imgTick.isHidden = true
                    
                    if index == 0
                    {
                        // for first module index, always show button for Evaluation
                        cell.lblViewDetail.isHidden = false
                        cell.btn.isHidden = false
                    }
                    else if index == numberOfModuleShowEvaluateButton
                    {
                        // here we are checking, if previous module is evaluated as true, then show button for current module to take test
                          cell.lblViewDetail.isHidden = false
                          cell.btn.isHidden = false
                    }
                    else if index > numberOfModuleShowEvaluateButton
                    {
                        // if index is greater than count, then hide the button
                          cell.lblViewDetail.isHidden = true
                          cell.btn.isHidden = true
                    }
                }
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1
        {
            // VIDEO CELL
            
            check_SetRotateWindow = true
            
            // print(briefVideoUrl_URL)
            let player = AVPlayer(url: briefVideoUrl_URL)
            
            playerViewController = LandscapePlayer()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                self.playerViewController.player!.play()
            }
        }
    }
    
    @objc func buyModule_IAP(btn:UIButton)
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
                
            })
            alert.addAction(cancel)
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
            
            return
        }
        
        print("Buy Modules - - - IAP Starts")
        self.showSpinnerWith(title: "Cargando...")
        
        print("- - - Buy Course - - ")
        
        if (SKPaymentQueue.canMakePayments())
        {
            let productID:NSSet = NSSet(array: [self.ID_MainModule as NSString]);
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
            productsRequest.delegate = self;
            productsRequest.start();
            print("Fetching Products");
        } else {
            print("can't make purchases");
            self.hideSpinner()
        }
    }
    
    @objc func takeToModuleDetail(btn:UIButton)
    {
        let dicP:[String:Any] = arrTableModules[btn.tag]
        if let id:Int = dicP["id"] as? Int
        {
            print("Module ID: ", id)
            callGetDetailModule(id: "\(id)")
        }
    }
}

extension StaticItemTapDetailVC
{
    func callGetCertifications()
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.GetCertifications.rawValue
        var headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
      
        if isUserTappedSkipButton == true{
            headers = ["Content-Type":"application/json"]
        }
        
        WebService.callApiWith(url: urlStr, method: .get, parameter: nil, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
 //       print(jsonStr)
            self.hideSpinner()
            
            if error != nil
            {
                self.showAlertWithTitle(title: "Alerta", message: "\(error!.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
            
            self.ID_MainModule = "Zertu_StaticModule_"
            self.arr_ModuleID.removeAll()
            self.arrTableModules.removeAll()
            if let code:Int = json["code"] as? Int
            {
                if code >= 200 && code < 300
                {
                    if let arr:[[String:Any]] = json["response"] as? [[String:Any]]
                    {
                        if arr.count > 0
                        {
                            let d:[String:Any] = arr.first!
                            
                            if let strTitel:String = d["nombre"] as? String
                            {
                                self.strTitle = strTitel
                            }
                            
                            if let IAP_ID:Int = d["id"] as? Int
                            {
                                self.ID_MainModule = self.ID_MainModule + "\(IAP_ID)"
                            }
                            
                            if let str:String = d["promoUrl"] as? String
                            {
                                var strVideo:String = str
                                
                                if strVideo.contains("?")
                                {
                                    strVideo = strVideo.components(separatedBy: "?").first!
                                    
                                    let videoID = (strVideo as NSString).lastPathComponent
                                    self.extractLinkFromVimeo(vidID: videoID)
                                }
                                else
                                {
                                    let videoID = (strVideo as NSString).lastPathComponent
                                    self.extractLinkFromVimeo(vidID: videoID)
                                }
                            }
                            
                            if let strDes:String = d["descripcion"] as? String
                            {
                                let attributes = [NSAttributedString.Key.font: UIFont(name: CustomFont.GSLRegular, size: 22)!,
                                                  NSAttributedString.Key.foregroundColor: UIColor.darkGray]

                                self.strDescription = NSAttributedString(string: strDes.htmlToString, attributes: attributes)
                                
                                let height = strDes.heightWithConstrainedWidth(UIScreen.main.bounds.width - 15, font: UIFont.boldSystemFont(ofSize: 18.0))
                                self.RowHeightDescription = height! // + 40
                            }
                            
                            if let arrMod:[[String:Any]] = d["modulos"] as? [[String:Any]]
                            {
                                self.arrTableModules = arrMod
                                var checkNumberOfShowButton = 0
                                
                                for dM in arrMod
                                {
                                    if let id:Int = dM["id"] as? Int
                                    {
                                        self.arr_ModuleID.append("\(id)")
                                    }
                                    
                                    if let check:Bool = dM["aprobado"] as? Bool
                                    {
                                        print("Check - - - - ? ", check)
                                        if check == true
                                        {
                                            checkNumberOfShowButton = checkNumberOfShowButton + 1
                                        }
                                    }
                                }
                                self.numberOfModuleShowEvaluateButton = checkNumberOfShowButton
                            }
                            
                            if let check:Bool = d["pagada"] as? Bool
                            {
                                self.isModulesPaid = check
                            }
                                                        
                            if let price:Int = d["precio"] as? Int
                            {
                                self.price = price
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.tblView.delegate = self
                            self.tblView.dataSource = self

                            self.tblView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func callGetDetailModule(id:String)
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.GetModuleDetail.rawValue + id
        var headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
      
        if isUserTappedSkipButton == true{
            headers = ["Content-Type":"application/json"]
        }
        
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
                    if let D_main:[String:Any] = json["response"] as? [String:Any]
                    {
                     
                        DispatchQueue.main.async {
                            let vc:ModuleDetailVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "ModuleDetailVC_ID") as! ModuleDetailVC
                            vc.currentID = id
                            vc.arr_ModuleID = self.arr_ModuleID
                            vc.dictMain = D_main
                            vc.reffStaticVC = self
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
        }
    }
}

// MARK: IN-APP Purchase
extension StaticItemTapDetailVC: SKPaymentTransactionObserver, SKProductsRequestDelegate
{
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    {
        print("- - - - PRODUCTS IAP - - - - \n ", response.products)
        print("\n - - - - - -")
        let count : Int = response.products.count
        if (count>0) {

            let validProduct: SKProduct = response.products[0] as SKProduct
            if (validProduct.productIdentifier == self.ID_MainModule as String) {
                print("- - Product Detail - - - -")
                print(validProduct.localizedTitle)
                print(validProduct.localizedDescription)
                print(validProduct.price)
                
                self.buyProduct(product: validProduct)
                
            } else {
                print(validProduct.productIdentifier)
                self.hideSpinner()
            }
        } else {
            print("nothing")
            self.hideSpinner()
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error)
    {
        print("Error Fetching product information");
        self.hideSpinner()
    }
    
    func buyProduct(product: SKProduct)
    {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
     
    func addIAPtransactionQueue()
    {
        SKPaymentQueue.default().add(self)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction:AnyObject in transactions
        {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction
            {
                switch trans.transactionState
                {
                case .purchased:
                    print(" - - - - In App Payment Success - - - Call Apple Api for Receipt Validation - -")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    DispatchQueue.main.async {
                        self.hideSpinner()
//                        self.back()
                        self.validateReceipt()
                    }
                    break
                    case .restored:
                    print(" - - - - In App RESTORED Success  - -")
                    
                    break
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    print("Show Payment failed Alert")
                    
                    DispatchQueue.main.async {
                        self.hideSpinner()
                    }
                    break
                default:
                    print("SOME Other Update transaction state like purchasing or restore")
                    break
                }
            }
        }
    }
    
    func validateReceipt(){
        
        self.showSpinnerWith(title: "Cargando...")
        
   //     let urlString = "https://sandbox.itunes.apple.com/verifyReceipt"   // Sandbox
        let urlString = "https://buy.itunes.apple.com/verifyReceipt"   // Production
        
        guard let receiptURL = Bundle.main.appStoreReceiptURL, let receiptString = try? Data(contentsOf: receiptURL).base64EncodedString() , let url = URL(string: urlString) else {
                return
        }
        
        let requestData : [String : Any] = ["receipt-data" : receiptString,
                                            "password" : self.IAP_SharedSecret,
                                            "exclude-old-transactions" : false]
        let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request)  { (data, response, error) in
            // convert data to Dictionary and view purchases
            DispatchQueue.main.async {
                self.hideSpinner()
                if let data = data, let jsonData:[String:Any] = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]{
                // your non-consumable and non-renewing subscription receipts are in `in_app` array
                // your auto-renewable subscription receipts are in `latest_receipt_info` array
                    
                 //   print(jsonData)
                    
                    if let jsonApple:[String:Any] = jsonData["receipt"] as? [String:Any]
                    {
                        if let arrPurchases:[[String:Any]] = jsonApple["in_app"] as? [[String:Any]]
                        {
                            for dic in arrPurchases
                            {
                                if let strProdId:String = dic["product_id"] as? String
                                {
                                    if strProdId == self.ID_MainModule
                                    {
                                        if let strTransactionID:String = dic["original_transaction_id"] as? String
                                        {
                                            print("Receipt - - > > ", strTransactionID)
                                            self.callServerToSendReceipt(receiptId: strTransactionID)
                                        }
                                        break
                                    }
                                }
                            }
                        }
                    }
              }
            }
        }.resume()
    }
    
    func callServerToSendReceipt(receiptId:String)
    {
        self.showSpinnerWith(title: "Cargando...")
        print("Updating Receipt to Backend - - - - ")
        var courseID = self.ID_MainModule.components(separatedBy: "Zertu_StaticModule_").last!
                
        let urlStr = serviceName.SendIAPReceipt_Module.rawValue
        let param:[String:Any] = ["tokenId":receiptId, "certificacionId":courseID]
        print(param)
        let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        print(headers)
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
                    DispatchQueue.main.async {
                        self.showAlertWithTitle(title: "Zertu", message: "Pago exitoso", okButton: "Ok", cancelButton: "", okSelectorName: #selector(self.back))
                        return
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

/*
extension StaticItemTapDetailVC
{
    /*
    func showRestoreAlert()
    {
        let alert = UIAlertController(title: "Zertú", message: "Como ya compró los productos de Zertú, ahora es el momento de Restaurar todos los productos que compró. Haga clic en Restaurar para continuar.", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Restaurar", style: .default, handler: { action in
            DispatchQueue.main.async {
                self.callRestore()
            }
        })
        alert.addAction(ok)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    */
    
    @objc func callRestore()
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
                
            })
            alert.addAction(cancel)
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
            
            return
        }
        
        if SKPaymentQueue.canMakePayments(){
            
            self.showSpinnerWith(title: "La restauración está en curso...")
            
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
        else{
            print("restored faild, IAP not activ?")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error)
    {
        print(error.localizedDescription)
        DispatchQueue.main.async {
            self.hideSpinner()
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("transactions restored")
        
        if queue.transactions.count == 0
        {
            print("The account you are login, has purchased course but, this apple id till now never bought any item from IAP")
            DispatchQueue.main.async {
                self.hideSpinner()
                
                let alert = UIAlertController(title: "Zertú", message: "No encontramos ningún producto comprado con este ID de Apple. Intente con otro ID de Apple utilizado para comprar los productos.", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "Ok", style: .default, handler: { action in
                    // show one more alert which says we found u already purchased this product using our web portal, so we are unlocking this course for u  - - - -     self.pushUserBackToHome()
                })
                alert.addAction(ok)
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true)
                })
                return
            }
        }
        
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction
            let prodID = t.payment.productIdentifier as String
            
            print("- - - Purchased Product Id - ", prodID)
            
            self.arrRestoredProducts.append(prodID)
            /*
             switch prodID {
             case "com.SubMonth":
             //  pushToCourseVideoDetailScreen()
             break
             case "com.SubYear":
             // pushToCourseVideoDetailScreen()
             break
             default:
             print("IAP not found")
             }
             */
        }
        
        if self.arrRestoredProducts.count > 0
        {
            if self.arrRestoredProducts.count == self.arrUpdateTransactionCalled.count
            {
                let alert = UIAlertController(title: "Zertú", message: "Felicidades. Se restauran todas las compras anteriores. Vaya a la página de inicio y vuelva a visitar el curso.", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "Ok", style: .default, handler: { action in
                    self.pushUserBackToHome()
                })
                alert.addAction(ok)
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true)
                })
            }
        }
        
        
    }
    
    func pushUserBackToHome()
    {
        isUserRestoredAllPurchases = true
        
        k_userDef.set(true, forKey: userDefaultKeys.userRestoredAllPurchases.rawValue)
        k_userDef.synchronize()
        
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
*/
