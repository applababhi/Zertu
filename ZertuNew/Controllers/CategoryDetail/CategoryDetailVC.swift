//
//  CategoryDetailVC.swift
//  home
//
//  Created by Abhishek Visa on 2/12/19.
//  Copyright © 2019 Shalini. All rights reserved.
//

import UIKit

class CategoryDetailVC: UIViewController {
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    var d_Category:[String:Any] = [:]
    var arrRows_CollV:[[[String:Any]]] = []  // Array of array of Dict
    var topHeaderHeight:CGFloat = 226.0
    var countForNumberOfCollVRows = 0
    var isArrayForOddRecords = false
        
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = ""
        if let str:String = d_Category["name"] as? String
        {
            lblTitle.text = str
        }
        
        setUpTopBar()
        CreateMainArrayHavingSubArrayForEachTableRowHavingCollView() // this v r doing to make whole screen scroll Table + CollV both together
        setupValues()
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
    
    func CreateMainArrayHavingSubArrayForEachTableRowHavingCollView()
    {
        // actually earlier we were showing list of courses like 2 in one row, like a grid, so we r using Coll View & if it found that it is odd, then v add one extra empty object to array, to maintain, the even consistency
        
        // First check what is count of Array, then divide by 2, to check if it's even, if it's odd, then add One more to it, so that ll be total  number of rows in Table, which show either 2 items in collv or one item in CollV
        // a row in table will not show more than 2 cells in collv
        
        // so need to make a Super array (arrRows_CollV), which will hold Array of each item in CollV
        
        if let arrMain:[[String:Any]] = d_Category["courses"] as? [[String:Any]]
        {
            let count = arrMain.count
            var checkEven:Bool = true
            
            if count % 2 == 0
            {
                checkEven = true
            }
            else
            {
                checkEven = false
                isArrayForOddRecords = true
            }
            
            countForNumberOfCollVRows = count/2  // chek here how many rows for table is needed to show collv in each row
            
            if checkEven == false
            {
                countForNumberOfCollVRows = countForNumberOfCollVRows + 1 // if its odd, add one, to show singgle item in collv inside table row
            }
            
            var howManyIndexDone = 0 // this will basically ll iterate For Loop from that point only, i.e it ll not include those items from array which are already checked
            for _ in 1...countForNumberOfCollVRows
            {
                var checkIfItsTwo = 0
                
                var each2InnerArray:[[String:Any]] = []
                
                for index in howManyIndexDone..<arrMain.count
                {
                    let d:[String:Any] = arrMain[index]
                    
                    if let id:Int = d["id"] as? Int
                    {
                        print(" - - - - - -  - - - - - - -  ", id)
                    }
                    
                    each2InnerArray.append(d)
                    
                    checkIfItsTwo = checkIfItsTwo + 1
                    howManyIndexDone = howManyIndexDone + 1
                    
                    print(" > > > >  ", howManyIndexDone)
                    
                    if checkIfItsTwo == 2 // if it's equal to 2, then break inner For Loop and jump to next main For loop index
                    {
                        arrRows_CollV.append(each2InnerArray)
                        break
                    }
                    if howManyIndexDone == arrMain.count // for last item, if it's only ODD
                    {
                        arrRows_CollV.append(each2InnerArray)
                        break
                    }
                }
            }
            
        }
    }
    
    func setupValues()
    {
        self.tblView.estimatedRowHeight = 50
        self.tblView.rowHeight = UITableView.automaticDimension
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.reloadData()
    }
    
    @IBAction func btnBackClick(btn:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CategoryDetailVC
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

extension CategoryDetailVC: UITableViewDelegate, UITableViewDataSource
{
    // MARK: TableView protocols
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return countForNumberOfCollVRows + 2 // +2 for HeaderImage + Desc
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0
        {
            // Header
            //   return 226    March 2020
            return 0
        }
        else if indexPath.row == 1
        {
            // Description
            return 40 // UITableView.automaticDimension // HIDING cell.lblDescription.text March2020
        }
        else
        {
            // for Coll View height in each row
            //  let arrToPass:[[String:Any]] = arrRows_CollV[currentIndexPath]
            var count = 0
            if arrRows_CollV.count > 0{
                count = arrRows_CollV.first!.count
            }
            let height:CGFloat = CGFloat((count * 200) + 20)
            // print("Each Table Row Heigght - ", height)
            
            if isArrayForOddRecords == true
            {
                // this check is made because, in method "CreateMainArrayHavingSubArrayForEachTableRowHavingCollView", we created a super array, containing 2 array at each index to show, as one row of coll view, then we inc. the width of each item of collv so that it look like a table listing, then due to this, we added a empty item in arrRows_CollV, if total of items in main array is odd, so that, we coukd show item in last row of coll view to left, now it was showing the empty space of 200 for last row if items are odd, now we just deleting that empty space not the item
                if indexPath.row == countForNumberOfCollVRows + 1
                {
                    return height - 200
                }
            }
            
            return height
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0
        {
            // Header
            let cell:CellCatDetail_ImageHeader = self.tblView.dequeueReusableCell(withIdentifier: "CellCatDetail_ImageHeader") as! CellCatDetail_ImageHeader
            cell.selectionStyle = .none
            
            cell.lblTitle.text = ""
            cell.vBk.backgroundColor = .red
            
            cell.imgView.backgroundColor = .clear
            
            if let imgStr:String = d_Category["coverImageUrl"] as? String
            {
                cell.imgView.setImageUsingUrl(imgStr)
            }
            
            return cell
        }
        else if indexPath.row == 1
        {
            // Description
            let cell:CellCatDetail_Header = self.tblView.dequeueReusableCell(withIdentifier: "CellCatDetail_Header") as! CellCatDetail_Header
            cell.selectionStyle = .none
            
            cell.lblDescription.text = ""
            
            if let str:String = d_Category["description"] as? String
            {
                // set attribute font
                
                let attributes = [NSAttributedString.Key.font: UIFont(name: CustomFont.GSLRegular, size: 19)!,
                                  NSAttributedString.Key.foregroundColor: UIColor.darkGray]
                
                let attributedString : NSAttributedString = NSAttributedString(string: str.htmlToString, attributes: attributes)
                
                //  cell.lblDescription.attributedText = attributedString    HIDING cell.lblDescription.text March2020
            }
            
            return cell
        }
        else
        {
            // Coll View
            
            let currentIndexPath = indexPath.row - 2
            
            let arrToPass:[[String:Any]] = arrRows_CollV[currentIndexPath]
            
            let cell:CellCatDetail_Courses = self.tblView.dequeueReusableCell(withIdentifier: "CellCatDetail_Courses") as! CellCatDetail_Courses
            
            cell.selectionStyle = .none
            
            //   cell.collView.isScrollEnabled = false
            
            cell.arrData = arrToPass
            
            cell.closure = {(selectedDict:[String:Any]) in
                
                print(" - - Take to Detail Video Screen, Call Api - -")
                // print(selectedDict)
                
                // for every selection call getCourseWith api and then in it's response, check if it's paid or not
                
                self.callDetailForSelectedCourse(dictCourses: selectedDict) // changed april2020
                //                self.CheckCourseIsPaid(dictCourses: selectedDict) // older
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}

extension CategoryDetailVC
{
    func callDetailForSelectedCourse(dictCourses:[String:Any])
    {
        if let courseID:Int = dictCourses["id"] as? Int
        {
            getCourseWith(id: "\(courseID)")
        }
    }
    
    func CheckCourseIsPaid(dictCourses:[String:Any])
    {
        if let isPaid:Bool = dictCourses["isPaidCourse"] as? Bool
        {
            if isPaid == true
            {
                if let userPaid:Bool = dictCourses["userPaid"] as? Bool
                {
                    if userPaid == true
                    {
                        if let courseID:Int = dictCourses["id"] as? Int
                        {
                            if isUserRestoredAllPurchases == false
                            {
                                // we are implementing Restore Purchase, so for that we will take user always to "PaidDetailVC" and there show Restore Button and complete restore process, then take user back to Home, then from next time onwards user will not come in this check and rather go to CourseDetailVideosVC
                                
                                print(". . . it's for  RESTORE - - - - - - - - - - -")
                                let vc:PaidDetailVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "PaidDetailVC_ID") as! PaidDetailVC
                                vc.dictCourse = dictCourses
                                vc.isRestoreCall = true
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            else
                            {
                                // Already Product Restored, now go to detail video screen
                                DispatchQueue.main.async {
                                    print("- Navigagte to Course Detail Video Screen -")
                                    let vc:CourseDetailVideosVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "CourseDetailVideosVC_ID") as! CourseDetailVideosVC
                                    vc.dictCourse = dictCourses
                                    vc.idToRefreshList = "\(courseID)"
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }
                    }
                    else
                    {
                        if let price:Double = dictCourses["price"] as? Double
                        {
                            print("Pay This Amount - -> ", price)
                            print("Its PAID course, take to PaidDetailVC")
                            self.takeToPaidCourseDetailScreen(dict: dictCourses)
                        }
                        else
                        {
                            if let courseID:Int = dictCourses["id"] as? Int
                            {
                                DispatchQueue.main.async {
                                    print("- Navigagte to Course Detail Video Screen -")
                                    let vc:CourseDetailVideosVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "CourseDetailVideosVC_ID") as! CourseDetailVideosVC
                                    vc.dictCourse = dictCourses
                                    vc.idToRefreshList = "\(courseID)"
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }
                    }
                }
                else
                {
                    if let price:Double = dictCourses["price"] as? Double
                    {
                        print("Pay This Amount - -> ", price)
                        print("Its PAID course, take to PaidDetailVC")
                        self.takeToPaidCourseDetailScreen(dict: dictCourses)
                    }
                    else
                    {
                        if let courseID:Int = dictCourses["id"] as? Int
                        {
                            DispatchQueue.main.async {
                                print("- Navigagte to Course Detail Video Screen -")
                                let vc:CourseDetailVideosVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "CourseDetailVideosVC_ID") as! CourseDetailVideosVC
                                vc.dictCourse = dictCourses
                                vc.idToRefreshList = "\(courseID)"
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                }
            }
            else
            {
                if let courseID:Int = dictCourses["id"] as? Int
                {
                    DispatchQueue.main.async {
                        print("- Navigagte to Course Detail Video Screen -")
                        let vc:CourseDetailVideosVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "CourseDetailVideosVC_ID") as! CourseDetailVideosVC
                        vc.dictCourse = dictCourses
                        vc.idToRefreshList = "\(courseID)"
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
        else
        {
            if let courseID:Int = dictCourses["id"] as? Int
            {
                DispatchQueue.main.async {
                    print("- Navigagte to Course Detail Video Screen -")
                    let vc:CourseDetailVideosVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "CourseDetailVideosVC_ID") as! CourseDetailVideosVC
                    vc.dictCourse = dictCourses
                    vc.idToRefreshList = "\(courseID)"
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
    }
    
    func takeToPaidCourseDetailScreen(dict:[String:Any])
    {
        let vc:PaidDetailVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "PaidDetailVC_ID") as! PaidDetailVC
        vc.dictCourse = dict
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getCourseWith(id:String)
    {
        self.showSpinnerWith(title: "Cargando...")
        let url2Pass = serviceName.GetSelectedCourse.rawValue + "\(id)"
        var header:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        
        if isUserTappedSkipButton == true{
            header = ["Content-Type":"application/json"]
        }
        
        WebService.callApiWith(url: url2Pass, method: .get, parameter: nil, header: header, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonString:String, error:Error?) in
            
            self.hideSpinner()
            //   print(jsonString)
            
            if error != nil
            {
                self.showAlertWithTitle(title: "Alerta", message: "\(error!.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
            
            if let code:Int = json["code"] as? Int
            {
                if code >= 200 && code < 300
                {
                    if let rootDict:[String:Any] = json["response"] as? [String:Any]
                    {
                        self.CheckCourseIsPaid(dictCourses: rootDict)
                        
                        /*
                         DispatchQueue.main.async {
                         print("- Navigagte to Course Detail Video Screen -")
                         let vc:CourseDetailVideosVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "CourseDetailVideosVC_ID") as! CourseDetailVideosVC
                         vc.dictCourse = rootDict
                         vc.idToRefreshList = id
                         self.navigationController?.pushViewController(vc, animated: true)
                         }
                         */
                    }
                }
            }
        }
    }
}
