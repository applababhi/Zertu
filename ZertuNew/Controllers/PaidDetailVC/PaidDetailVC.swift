//
//  PaidDetailVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 5/12/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import StoreKit

/* Sandbox tester Detail
 nakuloct4@gmail.com/Abhi$hek25
 zertutest@gmail.com/Abhi$hek25
 */

class PaidDetailVC: UIViewController {
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    var arrCards:[[String:Any]] = []
    var dictCourse:[String:Any] = [:]
    var arrTable:[String] = []   // ["ImageHeader", "Description", "Video", "Cards", "Buy"] // remove Card Section, as now we include IAP  May2020
    var strDescription:NSAttributedString!
    var RowHeightDescription:CGFloat = 0
    var strImgUrl = ""
    
    var briefVideoUrl_URL:URL!
    var briefVideoUrl_Thumbnail:String = ""
    var check_briefVideoUrl = false
    var videoCount:Int = 0 // this ll not be more than 1, as v just show briefVideoUrl if available
    
    var check_IfWindowRotated = false
    var check_SetRotateWindow = false
    var portraitFrame:CGRect!
    
    var IAP_ProductID:String = "Zertu_"
    var IAP_SharedSecret = "68c39ba984974c7a86df6db0efa91137" // get it from itunesconnect > app > features > IAP > App Specific Shared Secret
    
    var arrRestoredProducts:[String] = []
    var arrUpdateTransactionCalled:[String] = []
    var isRestoreCall = false
    var isPaidClick = false
    
    var playerViewController:LandscapePlayer!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if check_SetRotateWindow == true
        {
            check_SetRotateWindow = false
            check_IfWindowRotated = true
            self.view.rotate(angle: 90)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        portraitFrame = self.view.frame
        
      //  IAP_ProductID = IAP_ProductID.components(separatedBy: "Zertu_").last!
      //  print(IAP_ProductID)
        
        setUpTopBar()
        addIAPtransactionQueue()
        
      //  print(dictCourse)
        
        if let courseID:String = dictCourse["id"] as? String
        {
            if courseID == "54"
            {
                IAP_ProductID = "Zertu__"  // A special case for "Piensa y hazlo realidad" as in In App Purchase Portal, just for this we change the format from Zertu_ to Zertu__
            }
            
            IAP_ProductID = IAP_ProductID + courseID
            print(IAP_ProductID)
        }
        if let courseID:Int = dictCourse["id"] as? Int
        {
            if courseID == 54
            {
                IAP_ProductID = "Zertu__"  // A special case for "Piensa y hazlo realidad" as in In App Purchase Portal, just for this we change the format from Zertu_ to Zertu__
            }

            IAP_ProductID = IAP_ProductID + "\(courseID)"
            print(IAP_ProductID)
        }
        
        if let str:String = dictCourse["name"] as? String
        {
            lblTitle.text = str
        }
        if let strUrl:String = dictCourse["coverImageUrl"] as? String
        {
            if strUrl.contains("https") == false
            {
                // let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
                //   let strToEncode = str.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
                let imgLink = "\(baseImgUrl)" + strUrl
                strImgUrl = imgLink
            }
            else
            {
                strImgUrl = strUrl
            }
        }
        if let strUrl:String = dictCourse["newImageUrl"] as? String
        {
            if strUrl.contains("https") == false
            {
                // let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
                //   let strToEncode = str.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
                let imgLink = "\(baseImgUrl)" + strUrl
                strImgUrl = imgLink
            }
            else
            {
                strImgUrl = strUrl
            }
        }
        if let strDesc:String = dictCourse["mobileDescription"] as? String
        {
           // print(strDesc)
            let attributes = [NSAttributedString.Key.font: UIFont(name: CustomFont.GSLRegular, size: 20)!,
                              NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            
            let strUpdate:String = strDesc
            
            /*
             if strDesc.contains("\t")
             {
             strUpdate = strUpdate.replacingOccurrences(of: "\t", with: "")
             strUpdate = strUpdate.replacingOccurrences(of: "\n", with: "")
             }
             
             if strUpdate.contains("\t")
             {
             print("Yes")
             }
             */
            
            self.strDescription = NSAttributedString(string: strUpdate.htmlToString, attributes: attributes)
            
          //  let height = strUpdate.heightWithConstrainedWidth(UIScreen.main.bounds.width - 100, font: UIFont(name: CustomFont.GSLRegular, size: 21)!)
            
            let height = self.strDescription.height(containerWidth: UIScreen.main.bounds.width - 30)
            
            RowHeightDescription = height //+ 40
        }
        if let str:String = dictCourse["briefVideoUrl"] as? String
        {
            var strVideo:String = str
            
            if strVideo.contains("?")
            {
                strVideo = strVideo.components(separatedBy: "?").first!
                
                let videoID = (strVideo as NSString).lastPathComponent
                self.extractLinkFromVimeoFor_briefVideoUrl(vidID: videoID)
            }
            else
            {
                let videoID = (strVideo as NSString).lastPathComponent
                self.extractLinkFromVimeoFor_briefVideoUrl(vidID: videoID)
            }
        }
    }
    
    func extractLinkFromVimeoFor_briefVideoUrl(vidID:String)
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
                    self.videoCount = 1
                    self.briefVideoUrl_Thumbnail = videoObj!.thumbnailURL
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
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("- > > > > Handle FORCE ROTATION - - - - - - - ")
        
        if check_IfWindowRotated == true
        {
            self.view.rotate(angle: -90)
            check_IfWindowRotated = false
            self.view.frame = portraitFrame
        }
        
        self.perform(#selector(self.callApi), with: nil, afterDelay: 1.0)
    }
    
    @objc func callApi(){
//        callServerToGetLinkedCards() no need to show cards now as we use IAP May2020
        
        self.arrTable.append("ImageHeader")
        self.arrTable.append("Description")
        
        if let str:String = self.dictCourse["briefVideoUrl"] as? String
        {
            self.arrTable.append("Video")
        }
        
        self.arrTable.append("Buy")
        
        DispatchQueue.main.async {
            self.tblView.delegate = self
            self.tblView.dataSource = self
            self.tblView.reloadData()
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
}

extension PaidDetailVC
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

extension PaidDetailVC: UITableViewDelegate, UITableViewDataSource
{
    // MARK: TableView protocols
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrTable.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let strType:String = arrTable[indexPath.row]
        if strType.localizedStandardContains("ImageHeader")
        {
            return 250
        }
        else if strType.localizedStandardContains("Description")
        {
            return RowHeightDescription
        }
        else if strType.localizedStandardContains("Video")
        {
            return 210
        }
        else if strType.localizedStandardContains("Card")
        {
            if self.arrCards.count == 0
            {
                return 0
            }
            return 60
        }
        else
        {
            // Buy
            return 150 // 200
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let strType:String = arrTable[indexPath.row]
        if strType.localizedStandardContains("ImageHeader")
        {
            let cell:CellPaidDetail_Header = self.tblView.dequeueReusableCell(withIdentifier: "CellPaidDetail_Header") as! CellPaidDetail_Header
            cell.selectionStyle = .none
            
            cell.vBk.backgroundColor = .clear
            //  print(strImgUrl)
            cell.imgView.setImageUsingUrl(strImgUrl)
            
            return cell
        }
        else if strType.localizedStandardContains("Description")
        {
            let cell:CellPaidDetail_Description = self.tblView.dequeueReusableCell(withIdentifier: "CellPaidDetail_Description") as! CellPaidDetail_Description
            cell.selectionStyle = .none
            
            cell.lblDesc.attributedText = self.strDescription
            
            return cell
        }
        else if strType.localizedStandardContains("Video")   //  briefVideoUrl  Video
        {
            let cell:CellCourseDetail_Videos = self.tblView.dequeueReusableCell(withIdentifier: "CellCourseDetail_Videos_Brief") as! CellCourseDetail_Videos
            cell.selectionStyle = .none
            
            cell.imgV_Thumbnail.image = nil
            cell.lblTitle.text = ""
            cell.btnLock.isHidden = true
            cell.imgV_Play.isHidden = false
            cell.vVideoContainer.layer.cornerRadius = 5.0
            cell.vVideoContainer.layer.masksToBounds = true
            
            cell.imgV_Play.image = nil
            cell.imgV_Play.image = UIImage(named: "play")
            //  cell.imgV_Play.layer.cornerRadius = 20.0
            //  cell.imgV_Play.layer.masksToBounds = true
            
            
            DispatchQueue.main.async {
                cell.imgV_Thumbnail.setImageUsingUrl(self.briefVideoUrl_Thumbnail)
            }
            
            return cell
        }
        else if strType.localizedStandardContains("Card")
        {
            var indextopas:Int = indexPath.row - 3 // -3 ["ImageHeader", "Description", "Video"], as "Buy", gets added in arrTable in last
            
            if self.briefVideoUrl_URL == nil
            {
                indextopas = indexPath.row - 2
            }
            
            let dict:[String:Any] = arrCards[indextopas]
            
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
            }
            
            cell.btnFullRow.tag = indextopas
            cell.btnFullRow.addTarget(self, action: #selector(self.fullRow_Clicked(btn:)), for: .touchUpInside)
            
            return cell
        }
        else
        {
            // Buy
            let cell:CellPaidDetail_PriceBuy = self.tblView.dequeueReusableCell(withIdentifier: "CellPaidDetail_PriceBuy") as! CellPaidDetail_PriceBuy
            cell.selectionStyle = .none
//            cell.lblPrice.text = ""
            
            cell.btnBuy_1.isHidden = false
//            cell.btnBuy_2.isHidden = false
            cell.btnBuy_3.isHidden = true
            cell.btnRestore.isHidden = false
            
            cell.btnBuy_1.layer.cornerRadius = 5.0
//            cell.btnBuy_2.layer.cornerRadius = 5.0
            cell.btnBuy_3.layer.cornerRadius = 5.0
            cell.btnBuy_1.layer.masksToBounds = true
//            cell.btnBuy_2.layer.masksToBounds = true
            cell.btnBuy_3.layer.masksToBounds = true
            
            cell.btnRestore.layer.cornerRadius = 5.0
            cell.btnRestore.layer.masksToBounds = true
            print(dictCourse)
            if let price:Double = dictCourse["price"] as? Double
            {
                cell.btnBuy_1.setTitle("PRECIO TOTAL $\(Int(price))", for: .normal)
            }
            
            if let price:Int = dictCourse["price"] as? Int
            {
                cell.btnBuy_1.setTitle("PRECIO TOTAL $\(price)", for: .normal)
            }
            
            if let price:Double = dictCourse["priceTwo"] as? Double
            {
               // cell.btnBuy_2.setTitle("PUEDO PAGAR $\(Int(price))", for: .normal)
            }
            
            if let price:Int = dictCourse["priceTwo"] as? Int
            {
              //  cell.btnBuy_2.setTitle("PUEDO PAGAR $\(price)", for: .normal)
            }
            
            if let price:Double = dictCourse["priceThree"] as? Double
            {
                cell.btnBuy_3.isHidden = false
                cell.btnBuy_3.setTitle("POR AHORA NO PUEDO PAGAR $\(Int(price))", for: .normal)
            }
            
            if let price:Int = dictCourse["priceThree"] as? Int
            {
                cell.btnBuy_3.isHidden = false
                cell.btnBuy_3.setTitle("POR AHORA NO PUEDO PAGAR $\(price)", for: .normal)
            }
            // Only Call IAP for btnBuy_1 & btnBuy_2, for btnBuy_3, as its free call direct API
                                        
            cell.btnBuy_1.addTarget(self, action: #selector(self.buyCourse_Price1_Clicked(btn:)), for: .touchUpInside)
           // cell.btnBuy_2.addTarget(self, action: #selector(self.buyCourse_Price2_Clicked(btn:)), for: .touchUpInside)
            cell.btnBuy_3.addTarget(self, action: #selector(self.buyCourse_Price3_Clicked(btn:)), for: .touchUpInside)
            
            cell.btnRestore.addTarget(self, action: #selector(self.callRestore), for: .touchUpInside)
            
            /*
            if isRestoreCall == true
            {
                cell.btnBuy_1.isHidden = true
                cell.btnBuy_2.isHidden = true
                cell.btnBuy_3.isHidden = true
                cell.btnRestore.isHidden = false
            }
            */
            
            /*  no need of this check as we implemented IAP and hide zertu cards from this screen May2020
            if arrCards.count == 0
            {
                cell.c_bBuy_Ht.constant = 0
            }
            */

            //            cell.btnAddCard.addTarget(self, action: #selector(self.addNewCard_Clicked(btn:)), for: .touchUpInside)
            // hide add card button as no need now because of IAP  May2020
//            cell.btnAddCard.isHidden = true

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let strType:String = arrTable[indexPath.row]
        if strType.localizedStandardContains("Video")
        {
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
    
    @objc func addNewCard_Clicked(btn:UIButton)
    {
        print("- - - Add New Card -")
        let vc:AddCardConektaVC = AppStoryboards.MyProfile.instance.instantiateViewController(identifier: "AddCardConektaVC_ID") as! AddCardConektaVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PaidDetailVC
{
    func callServerToGetLinkedCards()
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
            
            self.arrCards.removeAll()
            self.arrTable.removeAll()
            self.tblView.reloadData()
            
            if let code:Int = json["code"] as? Int
            {
                if code >= 200 && code < 300
                {
                    if let arr:[[String:Any]] = json["response"] as? [[String:Any]]
                    {
                        self.arrCards = arr
                        
                        self.arrTable.append("ImageHeader")
                        self.arrTable.append("Description")
                        
                        if let str:String = self.dictCourse["briefVideoUrl"] as? String
                        {
                            self.arrTable.append("Video")
                        }
                        
                        for ind in 0..<arr.count
                        {
                            self.arrTable.append("Card - \(ind)")
                        }
                        
                        self.arrTable.append("Buy")
                        
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
    
    func callServerToSetDefaultCard(id:String)
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.MakeCardDefault.rawValue
        let param:[String:Any] = ["paymentToken":id]
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
                        DispatchQueue.main.async {
                            self.showAlertWithTitle(title: "Zertu", message: msg, okButton: "Ok", cancelButton: "", okSelectorName: nil)
                            self.callServerToGetLinkedCards()
                            return
                        }
                    }
                }
            }
        }
    }
    
    @objc func callServerToMakePayment(courseID:Int)
    {
         // No More calling this Method as using IAP
        
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.PayCourseByConekta.rawValue
        let param:[String:Any] = ["id":courseID]
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
                if code >= 200
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
            if let msgErrorJSON:String = json["error500"] as? String
            {
               // self.showAlertWithTitle(title: "Alerta", message: "Ocurrió algún error, intente nuevamente después de algún tiempo", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
        }
        
        
        
        /*
         callRefreshToken { (tokenT:String) in
         
         let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(tokenT)"]
         self.callServerFor(method: "POST", urlStr: serviceName.PayCourseByConekta.rawValue, param: ["id":courseID], header: headers, encoding: "JSON") { (dictFetched:[String:Any], err:Error?) in
         //         print(dictFetched)
         self.hideSpinner()
         
         if err != nil
         {
         print("An error came - ", err!)
         return
         }
         
         if let code:Int = dictFetched["code"] as? Int
         {
         if code >= 200 && code < 300
         {
         // its a success
         if let msg:String = dictFetched["response"] as? String
         {
         DispatchQueue.main.async {
         
         self.showAlertWithTitle(title: "Zertu!", message: msg, okButton: "Ok", cancelButton: "", okSelectorName: #selector(self.setCategoryVC))
         return
         }
         }
         }
         else if code >= 500
         {
         // its a failure
         if let msg:String = dictFetched["response"] as? String
         {
         DispatchQueue.main.async {
         // viewDidLoad
         self.showAlertWithTitle(title: "Zertu!", message: msg, okButton: "Ok", cancelButton: "", okSelectorName: #selector(self.setCategoryVC))
         return
         }
         }
         }
         }
         }
         }
         */
    }
    
    @objc func back()
    {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: IN-APP Purchase
extension PaidDetailVC: SKPaymentTransactionObserver, SKProductsRequestDelegate
{
    @objc func buyCourse_Price1_Clicked(btn:UIButton)
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
        
        isPaidClick = true
        
        self.showSpinnerWith(title: "Cargando...")
        
        print("- - - Buy Course - - ")
        
        if (SKPaymentQueue.canMakePayments())
        {
            let productID:NSSet = NSSet(array: [self.IAP_ProductID as NSString]);
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
            productsRequest.delegate = self;
            productsRequest.start();
            print("Fetching Products");
        } else {
            print("can't make purchases");
            self.hideSpinner()
        }
        
        /*
         
         OLD METHOD TO BUY FROM BACKEND ANDRES
         
         if let courseID:Int = dictCourse["id"] as? Int
         {
         print("Its PAID course with ID - ", courseID)
         
         let alertController = UIAlertController(title: "Confirmación de pago", message: "¿Estás seguro de que deseas comprar el curso?", preferredStyle: .alert)
         let okAction = UIAlertAction(title: "SÍ", style: UIAlertAction.Style.default) {
         UIAlertAction in
         NSLog("Pagar button Pressed")
         
         self.callServerToMakePayment(courseID: courseID)
         }
         let cancelAction = UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel) {
         UIAlertAction in
         NSLog("No Pressed PAGAR Button")
         }
         alertController.addAction(okAction)
         alertController.addAction(cancelAction)
         self.present(alertController, animated: true, completion: nil)
         }
         */
    }
    
    @objc func buyCourse_Price2_Clicked(btn:UIButton)
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
        
        isPaidClick = true
        
        self.IAP_ProductID = self.IAP_ProductID + "_2"
        
        self.showSpinnerWith(title: "Cargando...")
        
        print("- - - Buy Course - - ")
        
        if (SKPaymentQueue.canMakePayments())
        {
            let productID:NSSet = NSSet(array: [self.IAP_ProductID as NSString]);
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
            productsRequest.delegate = self;
            productsRequest.start();
            print("Fetching Products");
        } else {
            print("can't make purchases");
            self.hideSpinner()
        }
        
        /*
         
         OLD METHOD TO BUY FROM BACKEND ANDRES
         
         if let courseID:Int = dictCourse["id"] as? Int
         {
         print("Its PAID course with ID - ", courseID)
         
         let alertController = UIAlertController(title: "Confirmación de pago", message: "¿Estás seguro de que deseas comprar el curso?", preferredStyle: .alert)
         let okAction = UIAlertAction(title: "SÍ", style: UIAlertAction.Style.default) {
         UIAlertAction in
         NSLog("Pagar button Pressed")
         
         self.callServerToMakePayment(courseID: courseID)
         }
         let cancelAction = UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel) {
         UIAlertAction in
         NSLog("No Pressed PAGAR Button")
         }
         alertController.addAction(okAction)
         alertController.addAction(cancelAction)
         self.present(alertController, animated: true, completion: nil)
         }
         */
    }
    
    @objc func buyCourse_Price3_Clicked(btn:UIButton)
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
        
        isPaidClick = true
        
        if let courseID:Int = dictCourse["id"] as? Int
        {
            callServerToMakeFreePayment(courseID: "\(courseID)")
        }
        
        if let courseID:String = dictCourse["id"] as? String
        {
            callServerToMakeFreePayment(courseID: courseID)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if isPaidClick == true  // means not a restore call
        {
            print("- - - - PRODUCTS IAP - - - - \n ", response.products)
            print("\n - - - - - -")
            let count : Int = response.products.count
            if (count>0) {

                let validProduct: SKProduct = response.products[0] as SKProduct
                if (validProduct.productIdentifier == self.IAP_ProductID as String) {
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
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    DispatchQueue.main.async {
                        self.hideSpinner()
                        
                        print(">>>>>>>   updatedTransactions")
                        
                        self.arrUpdateTransactionCalled.append("updatedTransactions")
                        
                        // check count of array of all  purchased products and this delegagte called equal then all process completed, then proceed.
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
                                    if strProdId == self.IAP_ProductID
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
        var courseID = self.IAP_ProductID.components(separatedBy: "Zertu_").last!
        
        if courseID.contains("_2")
        {
            courseID = courseID.components(separatedBy: "_2").first!
        }
        
        let urlStr = serviceName.SendIAPReceipt.rawValue
        let param:[String:Any] = ["receipt":receiptId, "courseId":courseID]
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
    
    func callServerToMakeFreePayment(courseID:String)
    {
        self.showSpinnerWith(title: "Cargando...")

        let urlStr = serviceName.PostFreePayCourse.rawValue
        let param:[String:Any] = ["id":courseID, "price":"0"]
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
}

extension PaidDetailVC
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
