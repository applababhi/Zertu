//
//  ShoppingDetailVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 23/4/20.
//  Copyright © 2020 Shalini Sharma. All rights reserved.
//

import UIKit
import EventKit

class ShoppingDetailVC: UIViewController {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    var arrTable:[String] = []   // ["ImageHeader", "Description", "Label", "LinkToPDF", "Calendar"]
    var dictMain:[String:Any] = [:]
    var strImgUrl = ""
    var strLinkPdf = ""
    var strTitle = ""
    var strStartDate = ""
    var strEndDate = ""
    var strDescription:NSAttributedString!
    var RowHeightDescription:CGFloat = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTopBar()
        
        lblTitle.text = strTitle
        setupData()
    }
    
    func setUpTopBar()
    {
       // lblTitle.font = UIFont.systemFont(ofSize: 19)
        
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
           // lblTitle.font = UIFont.systemFont(ofSize: 17)
        }
        else if strModel == "iPhone 6"
        {
           // lblTitle.font = UIFont.systemFont(ofSize: 18)
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
    
    func setupData()
    {
        if let strUrl:String = dictMain["coverImageUrl"] as? String
        {
            strImgUrl = strUrl
            arrTable.append("ImageHeader")
        }
        if let strDesc:String = dictMain["description"] as? String
        {
            arrTable.append("Description")
            
            let attributes = [NSAttributedString.Key.font: UIFont(name: CustomFont.GSLRegular, size: 20)!,
                              NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            
            let strUpdate:String = strDesc
            
            self.strDescription = NSAttributedString(string: strUpdate.htmlToString, attributes: attributes)
            
            let height = strUpdate.heightWithConstrainedWidth(UIScreen.main.bounds.width - 15, font: UIFont.boldSystemFont(ofSize: 15.0))
            RowHeightDescription = height! 
        }
        if let str:String = dictMain["title"] as? String
        {
            arrTable.append("Label+" + "Curso: " + str)
        }
        if let str:Int = dictMain["maxCapacity"] as? Int
        {
            arrTable.append("Label+" + "Capacidad: " + "\(str)")
        }
        if let str:Int = dictMain["price"] as? Int
        {
          //  arrTable.append("Label+" + "Cantidad pagada: $" + "\(str)")
        }
        if let str:Double = dictMain["price"] as? Double
        {
            arrTable.append("Label+" + "Cantidad pagada: $" + "\(str)")
        }
        if let str:String = dictMain["startDate"] as? String
        {
            strStartDate = str
            arrTable.append("Label+" + "Fecha Inicio: " + str)
        }
        if let str:String = dictMain["endDate"] as? String
        {
            strEndDate = str
            arrTable.append("Label+" + "Fecha Fin: " + str)
        }
        
        if let str:String = dictMain["instructionsFileUrl"] as? String
        {
            strLinkPdf = str
            arrTable.append("LinkToPDF")
        }

        arrTable.append("Calendar")

        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
    }
}

extension ShoppingDetailVC
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

extension ShoppingDetailVC: UITableViewDelegate, UITableViewDataSource
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
            if strImgUrl == ""
            {
                return 0
            }
            return 250
        }
        else if strType.localizedStandardContains("Description")
        {
            return RowHeightDescription
        }
            else if strType.localizedStandardContains("Label")
            {
                return 40
            }
            else if strType.localizedStandardContains("LinkToPDF")
            {
                if strLinkPdf == ""
                {
                    return 0
                }
                return 50
            }
        else
        {
            // Add calendar button
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let strType:String = arrTable[indexPath.row]
        if strType.localizedStandardContains("ImageHeader")
        {
            let cell:CellPaidDetail_Header = self.tblView.dequeueReusableCell(withIdentifier: "CellPaidDetail_Header") as! CellPaidDetail_Header
            cell.selectionStyle = .none
            
            cell.vBk.backgroundColor = .clear
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
            else if strType.localizedStandardContains("Label")
            {
                let cell:CellShoppingDetail_Label = self.tblView.dequeueReusableCell(withIdentifier: "CellShoppingDetail_Label") as! CellShoppingDetail_Label
                cell.selectionStyle = .none
                cell.lblTitle.text = ""
                cell.lblTitle.textColor = .darkGray
                
                let strValue:String = strType.components(separatedBy: "+").last!
                cell.lblTitle.text = strValue
                return cell
            }
            else if strType.localizedStandardContains("LinkToPDF")
            {
                let cell:CellShoppingDetail_Label = self.tblView.dequeueReusableCell(withIdentifier: "CellShoppingDetail_Label") as! CellShoppingDetail_Label
                cell.selectionStyle = .none
                cell.lblTitle.text = ""
                cell.lblTitle.textColor = .blue
                
                cell.lblTitle.text = strLinkPdf
                return cell
            }
        else
        {
            // Last Add Calendar Button
            let cell:Cell_AddNewCard = self.tblView.dequeueReusableCell(withIdentifier: "Cell_AddNewCard") as! Cell_AddNewCard
            cell.selectionStyle = .none
            cell.btn_AddNewCard.addTarget(self, action: #selector(self.addToCalendar(btn:)), for: .touchUpInside)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let strType:String = arrTable[indexPath.row]
        if strType.localizedStandardContains("LinkToPDF")
        {
            print("OPEN URL - - - ", strLinkPdf)
            if let url = URL(string: strLinkPdf) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
        }
    }
    
    @objc func addToCalendar(btn:UIButton)
    {
        if strStartDate != ""
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            let startDate: Date? = formatter.date(from: strStartDate)
            let endDate: Date? = formatter.date(from: strEndDate)
            print(startDate!)
            
            if let title:String = dictMain["title"] as? String
            {
                addEventToCalendar(title: title, description: "", startDate: startDate ?? Date(), endDate: endDate ?? Date(), location: ""){ (success:Bool, error:Error?) in
                    if success == true
                    {
                        DispatchQueue.main.async {
                            self.showAlertWithTitle(title: "Éxito", message: "Evento guardado con éxito en su teléfono", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                        }
                    }
                }
                
            }
            
        }
        
        print("- - - Add To Calendar -")
    }
    
    func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, location: String?, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async { () -> Void in
            let eventStore = EKEventStore()

            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if (granted) && (error == nil) {
                    let alarm = EKAlarm(relativeOffset: -3600.0)
                    let event = EKEvent(eventStore: eventStore)
                    event.title = title
                    event.startDate = startDate
                    event.endDate = endDate
                    event.notes = description
                    event.alarms = [alarm]
                    event.location = location
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    do {
                        try eventStore.save(event, span: .thisEvent)
                    } catch let e as NSError {
                        completion?(false, e)
                        print ("\(#file) - \(#function) error: \(e.localizedDescription)")
                        return
                    }
                    completion?(true, nil)
                } else {
                    completion?(false, error as NSError?)
                    print ("\(#file) - \(#function) error: \(error)")
                }
            })
        }
    }
}
