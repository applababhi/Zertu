//
//  CellCatDetail_Courses.swift
//  home
//
//  Created by Abhishek Visa on 2/12/19.
//  Copyright © 2019 Shalini. All rights reserved.
//

import UIKit
import GTProgressBar

class CellCatDetail_Courses: UITableViewCell {

    @IBOutlet weak var collView:UICollectionView!    
    
    var arrData:[[String:Any]] = []{
        didSet{
            self.collView.dataSource = self
            self.collView.delegate = self
            self.collView.reloadData()
        }
    }
    
    var closure:([String:Any]) -> () = {(selectedDict:[String:Any]) in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


extension CellCatDetail_Courses: UICollectionViewDataSource, UICollectionViewDelegate
{
    // MARK: - UICollectionView protocols

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let dict:[String:Any] = arrData[indexPath.item]
        
        let cell:CollCellCatDetail_Course = collView.dequeueReusableCell(withReuseIdentifier: "CollCellCatDetail_Course", for: indexPath as IndexPath) as! CollCellCatDetail_Course
        
        cell.vBk.layer.cornerRadius = 5.0
        cell.vBk.layer.borderColor = UIColor.gray.cgColor
        cell.vBk.layer.borderWidth = 0.7
        cell.vBk.layer.masksToBounds = true
        
        cell.imgCourse.backgroundColor = .clear
        
        cell.lblIsPaid.isHidden = false
        cell.lblIsPaid.text = ""
        cell.lblIsPaid.backgroundColor = UIColor(named: "CyanGreenBackground")
        cell.lblIsPaid.layer.cornerRadius = 5.0
        cell.lblIsPaid.layer.masksToBounds = true
        
        
        /*
        cell.lblDesc.text = ""
        cell.lblPrice.text = ""
        cell.lblPercent.text = ""
        cell.progressBar.progress = 0.6
        
        if let str:String = dict["name"] as? String
        {
            cell.lblDesc.text = str
        }
        
        var totalVideosCount:Float = 0.0
        var watchedVideos:Float = 0.0

        if let videosNotWatched:Int = dict["totalVideosNotWatched"] as? Int
        {
            if let videosWatched:Int = dict["totalVideosWatched"] as? Int
            {
                totalVideosCount = Float(videosNotWatched + videosWatched)
                watchedVideos = Float(videosWatched)
                
                print(watchedVideos)
                print(totalVideosCount)
            }
        }
        
        if totalVideosCount != 0 // otherwise it ll be infinity 0/0
        {
            let progessPercent = watchedVideos/totalVideosCount
            cell.progressBar.progress = CGFloat(progessPercent)
            
            var decimalProgess:Float = watchedVideos/totalVideosCount
            print("- - - ", decimalProgess)
          
            decimalProgess = decimalProgess * 100
            let value = Float(decimalProgess).rounded(toPlaces: 0)
            let strValue:String = "\(value)"
            cell.lblPercent.text = "Avance \(strValue.components(separatedBy: ".").first!)%"
        }

        cell.progressBar.barBorderColor = UIColor.colorWithHexString("8a2be2")
        cell.progressBar.barFillColor = k_baseColor
        cell.progressBar.barBackgroundColor = UIColor.colorWithHexString("d3d3d3") // gray
        cell.progressBar.barBorderWidth = 0.5
        cell.progressBar.displayLabel = false
*/
        
        if let str:String = dict["coverImageUrl"] as? String
                {
                    if str.contains("https") == false
                    {
                       // let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
                     //   let strToEncode = str.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
                        let imgLink = "\(baseImgUrl)" + str
                        
                        cell.imgCourse.setImageUsingUrl(imgLink)
                    }
                    else
                    {
                        cell.imgCourse.setImageUsingUrl(str)
                    }
                }
                        
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
                              //  cell.lblPrice.text = "Ver Curso"
                                cell.lblIsPaid.text = "Ver Curso"
                            }
                            else
                            {
                                if let price:Double = dict["price"] as? Double
                                {
                                 //   cell.lblPrice.text = "Precio: $ \(price)"
                                 //   cell.lblPrice.textColor = .black
                                    cell.lblIsPaid.text = "Precio: $ \(Int(price))"
                                    cell.lblIsPaid.textColor = .black
        //                            cell.btnViewCourse.setTitle("Pagar", for: .normal)
                                }
                                else
                                {
                                    print("It's Free Course")
                                  //  cell.lblPrice.text = "Ver Curso"
                                    cell.lblIsPaid.text = "Ver Curso"
                                }
                            }
                        }
                        else
                        {
                            if let price:Double = dict["price"] as? Double
                            {
                              //  cell.lblPrice.text = "Precio: $ \(price)"
                                cell.lblIsPaid.text = "Precio: $ \(Int(price))"
        //                        cell.btnViewCourse.setTitle("Pagar", for: .normal)
                            }
                            else
                            {
                                print("It's Free Course")
                             //   cell.lblPrice.text = "Ver Curso"
                                cell.lblIsPaid.text = "Ver Curso"
                            }
                        }
                    }
                    else
                    {
                        print("It's Free Course")
                      //  cell.lblPrice.text = "Ver Curso"
                        cell.lblIsPaid.text = "Ver Curso"
                    }
                }
                else
                {
                    print("It's Free Course")
//                    cell.lblPrice.text = "Ver Curso"
                    cell.lblIsPaid.text = "Ver Curso"
                }
                
                /////////////////////
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let dict:[String:Any] = arrData[indexPath.item]
        
        closure(dict)
    }
}

extension CellCatDetail_Courses : UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
                
        return CGSize(width: collectionViewWidth/1.10, height: 200)
      //  return CGSize(width: collectionViewWidth/2.10, height: 235) // old bigger one
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
