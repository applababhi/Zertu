//
//  ExtensionHomeVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 2/12/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

import KeychainSwift

extension HomeVC
{
    func callGetCertifications_ToCreate2ndRow()
    {
        arr_Images_For2Row = []
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.GetCertifications.rawValue
        var headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
      
        if isUserTappedSkipButton == true{
            headers = ["Content-Type":"application/json"]
        }
        
        WebService.callApiWith(url: urlStr, method: .get, parameter: nil, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
      //      print(jsonStr)
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
                    if let arr:[[String:Any]] = json["response"] as? [[String:Any]]
                    {
                        for d in arr
                        {
                            if let strImg:String = d["urlPortada"] as? String
                            {
                                self.arr_Images_For2Row.append(["image":strImg])
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.callDashboardApi()
                    
                    self.extractLinkFromVimeo(vidID: "444416615") // for Banner Video Tap zero index
                }
            }
        }
    }
    
    @objc func callServerToUpdateRefreshToken()
    {
        let keychain = KeychainSwift()
                
        if keychain.get("ZertuUserEmail") == nil
        {
            k_userDef.setValue("", forKey: userDefaultKeys.AccessToken.rawValue)
            k_userDef.setValue("", forKey: userDefaultKeys.RefreshToken.rawValue)
            k_userDef.synchronize()

            let vc:LoginVC = AppStoryboards.Login.instance.instantiateViewController(withIdentifier: "LoginVC_ID") as! LoginVC
            k_window.rootViewController = vc
            return
        }
        
        let strEmail:String = keychain.get("ZertuUserEmail")!
        let strPass:String = keychain.get("ZertuUserPasscode")!
        print("- - - - - > > > > > > > > > > > > >")
        
        //print(strEmail)
        //print(strPass)
        
        if strEmail == "" || strPass == ""
        {
            k_userDef.setValue("", forKey: userDefaultKeys.AccessToken.rawValue)
            k_userDef.setValue("", forKey: userDefaultKeys.RefreshToken.rawValue)
            k_userDef.synchronize()

            let vc:LoginVC = AppStoryboards.Login.instance.instantiateViewController(withIdentifier: "LoginVC_ID") as! LoginVC
            k_window.rootViewController = vc
            return
        }

        let urlString:String = "\(serviceName.LoginAPIAndRefreshToken.rawValue)"

        let param :[String:String] = ["password":strPass,"username" : strEmail, "grant_type":"password", "scope": "read write","client_secret":"zertu","client_id":"zertu"]
            
        let headers:[String:String] = ["Content-Type":"application/x-www-form-urlencoded", "Accept" : "application/json"]
            
        self.showSpinnerWith(title: "Cargando...")
            
        WebService.callApiWith(url: urlString, method: .post, parameter: param, header: headers, encoding: "URL", vcReff: self) { (json:[String:Any], jsonString:String, error:Error?) in
                
            self.hideSpinner()
            // print(jsonString)
                
            if error != nil
            {
                self.showAlertWithTitle(title: "Alerta", message: "\(error!.localizedDescription)", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
                
            if let AcTok:String = json["access_token"] as? String
            {
                bearerToken = AcTok
                k_userDef.setValue(AcTok, forKey: userDefaultKeys.AccessToken.rawValue)
                
                keychain.set(strEmail, forKey: "ZertuUserEmail")
                keychain.set(strPass, forKey: "ZertuUserPasscode")
                                    
                if let tok:String = json["refresh_token"] as? String
                {
                    k_userDef.setValue(tok, forKey: userDefaultKeys.RefreshToken.rawValue)
                    k_userDef.synchronize()
                        
                    DispatchQueue.main.async {
                        self.viewWillAppear(true)
                    }
                }
            }
        }
    }
}


extension HomeVC : iCarouselDataSource, iCarouselDelegate
{
    func numberOfItems(in carousel: iCarousel) -> Int {
        
        return arrImages.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {

        let coverImageUrl = arrImages[index]
        
        var itemView: UIImageView
        
        itemView = UIImageView(frame: CGRect(x: 15, y: 0, width: (UIScreen.main.bounds.width - 30), height: 165))
        itemView.backgroundColor = .white
        itemView.contentMode = .scaleAspectFit
        itemView.clipsToBounds = true
        
        itemView.image = UIImage(named: coverImageUrl)
                
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
        /*
        if index == 0
        {
            // VIDEO CELL
            
            check_SetRotateWindow = true
            
            // print(briefVideoUrl_URL)
            let player = AVPlayer(url: briefVideoUrl_URL)
            
            playerViewController = LandscapePlayer()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                self.playerViewController.player!.play()
            }
        }
        else if index == 1
        {
            DispatchQueue.main.async {
                let vc:StaticItemTapDetailVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "StaticItemTapDetailVC_ID") as! StaticItemTapDetailVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return
        }
        else if index == 2
        {
            DispatchQueue.main.async {
                let scrollPoint = CGPoint(x: 0, y: self.tblView.contentSize.height - self.tblView.frame.size.height)
                self.tblView.setContentOffset(scrollPoint, animated: true)
            }
        }
        */
        
        
        // change on 2nd sept21, earlier there were 3 index now only 2, removed 1st
        
        if index == 0
        {
            DispatchQueue.main.async {
                let vc:StaticItemTapDetailVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "StaticItemTapDetailVC_ID") as! StaticItemTapDetailVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return
        }
        else if index == 1
        {
            DispatchQueue.main.async {
                let scrollPoint = CGPoint(x: 0, y: self.tblView.contentSize.height - self.tblView.frame.size.height)
                self.tblView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
}
