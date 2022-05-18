//
//  ShowAnswersVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 25/3/21.
//  Copyright © 2021 Shalini Sharma. All rights reserved.
//

import UIKit

class ShowAnswersVC: UIViewController {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnBack:UIImageView!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    var strTitle = ""
    
    var arr_Answers:[[String:Any]] = []

    var strDescription:NSAttributedString!
    var RowHeightDescription:CGFloat = 0
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        setUpTopBar()
        
        lblTitle.text = ""
        btnBack.setImageColor(color: UIColor.black)
                
        self.tblView.estimatedRowHeight = 90
        self.tblView.rowHeight = UITableView.automaticDimension
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.reloadData()
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

extension ShowAnswersVC
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

extension ShowAnswersVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arr_Answers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CellAnswerss = self.tblView.dequeueReusableCell(withIdentifier: "CellAnswerss") as! CellAnswerss
        cell.selectionStyle = .none
        let d:[String:Any] = arr_Answers[indexPath.row]
        
        cell.lblQuestion.text = ""
        cell.lblAnswer.text = ""
        cell.lblAnswer.textColor = .black
        
        if let dP:[String:Any] = d["pregunta"] as? [String:Any]
        {
            if let str:String = dP["pregunta"] as? String
            {
                let strPass = "\(indexPath.row + 1). " + str
                
                let attributes = [NSAttributedString.Key.font: UIFont(name: CustomFont.GSLRegular, size: 20)!,
                                  NSAttributedString.Key.foregroundColor: UIColor.black]

                cell.lblQuestion.attributedText = NSAttributedString(string: strPass.htmlToString, attributes: attributes)
            }
            
            if let str:String = d["respuesta"] as? String
            {
                // Answer
                cell.lblAnswer.text = str
            }
            
            if let check:Bool = d["correcta"] as? Bool
            {
                if check == true
                {
                    // green
                    cell.lblAnswer.textColor = .systemGreen
                }
                else
                {
                    // red
                    cell.lblAnswer.textColor = .systemRed
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

