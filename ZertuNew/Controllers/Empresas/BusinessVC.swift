//
//  BusinessVC.swift
//  Zertu
//
//  Created by Shalini Sharma on 7/11/19.
//  Copyright © 2019 Abhishek Bhardwaj. All rights reserved.
//

import UIKit
import SDWebImage

class BusinessVC: UIViewController {

    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    let arrRows:[String] = ["Header", "pdf1", "pdf2", "tf1", "tf2", "tf3", "tf4", "btnSubmit", "carousel"]
    let arrImages:[String] = ["https://zertu.mx/img/empresas/empre-01.jpg", "https://zertu.mx/img/empresas/empre-02.jpg", "https://zertu.mx/img/empresas/empre-03.png", "https://zertu.mx/img/empresas/empre-04.jpg", "https://zertu.mx/img/empresas/empre-05.jpg", "https://zertu.mx/img/empresas/empre-06.jpg", "https://zertu.mx/img/empresas/empre-07.jpg", "https://zertu.mx/img/empresas/empre-08.jpg"]
    
    var carouselRef:iCarousel!
    var strTF1 = ""
    var strTF2 = ""
    var strTF3 = ""
    var strTF4 = ""
    var timer:Timer!
    var itemCount:Int = 1
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblView.dataSource = self
        self.tblView.delegate = self
        setUpTopBar()
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
        else
        {
            // UNKNOWN CASE - Like iPhone 11 or XR
            c_TopBar_Ht.constant = 90
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.title = "EMPRESAS"
        
        strTF1 = ""
        strTF2 = ""
        strTF3 = ""
        strTF4 = ""
        
        tblView.reloadData()
        
        self.timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(self.autoScroll), userInfo: nil, repeats: true)
    }
    
    deinit {
        if timer != nil
        {
            timer.invalidate()
            timer = nil
        }
    }
    
    @objc func autoScroll()
    {
      if carouselRef != nil
      {
       if arrImages.count == itemCount
        {
            carouselRef.scrollToItem(at: 0, animated: true)
            itemCount = 1
        }
        else
        {
            itemCount = itemCount + 1
            carouselRef.scroll(byNumberOfItems: 1, duration: 1.0)
        }
        }
    }
    
    @IBAction func btnBackClick(btn:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
}

extension BusinessVC
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

extension BusinessVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrRows.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let str:String = arrRows[indexPath.row]

        switch str
        {
        case "Header":
            return 120
        case "tf1":
            return 85
        case "tf2":
            return 85
        case "tf3":
            return 85
        case "tf4":
            return 85
        case "btnSubmit":
            return 60
        case "pdf1":
            return 60
        case "pdf2":
            return 60
        case "carousel":
            return 200
        default:
            break
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let str:String = arrRows[indexPath.row]

        switch str
        {
        case "Header":
            let cell:CellBusiness_Header = tblView.dequeueReusableCell(withIdentifier: "CellBusiness_Header", for: indexPath) as! CellBusiness_Header
            cell.selectionStyle = .none
            
            return cell
        case "tf1":
            let cell:CellBusiness_TF = tblView.dequeueReusableCell(withIdentifier: "CellBusiness_TF", for: indexPath) as! CellBusiness_TF
            cell.selectionStyle = .none
            
            cell.tf.tag = 101
            cell.tf.delegate = self
            
            cell.lbl.text = "Nombre completo"
            cell.tf.text = strTF1
            cell.tf.placeholder = "Entrar Nombre completo"
            
            cell.tf.layer.cornerRadius = 6.0
            cell.tf.layer.borderColor = UIColor.gray.cgColor
            cell.tf.layer.borderWidth = 1.0
            cell.tf.layer.masksToBounds = true
            
            cell.tf.keyboardType = .default
            
            cell.tf.inputAccessoryView = nil
            
            cell.inCellAddLeftPaddingTo(TextField: cell.tf)
            
            return cell
        case "tf2":
            let cell:CellBusiness_TF = tblView.dequeueReusableCell(withIdentifier: "CellBusiness_TF", for: indexPath) as! CellBusiness_TF
            cell.selectionStyle = .none
            
            cell.tf.tag = 102
            cell.tf.delegate = self
            
            cell.lbl.text = "Empresa"
            cell.tf.text = strTF2
            cell.tf.placeholder = "Entrar Empresa"
            
            cell.tf.layer.cornerRadius = 6.0
            cell.tf.layer.borderColor = UIColor.gray.cgColor
            cell.tf.layer.borderWidth = 1.0
            cell.tf.layer.masksToBounds = true
            cell.tf.keyboardType = .default
            cell.tf.inputAccessoryView = nil
            cell.inCellAddLeftPaddingTo(TextField: cell.tf)
            return cell
        case "tf3":
            let cell:CellBusiness_TF = tblView.dequeueReusableCell(withIdentifier: "CellBusiness_TF", for: indexPath) as! CellBusiness_TF
            cell.selectionStyle = .none
            
            cell.tf.tag = 103
            cell.tf.delegate = self
            
            cell.lbl.text = "Teléfono"
            cell.tf.text = strTF3
            cell.tf.placeholder = "Entrar Teléfono"
            
            cell.tf.layer.cornerRadius = 6.0
            cell.tf.layer.borderColor = UIColor.gray.cgColor
            cell.tf.layer.borderWidth = 1.0
            cell.tf.layer.masksToBounds = true
            cell.tf.keyboardType = .phonePad
            
            // ToolBar
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
            toolBar.tintColor = UIColor.darkGray
            toolBar.sizeToFit()
            
            // Adding Button ToolBar
            let doneButton = UIBarButtonItem(title: "Hecho", style: .plain, target: self, action: #selector(self.doneClick))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolBar.setItems([spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            cell.tf.inputAccessoryView = toolBar
            
            cell.inCellAddLeftPaddingTo(TextField: cell.tf)
            return cell
        case "tf4":
            let cell:CellBusiness_TF = tblView.dequeueReusableCell(withIdentifier: "CellBusiness_TF", for: indexPath) as! CellBusiness_TF
            cell.selectionStyle = .none
            cell.tf.tag = 104
            cell.tf.delegate = self
            
            cell.tf.font = UIFont(name: "STHeitiTC-Light", size: 18)
            
            cell.lbl.text = "Correo electrónico"
            cell.tf.text = strTF4
            cell.tf.placeholder = "Entrar Correo electrónico"
            
            cell.tf.layer.cornerRadius = 6.0
            cell.tf.layer.borderWidth = 1.0
            cell.tf.layer.borderColor = UIColor.gray.cgColor
            cell.tf.layer.masksToBounds = true
            cell.tf.keyboardType = .emailAddress
            cell.tf.inputAccessoryView = nil
            
            cell.inCellAddLeftPaddingTo(TextField: cell.tf)
            return cell
        case "btnSubmit":
            let cell:CellBusiness_Btn = tblView.dequeueReusableCell(withIdentifier: "CellBusiness_Btn", for: indexPath) as! CellBusiness_Btn
            cell.selectionStyle = .none
            
            cell.btn.setTitle("ENVIAR", for: .normal)
            
            cell.btn.layer.cornerRadius = 6.0
            cell.btn.layer.masksToBounds = true
            
            cell.btn.addTarget(self, action: #selector(self.btnSubmit), for: .touchUpInside)
            
            cell.btn.setImage(nil, for: .normal)
            
            return cell
        case "pdf1":
            let cell:CellBusiness_Btn = tblView.dequeueReusableCell(withIdentifier: "CellBusiness_Btn", for: indexPath) as! CellBusiness_Btn
            cell.selectionStyle = .none
            cell.btn.setTitle("NESS EMPRESAS", for: .normal)

            cell.btn.layer.cornerRadius = 6.0
            cell.btn.layer.masksToBounds = true
            cell.btn.setImage(UIImage(named: "pdf"), for: .normal)
            cell.btn.imageEdgeInsets = UIEdgeInsets(top: 0, left:-20, bottom: 0, right: 0)

            cell.btn.addTarget(self, action: #selector(self.btnPdf1), for: .touchUpInside)
            return cell
        case "pdf2":
            let cell:CellBusiness_Btn = tblView.dequeueReusableCell(withIdentifier: "CellBusiness_Btn", for: indexPath) as! CellBusiness_Btn
            cell.selectionStyle = .none
            cell.btn.setTitle("NESS ALTA EMPRESAS", for: .normal)

            cell.btn.layer.cornerRadius = 6.0
            cell.btn.layer.masksToBounds = true
            cell.btn.setImage(UIImage(named: "pdf"), for: .normal)
            cell.btn.addTarget(self, action: #selector(self.btnPdf2), for: .touchUpInside)
            cell.btn.imageEdgeInsets = UIEdgeInsets(top: 0, left:-20, bottom: 0, right: 0)
            return cell
        case "carousel":
            let cell:CellBusiness_Carousel = tblView.dequeueReusableCell(withIdentifier: "CellBusiness_Carousel", for: indexPath) as! CellBusiness_Carousel
            cell.selectionStyle = .none
            
            cell.carousel.type = .linear
            cell.carousel.backgroundColor = UIColor.white
            cell.carousel.delegate = self
            cell.carousel.dataSource = self
            
            self.carouselRef = cell.carousel

            return cell
        default:
            break
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func btnSubmit()
    {
        if validateTF() == true
        {
            // Call Api
            self.callSubmitApi()
        }
    }
    
    @objc func btnPdf1()
    {
        if let url = URL(string: "https://zertu.mx/pdf/NESS_EMPRESAS_FINAL.pdf") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
    
    @objc func btnPdf2()
    {
        if let url = URL(string: "https://zertu.mx/pdf/NESS_ALTA_DIRECCI%C3%93N.pdf") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
    
    @objc func doneClick() {
        self.view.endEditing(true)
    }
}

extension BusinessVC: UITextFieldDelegate
{
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.tag == 101
        {
            strTF1 = textField.text!
        }
        if textField.tag == 102
        {
            strTF2 = textField.text!
        }
        if textField.tag == 103
        {
            strTF3 = textField.text!
        }
        if textField.tag == 104
        {
            strTF4 = textField.text!
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
    
    func validateTF() -> Bool
    {
        if strTF1.isEmpty == true || strTF2.isEmpty == true || strTF3.isEmpty == true || strTF4.isEmpty == true
        {
            self.showAlertWithTitle(title: "Validación", message: "Uno de sus campos de entrada está vacío. Por favor ingrese todos los campos", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return false
        }
        else
        {
            return true
        }
    }

}

extension BusinessVC
{
    func callSubmitApi()
    {
        self.showSpinnerWith(title: "Cargando...")
        

                let urlStr = serviceName.postBusiness.rawValue
                let param:[String:Any] = ["nombre":self.strTF1, "empresa":self.strTF2, "telefono":self.strTF3, "correo":self.strTF4]
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
                                    self.showAlertWithTitle(title: "Zertu", message: msg, okButton: "Ok", cancelButton: "", okSelectorName: #selector(self.refresh))
                                    return
                                }
                            }
                        }
                    }
                }
    }
    
    @objc func refresh()
    {
        strTF1 = ""
        strTF2 = ""
        strTF3 = ""
        strTF4 = ""

        tblView.reloadData()
    }
}

extension BusinessVC : iCarouselDataSource, iCarouselDelegate
{
    func numberOfItems(in carousel: iCarousel) -> Int {
        
        return arrImages.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {

        let coverImageUrl = arrImages[index]
        
        var itemView: UIImageView
        
        itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 190))
        
        itemView.layer.cornerRadius = 10.0
        itemView.layer.masksToBounds = true
        
        itemView.contentMode = .scaleAspectFill
        itemView.clipsToBounds = true
                
        itemView.sd_setImage(with: URL(string: coverImageUrl), placeholderImage: UIImage(named: "ph.png"))

        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        switch (option)
        {
        case .wrap:
            return 1
            
        default:
            return value * 1.1
        }
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int)
    {
        print("tapped Index from Carousel \(index)")
    }
    
}
