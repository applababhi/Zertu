//
//  ShowQuestionVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 8/2/21.
//  Copyright © 2021 Shalini Sharma. All rights reserved.
//

import UIKit

class ShowQuestionVC: UIViewController {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnBack:UIImageView!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    var strTitle = ""
    
    var arr_Questions:[[String:Any]] = []

    var strDescription:NSAttributedString!
    var RowHeightDescription:CGFloat = 0
    
    var arr_Heights:[CGFloat] = []
    var reffStaticVC:StaticItemTapDetailVC!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        setUpTopBar()
        
        lblTitle.text = ""
        btnBack.setImageColor(color: UIColor.black)
                
        setupData()
    }
    
    func setupData()
    {
        for index in 0..<arr_Questions.count
        {
            let d:[String:Any] = arr_Questions[index]
            
            if let strDes:String = d["pregunta"] as? String
            {
                let height_Question = strDes.heightWithConstrainedWidth(UIScreen.main.bounds.width - 15, font: UIFont.boldSystemFont(ofSize: 19.0))
                
               // var height_Answer_Total:CGFloat = 0
                
                if let arr:[[String:Any]] = d["respuestas"] as? [[String:Any]]
                {
                    /*
                    for ind in 0..<arr.count
                    {
                        let diner:[String:Any] = arr[ind]
                        
                        if let strInner:String = diner["respuesta"] as? String
                        {
                            let height_Answer = strInner.heightWithConstrainedWidth(UIScreen.main.bounds.width - 15, font: UIFont.boldSystemFont(ofSize: 30.0))
                            height_Answer_Total = height_Answer_Total + height_Answer!
                        }
                    }
                    
                    */
                    
                    print(" Answer ArrCount - - - - - - - >  ", arr.count)
                    
                    arr_Heights.append(height_Question! + CGFloat((arr.count) * 60))
                }
            }
        }
        
        self.tblView.delegate = self
        self.tblView.dataSource = self
     //   self.tblView.estimatedRowHeight = 90
     //   self.tblView.rowHeight = UITableView.automaticDimension
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
    
    @objc func btnSubmitClick(btn:UIButton)
    {
        var numberOfSelectedTrue = 0
        
        var arrToPass:[[String:Any]] = []
        var moduloId:Int = 0
        
        for d in arr_Questions
        {
            if let mId:Int = d["moduloId"] as? Int
            {
                moduloId = mId
            }
            
            if let arrInner:[[String:Any]] = d["respuestas"] as? [[String:Any]]
            {
                for dInner in arrInner
                {
                    if let check:Bool = dInner["selected"] as? Bool
                    {
                        if check == true
                        {
                            numberOfSelectedTrue += 1
                            
                            if let preguntaId:Int = dInner["preguntaId"] as? Int
                            {
                                if let respuestaId:Int = dInner["id"] as? Int
                                {
                                    arrToPass.append(["respuestaId":respuestaId, "preguntaId":preguntaId])
                                }
                            }
                            
                            break
                        }
                    }
                }
            }
        }
        
        print("> > > > > > > > > > >")
        print(arr_Questions.count)
        print(numberOfSelectedTrue)
        
        if arr_Questions.count == numberOfSelectedTrue
        {
            // All questions now answered, procedd to submit
            print("CaLL API, ", moduloId)
            print(arrToPass)
            
            callSubmitModule(id:"\(moduloId)", paramArray:arrToPass)
        }
        else
        {
            // somme questions answers are missing
            print("No No No")
            self.showAlertWithTitle(title: "Alerta", message: "Responda todas las preguntas de la lista para enviar", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
    }
}

extension ShowQuestionVC
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

extension ShowQuestionVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arr_Questions.count + 1 // +1 for Footer Submit Button
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == arr_Questions.count
        {
            // Last Submit cell
            return 55
        }
        
        return arr_Heights[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == arr_Questions.count
        {
            // Last Submit cell
            let cell:CellPaidDetail_PriceBuy = self.tblView.dequeueReusableCell(withIdentifier: "CellPaidDetail_PriceBuy") as! CellPaidDetail_PriceBuy
            cell.selectionStyle = .none

            cell.btnBuy_1.layer.cornerRadius = 5.0
            cell.btnBuy_1.layer.masksToBounds = true
                                                          
            cell.btnBuy_1.addTarget(self, action: #selector(self.btnSubmitClick(btn:)), for: .touchUpInside)
            return cell
        }
        
        let cell:CellQuestions = self.tblView.dequeueReusableCell(withIdentifier: "CellQuestions") as! CellQuestions
        cell.selectionStyle = .none
        var d:[String:Any] = arr_Questions[indexPath.row]
        
        cell.lblTitle.text = ""
        cell.indexOfRow = indexPath.row
        
        if let str:String = d["pregunta"] as? String
        {
            let strPass = "\(indexPath.row + 1). " + str
            
            let attributes = [NSAttributedString.Key.font: UIFont(name: CustomFont.GSLRegular, size: 20)!,
                              NSAttributedString.Key.foregroundColor: UIColor.black]

            cell.lblTitle.attributedText = NSAttributedString(string: strPass.htmlToString, attributes: attributes)
        }
        
        if let arr:[[String:Any]] = d["respuestas"] as? [[String:Any]]
        {
            cell.arr_QA = arr
        }
        
        cell.closure = {(index:Int, arr:[[String:Any]]) in
            d["respuestas"] = arr
            self.arr_Questions[index] = d
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ShowQuestionVC
{
    /*
    func callSubmitModule(id:String, paramArray:[[String:Any]])
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.POSTModuleSubmit.rawValue + id
        var headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
      
        let param:[[String:Any]] = paramArray
        
        if isUserTappedSkipButton == true{
            headers = ["Content-Type":"application/json"]
        }
        
        WebService.callApiWith(url: urlStr, method: .post, parameter: ["arrayAsParam":paramArray], header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
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
                    if let arr:[[String:Any]] = json["response"] as? [[String:Any]]
                    {
                        DispatchQueue.main.async {
                    
                        }
                    }
                }
            }
        }
    }
    */
    
    func callSubmitModule(id:String, paramArray:[[String:Any]])
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = baseUrl + serviceName.POSTModuleSubmit.rawValue + id
        
        guard let serviceUrl = URL(string: urlStr) else { return }
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: paramArray, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                self.hideSpinner()
            }
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                 //   print(json)
                    
                    guard let jsonD:[String:Any] = json as? [String : Any] else {return}
                    
                    if let code:Int =  jsonD["code"] as? Int
                    {
                        if code >= 200 && code < 300
                        {
                            // success
                            DispatchQueue.main.async {
                                self.showAlertWithTitle(title: "Éxito", message: "Respuestas enviadas con éxito", okButton: "Ok", cancelButton: "", okSelectorName: #selector(self.goBack))
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                self.showAlertWithTitle(title: "Alerta", message: "Se produjo un error, intente después de algún tiempo", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                                return
                            }
                        }
                    }
                    
                } catch {
                    print(error)
                    DispatchQueue.main.async {
                        self.showAlertWithTitle(title: "Alerta", message: "\(error.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                        return
                    }
                }
            }
        }.resume()
    }
    
    @objc func goBack()
    {
        DispatchQueue.main.async {
            self.navigationController?.popToViewController(self.reffStaticVC, animated: true)
        }
    }
}
