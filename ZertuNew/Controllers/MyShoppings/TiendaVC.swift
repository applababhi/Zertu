//
//  TiendaVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 31/12/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit
import SDWebImageWebPCoder

class TiendaVC: UIViewController {

    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var collView:UICollectionView!
    @IBOutlet weak var vShowCart:UIView!
    @IBOutlet weak var lblBadge:UILabel!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    var arrProducts:[[String:Any]] = []
    var arrProducts_Filtered:[[String:Any]] = []
    var arrCategories:[[String:Any]] = [] // Collection View
    
    var str_AlreadySelected_Category = "All"        
        
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrProducts_Filtered = arrProducts
        
        vShowCart.isHidden = true
        
        if k_helper.arrCart_products_InTiendaScreen.count > 0
        {
            vShowCart.isHidden = false
        }
        
        lblBadge.text = ""
        lblBadge.layer.cornerRadius = 10.0
        lblBadge.layer.borderWidth = 0.5
        lblBadge.layer.masksToBounds = true
        
        self.collView.dataSource = self
        self.collView.delegate = self

        // below 2 lines used because in this screen we are getting image extension as  webP
        let WebPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(WebPCoder)
        
        print("Array for Collection View Filter ::  ", arrCategories)
        self.tblView.estimatedRowHeight = 60
        self.tblView.rowHeight = UITableView.automaticDimension
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
        else if strModel == "iPhone 6"
        {
            
        }
        else
        {
            // UNKNOWN CASE - Like iPhone 11 or XR
            c_TopBar_Ht.constant = 90
        }
    }
    
    @IBAction func btnBackClick(btn:UIButton)
    {
        if k_helper.arrCart_products_InTiendaScreen.count > 0
        {
            let alert = UIAlertController(title: "Artículos en la cesta", message: "Si vuelves, se vaciará tu cesta", preferredStyle: .alert)
                
                 let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                     k_helper.arrCart_products_InTiendaScreen.removeAll()
                     self.navigationController?.popViewController(animated: true)
                 })
                 alert.addAction(ok)
                 let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
                 })
                 alert.addAction(cancel)
            
                 DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true)
            })
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnCartClick(btn:UIButton)
    {
        print("Take to Show Cart Screen > > > > > > > > >  >")
    //    print("CART Array - - - -  \n", k_helper.arrCart_products_InTiendaScreen)
        
        let vc:ShowCartVC = AppStoryboards.More.instance.instantiateViewController(identifier: "ShowCartVC_ID") as! ShowCartVC
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension TiendaVC
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

extension TiendaVC
{
    override func viewWillAppear(_ animated: Bool)
    {
      //  callGetProducts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }    
}

extension TiendaVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrProducts_Filtered.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict:[String:Any] = self.arrProducts_Filtered[indexPath.row]
        
        let cell:CellProductList = tblView.dequeueReusableCell(withIdentifier: "CellProductList", for: indexPath) as! CellProductList
        cell.selectionStyle = .none
        cell.lblName.text = ""
        cell.lblStrike.text = ""
        cell.lblPrice.text = ""
        cell.lblCount.text = ""
        cell.lbl_InStock.text = "No hay artículos en stock"
        cell.imgView.image = nil
        cell.imgView.contentMode = .scaleAspectFit
        cell.lbl_InStock.textColor = .systemRed
        
        cell.vBk.layer.cornerRadius = 5.0
        cell.vBk.layer.borderWidth = 0.7
        cell.vBk.layer.borderColor = UIColor.lightGray.cgColor
        cell.vBk.layer.masksToBounds = true
        
        cell.vCounter.layer.cornerRadius = 5.0
        cell.vCounter.layer.borderWidth = 0.5
        cell.vCounter.layer.borderColor = UIColor.black.cgColor
        cell.vCounter.layer.masksToBounds = true
        
        cell.btnViewDetail.layer.cornerRadius = 20.0
        cell.btnViewDetail.layer.borderWidth = 0.6
        cell.btnViewDetail.layer.masksToBounds = true
        
        cell.btnAddToCart.layer.cornerRadius = 5.0
        cell.btnAddToCart.layer.masksToBounds = true
        
        cell.c_lblStrike_Ht.constant = 25
        
        cell.btnMinus.tag = indexPath.row
        cell.btnPlus.tag = indexPath.row
        
        cell.btnViewDetail.tag = indexPath.row
        cell.btnAddToCart.tag = indexPath.row

        var strRegularPrice = ""
     //   var strSalePrice = ""
        
        if let str:String = dict["name"] as? String
        {
            cell.lblName.text = str
        }
        if let str_Reg:String = dict["regular_price"] as? String
        {
            
            strRegularPrice = str_Reg
            
            let attributeString =  NSMutableAttributedString(string: "Precio regular: $\(str_Reg)")
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                         value: NSUnderlineStyle.single.rawValue,
                                             range: NSMakeRange(0, attributeString.length))
            cell.lblStrike.attributedText = attributeString
            
            if let str:String = dict["sale_price"] as? String
            {
                cell.lblPrice.text = "Promoción: $\(str)"
            //    strSalePrice = str
                
                if str == ""
                {
                    cell.c_lblStrike_Ht.constant = 0
                    cell.lblPrice.text = "Precio : $\(strRegularPrice)"
                }
            }
            else
            {
                cell.c_lblStrike_Ht.constant = 0
                cell.lblPrice.text = "Precio : $\(strRegularPrice)"
            }
        }
        
        if let count:Int = dict["counter"] as? Int
        {
            cell.lblCount.text = "\(count)"
        }
        
        if let quant:Int = dict["stock_quantity"] as? Int
        {
            if quant > 0
            {
                cell.lbl_InStock.textColor = UIColor.colorWithHexString("#158E0B") // green
                cell.lbl_InStock.text = "\(quant) Artículo en stock"
            }
        }
        
        if let arrImg:[[String:Any]] = dict["images"] as? [[String:Any]]
        {
            cell.imgView.image = UIImage(named: "ph")
            
            if arrImg.count > 0
            {
                let di:[String:Any] = arrImg.first!
               
                if let imgStr:String = di["src"] as? String
                {
                    if imgStr.contains("webp") == true{
                        cell.imgView.sd_setImage(with: NSURL(string: imgStr) as URL?)
                    }
                    else{
                        cell.imgView.setImageUsingUrl(imgStr)
                    }
                }
            }
        }
        
        cell.btnMinus.addTarget(self, action: #selector(self.btnMinus_Clicked(btn:)), for: .touchUpInside)
        cell.btnPlus.addTarget(self, action: #selector(self.btnPlus_Clicked(btn:)), for: .touchUpInside)  // ADD TO CART
    
        cell.btnViewDetail.addTarget(self, action: #selector(self.btnViewDetail_Clicked(btn:)), for: .touchUpInside)

//        cell.btnAddToCart.addTarget(self, action: #selector(self.btnAddtoCart_Clicked(btn:)), for: .touchUpInside)
        
        cell.btnAddToCart.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func btnViewDetail_Clicked(btn:UIButton)
    {
        print(">>>>>>>   Take to Detail Page")
        let selectedDict:[String:Any] = self.arrProducts_Filtered[btn.tag]
        
        let vc:EachProductDetailVC = AppStoryboards.More.instance.instantiateViewController(identifier: "EachProductDetailVC_ID") as! EachProductDetailVC
        vc.d_ToUpdate = selectedDict
        vc.delegate = self
        
        if let masterName:String = selectedDict["name"] as? String
        {
            vc.strTitle = masterName
        }
        if let des:String = selectedDict["description"] as? String
        {
            vc.strDesc = des
        }
        if let arrImg:[[String:Any]] = selectedDict["images"] as? [[String:Any]]
        {
            if arrImg.count > 0
            {
                let di:[String:Any] = arrImg.first!
               
                if let imgStr:String = di["src"] as? String
                {
                    vc.strImgUrl = imgStr                    
                }
            }
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func btnPlus_Clicked(btn:UIButton)   // ADD TO CART
    {
        var count = 0
        var d_ToUpdate:[String:Any] = self.arrProducts_Filtered[btn.tag]
        var quantity_InStock = 0
        
        if let quant:Int = d_ToUpdate["stock_quantity"] as? Int
        {
            quantity_InStock = quant
            if quant == 0
            {
                self.showAlertWithTitle(title: "Alerta", message: "No hay artículos en stock", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
        }
        else{
            self.showAlertWithTitle(title: "Alerta", message: "No hay artículos en stock", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        
        if let cou:Int = d_ToUpdate["counter"] as? Int
        {
            count = cou
        }
        
        if count == quantity_InStock
        {
            self.showAlertWithTitle(title: "Alerta", message: "Cantidad máxima alcanzada", okButton: "Ok", cancelButton: "", okSelectorName: nil)
            return
        }
        
        count = count + 1
        
        d_ToUpdate["counter"] = count
        self.arrProducts_Filtered[btn.tag] = d_ToUpdate
        
        // Adding to Cart here
        var selectedProduct_Id:Int = 0
        
        if let id: Int = d_ToUpdate["id"] as? Int
        {
            selectedProduct_Id = id
        }
                
        if k_helper.arrCart_products_InTiendaScreen.count > 0
        {
            var foundIndex:Int!
            var checkIfSameItemExistInCart = false
            for index in 0..<k_helper.arrCart_products_InTiendaScreen.count
            {
                let dic:[String:Any] = k_helper.arrCart_products_InTiendaScreen[index]
                if let idProd: Int = dic["id"] as? Int
                {
                    if idProd == selectedProduct_Id
                    {
                        foundIndex = index
                        checkIfSameItemExistInCart = true
                    }
                }
            }
            
            if checkIfSameItemExistInCart == false{
                k_helper.arrCart_products_InTiendaScreen.append(d_ToUpdate)
            }
            else
            {
                // repeated case
                k_helper.arrCart_products_InTiendaScreen[foundIndex] = d_ToUpdate
            }
        }
        else{
            k_helper.arrCart_products_InTiendaScreen.append(d_ToUpdate)
        }
        
        self.lblBadge.text = "\(k_helper.arrCart_products_InTiendaScreen.count)"
        vShowCart.isHidden = false
        
        let indexPath = IndexPath(item: btn.tag, section: 0)
        tblView.reloadRows(at: [indexPath], with: .fade)
    }
    
    @objc func btnMinus_Clicked(btn:UIButton)
    {
        var count = 0
        var d:[String:Any] = self.arrProducts_Filtered[btn.tag]
        if let cou:Int = d["counter"] as? Int
        {
            count = cou
        }
        
        if count != 0
        {
            count = count - 1
            d["counter"] = count
            self.arrProducts_Filtered[btn.tag] = d
            
            
            // Removing from Cart here
            var selectedProduct_Id:Int = 0
            
            if let id: Int = d["id"] as? Int
            {
                selectedProduct_Id = id
            }
            
            if k_helper.arrCart_products_InTiendaScreen.count > 0
            {
                var foundIndex:Int!
                for index in 0..<k_helper.arrCart_products_InTiendaScreen.count
                {
                    let dic:[String:Any] = k_helper.arrCart_products_InTiendaScreen[index]
                    if let idProd: Int = dic["id"] as? Int
                    {
                        if idProd == selectedProduct_Id
                        {
                            foundIndex = index
                            
                            if count == 0
                            {
                                k_helper.arrCart_products_InTiendaScreen.remove(at: foundIndex)
                                
                                if k_helper.arrCart_products_InTiendaScreen.count == 0
                                {
                                    self.lblBadge.text = "\(k_helper.arrCart_products_InTiendaScreen.count)"
                                    vShowCart.isHidden = true
                                }
                                
                                self.lblBadge.text = "\(k_helper.arrCart_products_InTiendaScreen.count)"
                                let indexPath = IndexPath(item: btn.tag, section: 0)
                                tblView.reloadRows(at: [indexPath], with: .fade)

                                return
                            }
                        }
                    }
                }
                
                k_helper.arrCart_products_InTiendaScreen[foundIndex] = d
                self.lblBadge.text = "\(k_helper.arrCart_products_InTiendaScreen.count)"
                vShowCart.isHidden = false
            }
            else{
                self.lblBadge.text = "\(k_helper.arrCart_products_InTiendaScreen.count)"
                vShowCart.isHidden = true
            }
            
            
            let indexPath = IndexPath(item: btn.tag, section: 0)
            tblView.reloadRows(at: [indexPath], with: .fade)
        }
    }
}

extension TiendaVC: UICollectionViewDataSource, UICollectionViewDelegate
{
    // MARK: - UICollectionView protocols

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let dict:[String:Any] = arrCategories[indexPath.item]
        
        let cell:CollCellTienda_Category = self.collView.dequeueReusableCell(withReuseIdentifier: "CollCellTienda_Category", for: indexPath as IndexPath) as! CollCellTienda_Category
        
        cell.btn.setTitleColor(.clear, for: .normal)
        cell.lblTitle.text = ""
        cell.lblTitle.textColor = .white
        cell.lblTitle.backgroundColor = .lightGray
        cell.lblTitle.layer.cornerRadius = 15.0
        cell.lblTitle.layer.borderWidth = 0.5
        cell.lblTitle.layer.masksToBounds = true
             
        if let str: String = dict["title"] as? String
        {
            cell.lblTitle.text = str
            cell.btn.setTitle(str, for: .normal)
        }
        
        if let check: Bool = dict["selected"] as? Bool
        {
            if check == true
            {
                cell.lblTitle.backgroundColor = k_baseColor
            }
        }
        
        cell.btn.tag = indexPath.item
        cell.btn.addTarget(self, action: #selector(self.categoryTapped(btn:)), for: .touchUpInside)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
    
    @objc func categoryTapped(btn:UIButton)
    {
        let dictSelected:[String:Any] = arrCategories[btn.tag]
        let strTitle:String = dictSelected["title"] as! String
        
        if str_AlreadySelected_Category == strTitle
        {
            print("Tapped on already selected Category..")
            return
        }
        
        print("Filter the Array and refresh the list ..... .....")
        
        str_AlreadySelected_Category = strTitle
        
        for ind in 0..<arrCategories.count
        {
            var dict:[String:Any] = arrCategories[ind]
            dict["selected"] = false
            if ind == btn.tag
            {
                dict["selected"] = true
            }
            arrCategories[ind] = dict
        }
        self.collView.reloadData()
        
        self.arrProducts_Filtered.removeAll()
        
        if str_AlreadySelected_Category == "All"
        {
            self.arrProducts_Filtered = self.arrProducts
            self.tblView.reloadData()
            
            return
        }
        
        // FILTER Products
        
        let filteredArray = self.arrProducts.filter{$0["Category_Updated_InCode"] as! String == str_AlreadySelected_Category}
        
        self.arrProducts_Filtered = filteredArray
        
        self.tblView.reloadData()
    }
}

extension TiendaVC : UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 135, height: 38)
//        return CGSize(width: collectionViewWidth/1.10, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}


class CollCellTienda_Category: UICollectionViewCell {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var btn:UIButton!
}

extension TiendaVC
{
    // Not calling in this class
    
    func callGetProducts()
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.GetProductsList.rawValue
        let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        
        WebService.callApiWith(url: urlStr, method: .get, parameter: nil, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
            print(jsonStr)
            self.hideSpinner()
            
            if error != nil
            {
                self.showAlertWithTitle(title: "Alerta", message: "\(error!.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }

            self.arrProducts.removeAll()
            if let code:Int = json["code"] as? Int
            {
                if code >= 200 && code < 300
                {
                    if let arrItems:[[String:Any]] = json["response"] as? [[String:Any]]
                    {
                        self.arrProducts = arrItems
                        for iind in 0..<self.arrProducts.count
                        {
                            var d:[String:Any] = self.arrProducts[iind]
                            d["counter"] = 0
                            self.arrProducts[iind] = d
                        }
                        
                        DispatchQueue.main.async {
                            if self.tblView.delegate == nil
                            {
                                self.tblView.delegate = self
                                self.tblView.dataSource = self
                            }
                            self.tblView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

extension TiendaVC: UpdateTheTiendaListWithCounter
{
    func updateTheDictAtIndex(id: Int, dict: [String : Any])
    {       
        str_AlreadySelected_Category = "All"
        for ind in 0..<arrCategories.count
        {
            var dict:[String:Any] = arrCategories[ind]
            dict["selected"] = false
            if ind == 0
            {
                dict["selected"] = true
            }
            arrCategories[ind] = dict
        }
        self.collView.reloadData()
        
        
        
        var foundIndex:Int!
        for index in 0..<self.arrProducts.count
        {
            let dic:[String:Any] = self.arrProducts[index]
            
            if let idFound:Int = dic["id"] as? Int
            {
                if idFound == id
                {
                    foundIndex = index
                    break
                }
            }
        }
        
        if foundIndex == nil{
            vShowCart.isHidden = true
            return
        }
        
        self.arrProducts[foundIndex] = dict
        
        self.arrProducts_Filtered = self.arrProducts
        self.tblView.reloadData()
        
        self.lblBadge.text = "\(k_helper.arrCart_products_InTiendaScreen.count)"
        vShowCart.isHidden = false
        
        if k_helper.arrCart_products_InTiendaScreen.count == 0
        {
            vShowCart.isHidden = true
        }
    }
}
