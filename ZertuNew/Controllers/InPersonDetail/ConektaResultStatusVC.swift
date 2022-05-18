//
//  ConektaResultStatusVC.swift
//  Zertu
//
//  Created by Abhishek Bhardwaj on 14/6/18.
//  Copyright © 2018 Abhishek Bhardwaj. All rights reserved.
//

import UIKit

class ConektaResultStatusVC: UIViewController {
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!

    @IBOutlet weak var lbl_Courses:UILabel!
    @IBOutlet weak var lbl_PricePerPerson:UILabel!
    @IBOutlet weak var lbl_NumOfPerson:UILabel!
    @IBOutlet weak var lbl_Total:UILabel!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var lbl_Message:UILabel!
    
    var strPrice = ""
    var strCourse = ""
    var paymentStatus = false
    var strPricePerPerson = ""
    var numberofPersons = 0
    
    var ref_ConektaPayDetailVC:ConektaPayDetailVC!
    var ref_InPersonDetailVC:InPersonDetailVC!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTopBar()
        lblTitle.text = "Confirmar pago"
        
        let course:String = "Curso: \(strCourse)"
        lbl_Courses.attributedText = self.setAttributedString(str: course)
        
        let perPerson:String = "Precio por boleto: $\(strPricePerPerson)"
        lbl_PricePerPerson.attributedText = self.setAttributedString(str: perPerson)
        
        let numPerson:String = "Número de boletos: \(numberofPersons)"
        lbl_NumOfPerson.attributedText = self.setAttributedString(str: numPerson)
        
        let total:String = "Total: $\(strPrice)"
        lbl_Total.attributedText = self.setAttributedString(str: total)
        
        if paymentStatus == true
        {
            // its success
            let strMsg:String = """
        iGracia por inscribirte!
        Te llegará un correo electrónico
        con tu confirmación e instrucciones
    """
            lbl_Message.text = strMsg
            imgView.image = UIImage(named: "greentickSuccess")!
        }
        else
        {
            // its failure
            
            imgView.image = UIImage(named: "redCrossStatus")!
            let strMsg:String = """
        No pudimos procesar tu pago.
        Por favor intenta con otro método
    """
            lbl_Message.text = strMsg
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if paymentStatus == true
        {
            // take to root view controller
            self.navigationController?.popToRootViewController(animated: true)
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
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
        let attrs2 = [NSAttributedString.Key.font :  UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.black]
        
        let attributedString1 = NSMutableAttributedString(string:str1, attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:" \(str2)", attributes:attrs2)
        
        attributedString1.append(attributedString2)
        
        return attributedString1
    }
}
