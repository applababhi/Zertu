//
//  MyShoppingsVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 22/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit
import Floaty

class MyShoppingsVC: UIViewController {

    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var lblNoRecords:UILabel!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    var arrTickets:[[String:Any]] = []
    
    var floaty = Floaty()
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTopBar()
        setupFloatingButton()
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
   
}

extension MyShoppingsVC
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

extension MyShoppingsVC
{
    override func viewWillAppear(_ animated: Bool) {
        lblNoRecords.isHidden = true
        callGetTickets()
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
        self.view.addSubview(floaty)
    }
}

extension MyShoppingsVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrTickets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict:[String:Any] = arrTickets[indexPath.row]
        let cell:CellTicket = tblView.dequeueReusableCell(withIdentifier: "CellTicket", for: indexPath) as! CellTicket
        cell.selectionStyle = .none
        cell.lblName.text = ""
        cell.lblReceipt.text = ""
        cell.lblAmount.text = ""
        cell.imgV.setImageColor(color: .black)
        
        cell.vBk.layer.cornerRadius = 5.0
        cell.vBk.layer.borderWidth = 0.3
        cell.vBk.layer.borderColor = UIColor.lightGray.cgColor
        cell.vBk.layer.masksToBounds = true
        
        if let str:String = dict["name"] as? String
        {
            cell.lblName.text = "Nombre: " + str
        }
        if let str:String = dict["receipt"] as? String
        {
            cell.lblReceipt.text = "Recibo: " + str
        }
        if let str:String = dict["amountPaid"] as? String
        {
            cell.lblAmount.text = "Cantidad pagada: $" + str
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dict:[String:Any] = arrTickets[indexPath.row]
        let vc:ShoppingDetailVC = AppStoryboards.Shopping.instance.instantiateViewController(identifier: "ShoppingDetailVC_ID") as! ShoppingDetailVC
        
        if let d:[String:Any] = dict["inPersonCourse"] as? [String:Any]
        {
            vc.dictMain = d
        }        
        if let str:String = dict["receipt"] as? String
        {
            vc.strTitle = str
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MyShoppingsVC
{
    func callGetTickets()
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.GetMyTickets.rawValue
        let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        
        WebService.callApiWith(url: urlStr, method: .get, parameter: nil, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
        //    print(jsonStr)
            self.hideSpinner()
            
            if error != nil
            {
                self.showAlertWithTitle(title: "Alerta", message: "\(error!.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }

            self.arrTickets.removeAll()
            if let code:Int = json["code"] as? Int
            {
                if code >= 200 && code < 300
                {
                    if let arrItems:[[String:Any]] = json["response"] as? [[String:Any]]
                    {
                        self.arrTickets = arrItems
                        
                        DispatchQueue.main.async {
                            if self.tblView.delegate == nil
                            {
                                self.tblView.delegate = self
                                self.tblView.dataSource = self
                            }
                            self.tblView.reloadData()
                            
                            if arrItems.count == 0
                            {
                                self.lblNoRecords.isHidden = false
                            }
                        }
                    }
                }
            }
        }
    }
}

extension MyShoppingsVC
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
