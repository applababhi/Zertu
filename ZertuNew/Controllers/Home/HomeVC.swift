//
//  HomeVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 22/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit
import KeychainSwift
import Floaty
import FirebaseAnalytics
import StoreKit

class HomeVC: UIViewController {

    @IBOutlet weak var btnLogout:UIButton!
    @IBOutlet weak var tblView:UITableView!
    var floaty = Floaty()

    // Tableview will be divided in 4 parts: Category + New Courses + In Person + Each Category
    var arr_NewCourses:[[String:Any]] = []
    var arr_Categories:[[String:Any]] = []
    var arr_InPerson:[[String:Any]] = []
    var arr_Masters:[[String:Any]] = []
    var arr_Library:[[String:Any]] = []
    var totalCountOfThisTable:Int!
    
    var arrRestoredProducts:[String] = []
    var arrUpdateTransactionCalled:[String] = []
    var d_Selected_Course:[String:Any] = [:]
    var id_Selected_Course:String = ""
    
    var arr_Images_For2Row:[[String:Any]] = []
    
    var carouselRef:iCarousel!
    let arrImages:[String] = ["banner_2", "banner_3"] // ["banner_1", "banner_2", "banner_3"]
    var timer:Timer!
    var itemCount:Int = 1
    
    var check_IfWindowRotated = false
    var check_SetRotateWindow = false
    var portraitFrame:CGRect!
    var playerViewController:LandscapePlayer!
    var briefVideoUrl_URL:URL!

    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        portraitFrame = self.view.frame
        setupFloatingButton()
        NotificationCenter.default.addObserver(self, selector: #selector(self.callServerToUpdateRefreshToken), name: Notification.Name("UpdateRereshToken"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        btnLogout.isHidden = false
        if isUserTappedSkipButton == true
        {
            btnLogout.isHidden = true
        }
        
        if k_helper.isNetworkAvailable ==  "Available"
        {
             callGetCertifications_ToCreate2ndRow()
        }
        else
        {
            DispatchQueue.main.async {
                self.showAlertWithTitle(title: "Alerta", message: "No hay conexión a internet disponible", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            }
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: AnalyticsParameterSuccess
        ])
    }
    
    @IBAction func btnLogoutClick(btn:UIButton)
    {
        let alertController = UIAlertController(title: "Cerrar sesión", message: "Estás seguro de que quieres desconectarte?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "sí", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("Yes Logout Pressed")
            self.callLogoutApi()
        }
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Logout Pressed")
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

}

extension HomeVC
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

extension HomeVC
{
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

extension HomeVC: UITableViewDelegate, UITableViewDataSource
{
    // MARK: TableView protocols

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
       var other3count = 0
        if self.arr_InPerson.count > 0 {
            other3count = other3count + 1
        }
        if self.arr_NewCourses.count > 0 {
            other3count = other3count + 1
        }
        if self.arr_Masters.count > 0 {
            other3count = other3count + 1
        }
        if self.arr_Library.count > 0 {  // this added new as a last row - March 2021
            other3count = other3count + 1
        }

 /* OLD       totalCountOfThisTable = (1 + 1 + self.arr_Categories.count + other3count) - 1 // -1 because we want to use this Var for comparing last item in Table to show master
        
        // First Header, Category, New Courses in one row, then InPerson in one row, then Each Category in each Row, in last Masters in one row
        return 1 + 1 + self.arr_Categories.count + other3count // 1 is for header Row, 1 is for Categories in a row
        */
        
        // after Feb2021, we made newCourse array and InPerson Array to zero
        totalCountOfThisTable = (1 + 1 + self.arr_Categories.count + other3count) - 1 // -1 because we want to use this Var for comparing last item in Table to show master
        
        // First Header, Static Content in one row, then Each Category in each Row, in last Masters in one row
        
        return 1 + 1 + self.arr_Categories.count + other3count // 1 is for header Row, 1 is for Static Content in a row
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0
        {
            // Image header carousel
            return 165
        }
        return 190
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0
        {
            // Header Image Banner
            let header:CellHome_Header = self.tblView.dequeueReusableCell(withIdentifier: "CellHome_Header") as! CellHome_Header
            header.selectionStyle = .none
            
//            header.imgView.backgroundColor = UIColor(named: "TabCircleColor")!
                
//            header.imgView.contentMode = .scaleAspectFill
//            header.imgView.image = #imageLiteral(resourceName: "InPerson")
            
            header.carousel.type = .linear
            header.carousel.backgroundColor = UIColor.white
            header.carousel.delegate = self
            header.carousel.dataSource = self
            
            self.carouselRef = header.carousel
            
            return header
        }
        
        // OLD(now this removed Feb2021) = = First show one row of All Categories, then New Courses in one row, then InPerson in one row, then Each Category in each Row and in last Masters in one row

        var other3count = 0
        if self.arr_InPerson.count > 0 {
            other3count = other3count + 1    // +1 means, we just need to add one row here
        }
        if self.arr_NewCourses.count > 0 {
            other3count = other3count + 1   // +1 means, we just need to add one more row here
        }
        if self.arr_Masters.count > 0 {
            other3count = other3count + 1   // +1 means, we just need to add one more row here
           
        //  don't need to add +1 here if still master count is > 0, because in next line we r calculating the index for eachCategoryArray and if we +1 here, then it ll say to eachCategoryArray outOfBound, and our conditon to show last cell as Master comes afetr assigning indexpathForEachCategory, so no problem in showing that.
        }
        if self.arr_Library.count > 0 {
//            other3count = other3count + 1   // +1 means, we just need to add one more row here
           
        //  don't need to add +1 here if still master count is > 0, because in next line we r calculating the index for eachCategoryArray and if we +1 here, then it ll say to eachCategoryArray outOfBound, and our conditon to show last cell as Master comes afetr assigning indexpathForEachCategory, so no problem in showing that.
        }
        var indexpathForEachCategory:Int!
        
        if indexPath.row <= 5
        {
            indexpathForEachCategory = indexPath.row - other3count //- 1  //   -1 Static Content row
        }
        else
        {
            indexpathForEachCategory = indexPath.row - other3count - 1  //   -1 Static Content row
        }
                
        let cell:CellHome_Rows = self.tblView.dequeueReusableCell(withIdentifier: "CellHome_Rows") as! CellHome_Rows
        cell.selectionStyle = .none
        cell.lblTitle.text = ""
                
        cell.lblTitle.font = UIFont(name: CustomFont.GSLRegular, size: 20.0)
        
        // change March2020, check if any category has sub category
        var check_SubCat:Bool = false
        cell.check_IsSubCategoryToShowSubCategoryScreenOnTap = false

        
        cell.closure = { (selectedDict:[String:Any], selectedTitle:String, isSubCategory:Bool) in
                        
            if selectedTitle == "Instituto"
            {
                // means it's a index 1 row
                if let imageName:String = selectedDict["image"] as? String
                {
                    /*
                    if imageName == "insti"
                    {
                        print(imageName)
                        DispatchQueue.main.async {
                            let vc:StaticItemTapDetailVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "StaticItemTapDetailVC_ID") as! StaticItemTapDetailVC
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        return
                    }
                    else if imageName == "recet"
                    {
                        print(imageName)
                        self.showAlertWithTitle(title: "Alerta", message: "Coming soon", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                        return
                    }
                    */
                    DispatchQueue.main.async {
                        let vc:StaticItemTapDetailVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "StaticItemTapDetailVC_ID") as! StaticItemTapDetailVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    return
                }
            }
            
//            print("Navigate to Course Detail screen \n - - - - >> ", selectedDict)
            print("Navigate to Course Detail screen \n ")
            print(" - - - - ", selectedTitle)
            print(" - - - - ", isSubCategory)
            
         //   print(selectedDict.jsonStringRepresentation!)
            
            if selectedTitle == "Maestros"
            {
                // Last Cell, show different Detail Screen
                
                let vc:MasterDetailVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "MasterDetailVC_ID") as! MasterDetailVC
                
                if let masterName:String = selectedDict["name"] as? String
                {
                    vc.strTitle = masterName
                }
                if let des:String = selectedDict["description"] as? String
                {
                    vc.strDesc = des
                }
                if let strUrl:String = selectedDict["primaryPicUrl"] as? String
                {
                    if strUrl.contains("https") == false
                    {
                        let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
                        let strToEncode = strUrl.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
                        let imgLink = "\(baseImgUrl)" + strToEncode!
                        vc.strImgUrl = imgLink
                    }
                    else
                    {
                        vc.strImgUrl = strUrl
                    }
                    
                }
                vc.btnHTML = ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
                else if selectedTitle == "Libros"
                {
                    // Last Cell, show different Detail Screen
                    
                    let vc:MasterDetailVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "MasterDetailVC_ID") as! MasterDetailVC
                 //   print(selectedDict)
                    if let masterName:String = selectedDict["name"] as? String
                    {
                        vc.strTitle = masterName
                    }
                    if let des:String = selectedDict["description"] as? String
                    {
                        vc.strDesc = des
                    }
                    if let strUrl:String = selectedDict["imageUrl"] as? String
                    {                        
                        vc.strImgUrl = strUrl
                    }
                    if let strUrl:String = selectedDict["url"] as? String
                    {
                        let checkExtension = strUrl.components(separatedBy: ".").last
                        vc.btnHTML = strUrl
                        vc.extensionStr = checkExtension ?? ""
                                                
                        if checkExtension == "pdf" || checkExtension == "PDF"
                        {
                            vc.isPDF = true
                        }
                    }
                    if let isFree:Bool = selectedDict["free"] as? Bool
                    {
                        vc.bookIsFree = isFree
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            else
            {
                self.navigateToDetailScreenonTap(name: selectedTitle, dict: selectedDict, isSubCategory: isSubCategory)
            }
        }
        
        if indexPath.row == 6
        {
//            cell.lblTitle.text = "Categorías" // OLD(now this removed Feb2021) Categories One Row
//            cell.arrData = self.arr_Categories
            
            cell.lblTitle.text = "Instituto"
//            cell.arrData = [["image":"insti"], ["image":"recet"]] // 2 static items for Row index 1
            cell.arrData = self.arr_Images_For2Row
            return cell
        }
        
        if indexPath.row == 2  // New Course (with condition, it may be there or may be zero count)
        {
            if self.arr_NewCourses.count > 0 {
                // here use arr_NewCourses
                cell.lblTitle.text = "Cursos nuevos"
                cell.arrData = self.arr_NewCourses
                
                return cell
            }
            else if self.arr_InPerson.count > 0 {
                // here use arr_InPerson
                cell.lblTitle.text = "Cursos presenciales"
                cell.arrData = self.arr_InPerson
                
                return cell
            }
        }
        if indexPath.row == 3  // In person Course
        {
            if self.arr_InPerson.count > 0 {
                // here use arr_InPerson
                cell.lblTitle.text = "Cursos presenciales"
                cell.arrData = self.arr_InPerson
                
                return cell
            }
        }
        if indexPath.row == totalCountOfThisTable - 1  //  Masters Row - Second last in list
        {
            if self.arr_Masters.count > 0 {
                // here use arr_InPerson
                cell.lblTitle.text = "Maestros"
                cell.arrData = self.arr_Masters
                
                return cell
            }
        }
       if indexPath.row == totalCountOfThisTable   // Last Masters Row
       {
           if self.arr_Library.count > 0 {
               // here use arr_InPerson
               cell.lblTitle.text = "Libros"
               cell.arrData = self.arr_Library
               
               return cell
           }
       }
        // for rest of IndexPaths use arr_Categories

        if let dict:[String:Any] = arr_Categories[indexpathForEachCategory] as? [String:Any]
        {
            if let str:String = dict["name"] as? String
            {
                if str.count > 44
                {
                    let strDevice = getDeviceModel()
                    if strDevice == "iPhone 5" || strDevice == "iPhone 6"
                    {
                        cell.lblTitle.font = UIFont(name: CustomFont.GSLRegular, size: 17.0)
                    }
                    else
                    {
                        cell.lblTitle.font = UIFont(name: CustomFont.GSLRegular, size: 19.0)
                    }
                }
                cell.lblTitle.text = str
            }
                        
            if let arrSubCat:[[String:Any]] = dict["subcategories"] as? [[String:Any]]
            {
                // Here in Subcategory Array, before passing to cell arrData, we need to iterate on ZCourses array, and check in it's dict, whether "subcourse" is false, if its false we need to add that particular course or courses along with arrSubCat
                var ar2pas:[[String:Any]] = []
                var arNonSubCourse:[[String:Any]] = []
                if let arr:[[String:Any]] = dict["courses"] as? [[String:Any]]
                {
                    for d in arr
                    {
                        if let checkSubCourse:Bool = d["subcourse"] as? Bool
                        {
                            if checkSubCourse == false
                            {
                                arNonSubCourse.append(d)
                            }
                        }
                    }
                }
                
                if arrSubCat.count > 0 // if only it has any value then do this
                {
                    ar2pas.append(contentsOf: arrSubCat)
                    ar2pas.append(contentsOf: arNonSubCourse)
                 
                    check_SubCat = true
                    cell.arrData = ar2pas   //  OLD -> arrSubCat
                    cell.check_IsSubCategoryToShowSubCategoryScreenOnTap = true
                }
                else
                {
                    // no else case here, if there is no arrSubCat, then no need to also pass the arNonSubCourse to cell.arrData, because then v need to pass full courses array, which v r doing 5 lines below
                }
            }
            
            if check_SubCat == false
            {
                if let arr:[[String:Any]] = dict["courses"] as? [[String:Any]]
                {
                    cell.arrData = arr
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    func navigateToDetailScreenonTap(name:String, dict:[String:Any], isSubCategory:Bool)
    {
        print("Take to detail screen on Tap - -")
        if name == "Categorías"
        {
            DispatchQueue.main.async {
                let vc:CategoryDetailVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "CategoryDetailVC_ID") as! CategoryDetailVC
                vc.d_Category = dict
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if isSubCategory == true
        {
            DispatchQueue.main.async {
                if let strSlug:String = dict["slug"] as? String
                {
                    self.getCoursesWith(slug: strSlug) // this case will come from arrSubCat items
                }
                else
                {
                    // Each Course Click
                    self.callDetailForSelectedCourse(dictCourses: dict)  // this case will come from arNonSubCourse items
                }
            }
        }        
        else if name == "Cursos presenciales"
        {
            // In Person Click
            
            if let id:Int = dict["id"] as? Int
            {
                self.callServerToGetInPersonCourseWith(id: "\(id)")
            }
        }
        else
        {
            // Each Course Click
            self.callDetailForSelectedCourse(dictCourses: dict)
        }
    }
    
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
                            self.d_Selected_Course = dictCourses
                            self.id_Selected_Course = "\(courseID)"
                            
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
}

extension HomeVC
{
    func callDashboardApi()
    {
        self.showSpinnerWith(title: "Cargando...")
        let url2Pass = serviceName.Dashboard.rawValue
        var header:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        
        if isUserTappedSkipButton == true{
            header = ["Content-Type":"application/json"]
        }
        
        WebService.callApiWith(url: url2Pass, method: .get, parameter: nil, header: header, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonString:String, error:Error?) in
            
             self.hideSpinner()
           //  print(jsonString)

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
                        if let arr:[[String:Any]] = rootDict["newCourses"] as? [[String:Any]]
                        {
                            self.arr_NewCourses = arr
                        }
                        if let arr:[[String:Any]] = rootDict["categories"] as? [[String:Any]]
                        {
                            self.arr_Categories = arr
                        }
                        if let arr:[[String:Any]] = rootDict["inPersonCourses"] as? [[String:Any]]
                        {
                            self.arr_InPerson = arr
                        }
                        if let arr:[[String:Any]] = rootDict["masters"] as? [[String:Any]]
                        {
                            self.arr_Masters = arr
                        }
                        if let arr:[[String:Any]] = rootDict["books"] as? [[String:Any]]
                        {
                            self.arr_Library = arr
                        }
                        
                        // Feb2021, remove below 3 Listing from the table and just add one static row
                        self.arr_NewCourses.removeAll()
                        self.arr_InPerson.removeAll()
                        
                        DispatchQueue.main.async {
                            self.tblView.delegate = self
                            self.tblView.dataSource = self
                            self.tblView.reloadData()
                            
                            if self.timer != nil
                            {
                                self.timer.invalidate()
                                self.timer = nil
                            }
                            self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.autoScroll), userInfo: nil, repeats: true)

                        }
                    }
                }
            }
            if let _:String = json["error500"] as? String
            {
                // this is coming when we play already watched video and in its end then again call api
                self.showAlertWithTitle(title: "Alerta", message: "Ocurrió algún error, intente nuevamente después de algún tiempo", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
        }
    }
    
    /*
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
                            getCourseWith(id: "\(courseID)")
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
                                getCourseWith(id: "\(courseID)")
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
                            getCourseWith(id: "\(courseID)")
                        }
                    }
                }
            }
            else
            {
                if let courseID:Int = dictCourses["id"] as? Int
                {
                    getCourseWith(id: "\(courseID)")
                }
            }
        }
        else
        {
            if let courseID:Int = dictCourses["id"] as? Int
            {
                getCourseWith(id: "\(courseID)")
            }
        }
    }
    */
    
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
    //         print(jsonString)

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
            if let _:String = json["error500"] as? String
            {
                // this is coming when we play already watched video and in its end then again call api
                self.showAlertWithTitle(title: "Alerta", message: "Ocurrió algún error, intente nuevamente después de algún tiempo", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
        }
    }
    
    func callServerToGetInPersonCourseWith(id:String)
    {
        self.showSpinnerWith(title: "Cargando...")
        var url2Pass:String = serviceName.InPersonCourseID.rawValue
        url2Pass = url2Pass.replacingOccurrences(of: "+++", with: id)
        
        let header:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        WebService.callApiWith(url: url2Pass, method: .get, parameter: nil, header: header, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonString:String, error:Error?) in
            
             self.hideSpinner()
           //  print(jsonString)

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
                        DispatchQueue.main.async {
                            let vc:InPersonDetailVC = AppStoryboards.InPerson.instance.instantiateViewController(identifier: "InPersonDetailVC_ID") as! InPersonDetailVC
                            vc.dict_InPerson = rootDict
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
            if let _:String = json["error500"] as? String
            {
                // this is coming when we play already watched video and in its end then again call api
                self.showAlertWithTitle(title: "Alerta", message: "Ocurrió algún error, intente nuevamente después de algún tiempo", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
        }
    }
    
    func callLogoutApi()
    {
        let keychain = KeychainSwift()
        keychain.set("", forKey: "ZertuUserEmail")
        keychain.set("", forKey: "ZertuUserPasscode")

        k_userDef.setValue("", forKey: userDefaultKeys.AccessToken.rawValue)
        k_userDef.setValue("", forKey: userDefaultKeys.RefreshToken.rawValue)
        k_userDef.synchronize()
        
        let vc: LoginVC = AppStoryboards.Login.instance.instantiateViewController(withIdentifier: "LoginVC_ID") as! LoginVC
        k_window.rootViewController = vc

        /*
        self.showSpinnerWith(title: "Cargando...")
        let param: [String:Any] = ["ios_notification_token":deviceToken_FCM]
        WebService.requestService(url: ServiceName.DELETE_Logout.rawValue, method: .delete, parameters: param, headers: [:], encoding: "URL", viewController: self) { (json:[String:Any], jsonString:String, error:Error?) in
            self.hideSpinner()
            //   print(jsonString)
            if error != nil
            {
                print("Error - ", error!)
                self.showAlertWithTitle(title: "Error", message: "\(error!.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
            else
            {
                print("USER LOGOUT - - - - - - - ")
                DispatchQueue.main.async {
                    k_userDef.setValue("", forKey: userDefaultKeys.AccessToken.rawValue)
                    k_userDef.setValue("", forKey: userDefaultKeys.RefreshToken.rawValue)
                    k_userDef.synchronize()
                    
                    let vc: LoginVC = AppStoryBoards.Login.instance.instantiateViewController(withIdentifier: "LoginVC_ID") as! LoginVC
                    k_window.rootViewController = vc
                }
            }
        }
        */
    }
    
    func getCoursesWith(slug:String)
    {
        self.showSpinnerWith(title: "Cargando...")
        let url2Pass = serviceName.GetEachCategoryNew.rawValue + "\(slug)"
        let header:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        WebService.callApiWith(url: url2Pass, method: .get, parameter: nil, header: header, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonString:String, error:Error?) in
            
             self.hideSpinner()
           //  print(jsonString)

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
                        DispatchQueue.main.async {
                            print("- Navigagte to Category Detail - Courses list Screen -")
                            let vc:CategoryDetailVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "CategoryDetailVC_ID") as! CategoryDetailVC
                            vc.d_Category = rootDict
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
            if let _:String = json["error500"] as? String
            {
                // this is coming when we play already watched video and in its end then again call api
                self.showAlertWithTitle(title: "Alerta", message: "Ocurrió algún error, intente nuevamente después de algún tiempo", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
        }
    }
}

/*
extension HomeVC: SKPaymentTransactionObserver, SKProductsRequestDelegate
{
    func showRestoreAlert()
    {
        let alert = UIAlertController(title: "Zertú", message: "Como ya compró los productos de Zertú, ahora es el momento de Restaurar todos los productos que compró. Haga clic en Restaurar para continuar.", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Restaurar", style: .default, handler: { action in
            self.callRestore()
        })
        alert.addAction(ok)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        
    }
    
    func callRestore()
    {
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
        print(error)
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
                
                let alert = UIAlertController(title: "Zertú", message: "El ID de Apple que utilizó para comprar productos anteriores es diferente de este ID de Apple. Utilice su antigua ID de Apple para restaurar la compra", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "Ok", style: .default, handler: { action in
                })
                alert.addAction(ok)
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true)
                })

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
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // print("- - - - ALL PRODUCTS IAP - - - - \n ", response.products)
        print("\n - - Product Count- - - - ", response.products.count)
        
        for product in response.products {
            print("- -   -   - -")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            print("   - -   ")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction:AnyObject in transactions
        {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction
            {
                switch trans.transactionState
                {
                case .restored:
                    print(" - - - - In App RESTORED Success  - -")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    DispatchQueue.main.async {
                        self.hideSpinner()
                        
                        print(">>>>>>>   updatedTransactions")
                        
                        self.arrUpdateTransactionCalled.append("updatedTransactions")
                        
                        // check count of array of all  purchased products and this delegagte called equal then all process completed, then proceed.
                        if self.arrRestoredProducts.count == self.arrUpdateTransactionCalled.count
                        {
                            let alert = UIAlertController(title: "Zertú", message: "Restauramos con éxito todos sus productos comprados. Presione Ok para continuar.", preferredStyle: .alert)
                            
                            let ok = UIAlertAction(title: "Ok", style: .default, handler: { action in
                                self.pushToCourseVideoDetailScreen()
                            })
                            alert.addAction(ok)
                            DispatchQueue.main.async(execute: {
                                self.present(alert, animated: true)
                            })
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
                    DispatchQueue.main.async {
                        self.hideSpinner()
                    }
                    break
                }
            }
        }
    }
    
    func pushToCourseVideoDetailScreen()
    {
        isUserRestoredAllPurchases = true
        
        k_userDef.set(true, forKey: userDefaultKeys.userRestoredAllPurchases.rawValue)
        k_userDef.synchronize()
        
        DispatchQueue.main.async {
            print("- Navigagte to Course Detail Video Screen -")
            let vc:CourseDetailVideosVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "CourseDetailVideosVC_ID") as! CourseDetailVideosVC
            vc.dictCourse = self.d_Selected_Course
            vc.idToRefreshList = self.id_Selected_Course
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
*/

extension HomeVC
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
