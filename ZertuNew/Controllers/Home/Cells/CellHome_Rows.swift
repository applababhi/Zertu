//
//  CellHome_Rows.swift
//  home
//
//  Created by Abhishek Visa on 28/11/19.
//  Copyright © 2019 Shalini. All rights reserved.
//

import UIKit

class CellHome_Rows: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var collView:UICollectionView!
    
    var check_IsSubCategoryToShowSubCategoryScreenOnTap = false
    
    var arrData:[[String:Any]] = [] {
        didSet{
            collView.dataSource = self
            collView.delegate = self
            collView.reloadData()
        }
    }
    
    var isStaticContent = false
    
    var closure:([String:Any], String, Bool) -> () = {(selectedDict:[String:Any], title:String, isSubCategory:Bool) in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension CellHome_Rows: UICollectionViewDataSource, UICollectionViewDelegate
{
    // MARK: - UICollectionView protocols

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

//   There was a problem, when v scroll UIImageViews in CollectionView in ios13, they are changing there sizes -> solution is to change the Estimate size to None(by default Automatic) in the Xcode 11 Storyboard.
        
        let dict:[String:Any] = arrData[indexPath.item]
   //     print(dict)
        let cell:CollCellHome = collView.dequeueReusableCell(withReuseIdentifier: "CollCellHome", for: indexPath as IndexPath) as! CollCellHome
        
        cell.vBk.layer.cornerRadius = 5.0
        cell.vBk.layer.borderWidth = 0.2
        cell.vBk.layer.masksToBounds = true
        cell.lblType.layer.cornerRadius = 5.0
        cell.lblType.layer.masksToBounds = true                
        
        cell.imgBk.contentMode = .scaleAspectFill
        cell.imgBk.image = nil
        cell.imgBk.clipsToBounds = true
        
        cell.lblType.isHidden = false
        cell.lblType.text = ""
        cell.lblType.backgroundColor = UIColor(named: "CyanGreenBackground")
        
        lblTitle.isHidden = false
        
        /////////////////////
        // if isPaidCourse is TRUE & userPaid is FALSE, then show Pay Button with Price, else just show, View Course
        if let isPaid:Bool = dict["isPaidCourse"] as? Bool
        {
                    if isPaid == true
                    {
                        if let userPaid:Bool = dict["userPaid"] as? Bool
                        {
                            if userPaid == true
                            {
                                print("It's Free Course")
                                cell.lblType.text = "Ver Curso"
                            }
                            else
                            {
                                if let price:Double = dict["price"] as? Double
                                {
                                    cell.lblType.text = "Precio: $\(Int(price))"
                                    cell.lblType.textColor = .black
        //                            cell.btnViewCourse.setTitle("Pagar", for: .normal)
                                }
                                else
                                {
                                    print("It's Free Course")
                                    cell.lblType.text = "Ver Curso"
                                }
                            }
                        }
                        else
                        {
                            if let price:Double = dict["price"] as? Double
                            {
                                cell.lblType.text = "Precio: $\(Int(price))"
        //                        cell.btnViewCourse.setTitle("Pagar", for: .normal)
                            }
                            else
                            {
                                print("It's Free Course")
                                cell.lblType.text = "Ver Curso"
                            }
                        }
                    }
                    else
                    {
                        print("It's Free Course")
                        cell.lblType.text = "Ver Curso"
                    }
        }
        else
        {
                print("It's Free Course")
                cell.lblType.text = "Ver Curso"
        }
                
        /////////////////////

        if let strUrl:String = dict["coverImageUrl"] as? String
        {
          //  cell.imgBk.setImageUsingUrl(strUrl)
        }
        if let strUrl:String = dict["newImageUrl"] as? String
        {
            cell.imgBk.setImageUsingUrl(strUrl)
        }
        
        if lblTitle.text == "Categorías" || lblTitle.text == "Instituto"
        {
           // cell.lblType.isHidden = true
            
            if lblTitle.text == "Instituto"
            {
                if let strIm:String = dict["image"] as? String
                {
//                    cell.imgBk.image = UIImage(named: strIm)
                    cell.imgBk.sd_setImage(with: URL(string: strIm), placeholderImage: UIImage(named: "ph.png"))
                    //lblTitle.isHidden = true
                }
            }
        }
        
        if lblTitle.text == "Maestros"  // Second Last Cell
        {
            if let masterName:String = dict["name"] as? String
            {
                cell.lblType.text = masterName
            }
            if let strUrl:String = dict["primaryPicUrl"] as? String
            {
                if strUrl.contains("https") == false
                {
                    let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
                    let strToEncode = strUrl.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
                    let imgLink = "\(baseImgUrl)" + strToEncode!
                    cell.imgBk.setImageUsingUrl(imgLink)
                }
                else
                {
                    cell.imgBk.setImageUsingUrl(strUrl)
                }
            }
        }
        
        if lblTitle.text == "Libros"  // Last Cell
        {
            if let name:String = dict["name"] as? String
            {
//                cell.lblType.text = name
                
                cell.lblType.isHidden = true
            }
            if let strUrl:String = dict["imageUrl"] as? String
            {
                cell.imgBk.setImageUsingUrl(strUrl)
            }
        }
                
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let dict:[String:Any] = arrData[indexPath.item]
        
        closure(dict, self.lblTitle.text!, check_IsSubCategoryToShowSubCategoryScreenOnTap)
    }
}

extension CellHome_Rows : UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        return CGSize(width: collectionViewWidth/1.35, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
