//
//  ConektaPayDetailVC.swift
//  Zertu
//
//  Created by Abhishek Bhardwaj on 14/6/18.
//  Copyright © 2018 Abhishek Bhardwaj. All rights reserved.
//

import UIKit

class ConektaPayDetailVC: UIViewController {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!

    @IBOutlet weak var lbl_Courses:UILabel!
    @IBOutlet weak var lbl_PricePerPerson:UILabel!
    @IBOutlet weak var lbl_NumOfPerson:UILabel!
    @IBOutlet weak var lbl_Total:UILabel!
    @IBOutlet weak var tblView:UITableView!
    
    var arr_CardList:[[String:Any]] = []
    var strPrice = ""
    var strCourse = ""
    var CourseID = 0
    var strPricePerPerson = ""
    var numberofPersons = 0
    
    var arrPersons:[[String:Any]] = []
    
    var selectedCardIDforDefaultCard:String = ""
    
   // var view_White:UIView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTopBar()
        
        lblTitle.text = "Review Purchase"
        
        let course:String = "Curso: \(strCourse)"
        lbl_Courses.attributedText = self.setAttributedString(str: course)
        
        let perPerson:String = "Precio por boleto: $\(strPricePerPerson)"
        lbl_PricePerPerson.attributedText = self.setAttributedString(str: perPerson)
        
        let numPerson:String = "Número de boletos: \(numberofPersons)"
        lbl_NumOfPerson.attributedText = self.setAttributedString(str: numPerson)
        
        let total:String = "Total: $\(strPrice)"
        lbl_Total.attributedText = self.setAttributedString(str: total)
        
        tblView.dataSource = self
        tblView.delegate = self
        
        self.perform(#selector(self.callServerToGetLinkedCards), with: nil, afterDelay: 0.1)
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
        let attrs2 = [NSAttributedString.Key.font :  UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.black]
        
        let attributedString1 = NSMutableAttributedString(string:str1, attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:" \(str2)", attributes:attrs2)
        
        attributedString1.append(attributedString2)
        
        return attributedString1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc func callServerToGetLinkedCards()
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
                        self.arr_CardList.append(contentsOf: arr)
                        DispatchQueue.main.async {
                            self.tblView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
}

extension ConektaPayDetailVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arr_CardList.count == 0 ? 1 : arr_CardList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.model == "iPad"
        {
            return 40
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if arr_CardList.count == 0
        {
            let cell:Cell_NoCardFound = tblView.dequeueReusableCell(withIdentifier: "Cell_NoCardFound", for: indexPath) as! Cell_NoCardFound
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            return cell
        }
        else
        {
            let dict = arr_CardList[indexPath.row]
            
            let cell:Cell_RegisteredCard = tblView.dequeueReusableCell(withIdentifier: "Cell_RegisteredCard", for: indexPath) as! Cell_RegisteredCard
            cell.selectionStyle = .none
            cell.lbl_CardType.text = ""
            cell.lbl_CardNumber.text = ""
            cell.imgView.contentMode = .scaleAspectFit
            cell.imgView.image = nil
            
            cell.view_Bk.layer.cornerRadius = 5.0
            cell.view_Bk.layer.borderColor = UIColor.lightGray.cgColor
            cell.view_Bk.layer.borderWidth = 1.0
            cell.view_Bk.layer.masksToBounds = true
            
            if let strType:String = dict["type"] as? String
            {
                cell.lbl_CardType.text = strType
            }
            if let strNum:String = dict["maskedNumber"] as? String
            {
                cell.lbl_CardNumber.text = strNum
            }
            if let check:Bool = dict["defaultMethod"] as? Bool
            {
                if check == true
                {
                    cell.imgView.image = UIImage(named: "greentickSuccess")!
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var dictSel = arr_CardList[indexPath.row]
        if let check:Bool = dictSel["defaultMethod"] as? Bool
        {
            if check == true
            {
                // means we do not need to uncheck the already true value
                return
            }
            
            if let cardId:String = dictSel["id"] as? String
            {
                self.selectedCardIDforDefaultCard = cardId
                
                self.perform(#selector(self.callServerToSetDefaultCard), with: nil, afterDelay: 0.2)
            }
        }
    }
    
    // set view for footer
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerView:Cell_AddNewCard = tblView.dequeueReusableCell(withIdentifier: "Cell_AddNewCard") as! Cell_AddNewCard
        footerView.selectionStyle = .none
        footerView.btn_AddNewCard.addTarget(self, action: #selector(self.btnPay_Clicked(btn:)), for: .touchUpInside)
        return footerView
    }
    
    // set height for footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if UIDevice.current.model == "iPad"
        {
            return 40
        }
        return 60
    }
    
    @objc func btnPay_Clicked(btn:UIButton)
    {
        self.perform(#selector(self.callServerToMakePayment), with: nil, afterDelay: 0.2)
    }
    
    @objc func callServerToMakePayment()
    {
        self.showSpinnerWith(title: "Cargando...")
                
        let urlStr = serviceName.PayByConekta.rawValue
        let param:[String:Any] = ["inPersonCourseId":self.CourseID, "numberOfPeople":self.numberofPersons, "people":self.arrPersons]
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
                            // its a success
                            if let dictRes:[String:Any] = json["response"] as? [String:Any]
                            {
                                DispatchQueue.main.async {
                                    // take to Result Conekta Screen
                                    let conResVC:ConektaResultStatusVC = AppStoryboards.InPerson.instance.instantiateViewController(identifier: "ConektaResultStatusVC_ID") as! ConektaResultStatusVC

                                    conResVC.strPrice = self.strPrice
                                    conResVC.strCourse = self.strCourse
                                    if let checkSt:Bool = dictRes["status"] as? Bool
                                    {
                                        conResVC.paymentStatus = checkSt
                                    }
                                    
                                    conResVC.strPricePerPerson = self.strPricePerPerson
                                    conResVC.numberofPersons = self.numberofPersons
                                    conResVC.ref_ConektaPayDetailVC = self
                                    
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

                                conResVC.strPrice = self.strPrice
                                conResVC.strCourse = self.strCourse
                                conResVC.paymentStatus = false
                                conResVC.strPricePerPerson = self.strPricePerPerson
                                conResVC.numberofPersons = self.numberofPersons
                                conResVC.ref_ConektaPayDetailVC = self
                                self.navigationController?.pushViewController(conResVC, animated: true)
                            }
                        }
                    }
            
        }
    }
    
    @objc func callServerToSetDefaultCard()
    {
        self.showSpinnerWith(title: "Cargando...")
        let urlStr = serviceName.MakeCardDefault.rawValue
        let param:[String:Any] = ["paymentToken":self.selectedCardIDforDefaultCard]
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
                        let sel:Selector = #selector(self.refreshList)
                        DispatchQueue.main.async {
                            self.showAlertWithTitle(title: "Zertu", message: msg, okButton: "Ok", cancelButton: "", okSelectorName: sel)
                            return
                        }
                    }
                }
            }
        }
    }
    
    @objc func refreshList()
    {
        callServerToGetLinkedCards()
    }
}
