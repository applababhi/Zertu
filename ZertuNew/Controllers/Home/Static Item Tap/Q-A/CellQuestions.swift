//
//  CellQuestions.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 8/2/21.
//  Copyright © 2021 Shalini Sharma. All rights reserved.
//

import UIKit

class CellQuestions: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tblView:UITableView!
    
    var indexOfRow:Int!
    
    var closure: (Int, [[String:Any]]) -> () = {(index:Int, arr:[[String:Any]]) in }
    
    var arr_QA:[[String:Any]] = []{
        didSet{
            if tblView.delegate == nil
            {
                tblView.delegate = self
                tblView.dataSource = self
                tblView.remembersLastFocusedIndexPath = true
            }
            else {
                DispatchQueue.main.async {
                    self.tblView.reloadData()
                }
            }
         //   self.tblView.estimatedRowHeight = 90
         //   self.tblView.rowHeight = UITableView.automaticDimension
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension CellQuestions: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arr_QA.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        /*
        let diner:[String:Any] = arr_QA[indexPath.row]
        
        if let strInner:String = diner["respuesta"] as? String
        {
           // let attributes = [NSAttributedString.Key.font: UIFont(name: CustomFont.GSLRegular, size: 19)!, NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            
            let height_Answer = strInner.heightWithConstrainedWidth(UIScreen.main.bounds.width - 15, font: UIFont.boldSystemFont(ofSize: 30.0))
            return height_Answer!
        }
        */
        
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CellEachAnswer = self.tblView.dequeueReusableCell(withIdentifier: "CellEachAnswer") as! CellEachAnswer
        cell.selectionStyle = .none
        cell.lblTitle.text = ""
        cell.lblTitle.textColor = .darkGray
        
        cell.vSelection.backgroundColor = .clear
        cell.vSelection.layer.cornerRadius = 8.0
        cell.vSelection.layer.borderColor = UIColor.gray.cgColor
        cell.vSelection.layer.borderWidth = 1.0
        cell.vSelection.layer.masksToBounds = true
        
        let d:[String:Any] = arr_QA[indexPath.row]
        
        if let str:String = d["respuesta"] as? String
        {
            let attributes = [NSAttributedString.Key.font: UIFont(name: CustomFont.GSLRegular, size: 18)!,
                              NSAttributedString.Key.foregroundColor: UIColor.black]

            cell.lblTitle.attributedText = NSAttributedString(string: str.htmlToString, attributes: attributes)
        }
        
        if let check:Bool = d["selected"] as? Bool
        {
            if check == true{
                cell.vSelection.backgroundColor = k_baseColor
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        for index in 0..<arr_QA.count
        {
            var d:[String:Any] = arr_QA[index]
            
            if index == indexPath.row
            {
                if let check:Bool = d["selected"] as? Bool
                {
                    d["selected"] = !check
                }
            }
            else
            {
                d["selected"] = false
            }
            
            arr_QA[index] = d
        }
        
        closure(indexOfRow, arr_QA)
        
        UIView.performWithoutAnimation {
            self.tblView.reloadData()
        }
    }
}
