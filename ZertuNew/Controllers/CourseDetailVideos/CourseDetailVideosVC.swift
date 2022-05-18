//
//  CourseDetailVideosVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 3/12/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import GTProgressBar

class CourseDetailVideosVC: UIViewController {
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    var arr_Downloads:[[String:Any]] = []
    var dictCourse:[String:Any]!
    var arr_Videos:[[String:Any]] = []
    var arr_VideoLinks: [URL] = []
    var arr_VideoIdsNeedToCompareForShuffle: [String] = []
    var strFAQ:String = ""
    var strImgCoverUrl:String = ""
    var strName = ""
    var strDescription:NSAttributedString!
    var strTitle = ""
    var RowHeightDescription:CGFloat = 0
    var arrThumbnails:[String] = []
    
    var briefVideoUrl_URL:URL!
    var briefVideoUrl_Thumbnail:String = ""
    var check_briefVideoUrl = false
    
    var check_IfWindowRotated = false
    var check_SetRotateWindow = false
    var portraitFrame:CGRect!
    
    var playerViewController:LandscapePlayer!
    var selectedUUID_playing:String = ""
    var idToRefreshList:String = ""
    var check_VideoFinishNowCallApi = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        portraitFrame = self.view.frame
        
        self.lblTitle.text = ""
        
        setUpTopBar()
        setUpDictValues() // Create Values for Faq, Desc, VideoDictArray - VideoLink - thumbnail Array, then load Table
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
    
    func setUpDictValues()
    {
        // print(dictCourse.jsonStringRepresentation!)
      //  print(dictCourse)
//
//        if let courseID:String = dictCourse["id"] as? String
//        {
//            print(courseID)
//        }
//        if let courseID:Int = dictCourse["id"] as? Int
//        {
//            print(courseID)
//        }
//
        arr_Videos.removeAll()
        arr_VideoLinks.removeAll()
        arr_Downloads.removeAll()
        arrThumbnails.removeAll()
        
        if tblView.delegate != nil
        {
            tblView.reloadData()
        }
        
        self.showSpinnerWith(title: "")
        if let str:String = dictCourse["name"] as? String
        {
            self.strName = str
        }
        if let strDesc:String = dictCourse["mobileDescription"] as? String
        {
            //  print(strDesc)
            let attributes = [NSAttributedString.Key.font: UIFont(name: CustomFont.GSLRegular, size: 20)!,
                              NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            
            self.strDescription = NSAttributedString(string: strDesc.htmlToString, attributes: attributes)
            
            //   let height = strDesc.heightWithConstrainedWidth(UIScreen.main.bounds.width - 15, font: UIFont.boldSystemFont(ofSize: 17.0))
            
            let height = self.strDescription.height(containerWidth: UIScreen.main.bounds.width - 30)
            
            RowHeightDescription = height
        }
        
        if let str:String = dictCourse["faq"] as? String
        {
            self.strFAQ = str
        }
        
        /*
         if let imgLink:String = dictCourse["coverImageUrl"] as? String
         {
         let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
         
         let strToEncode = imgLink.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
         self.strImgCoverUrl = "\(baseImgUrl)" + strToEncode!
         }
         */
        
        if let imgLink:String = dictCourse["newImageUrl"] as? String
        {
            self.strImgCoverUrl = imgLink
        }
        
        if let d_cat:[String:Any] = dictCourse["category"] as? [String:Any]
        {
            if let str:String = d_cat["name"] as? String
            {
                self.strTitle = str
            }
        }
        
        if let arrD:[[String:Any]] = dictCourse["downloads"] as? [[String:Any]]
        {
            arr_Downloads.append(contentsOf: arrD)
        }
       //  print(dictCourse)
        if let str:String = dictCourse["briefVideoUrl"] as? String
        {
            var strVideo:String = str
            
            if strVideo.contains("?")
            {
                strVideo = strVideo.components(separatedBy: "?").first!
                
                let videoID = (strVideo as NSString).lastPathComponent
                self.extractLinkFromVimeoFor_briefVideoUrl(vidID: videoID)
            }
            else
            {
                let videoID = (strVideo as NSString).lastPathComponent
                self.extractLinkFromVimeoFor_briefVideoUrl(vidID: videoID)
            }
            
            //  self.setUpVideosARRAY()  called inside closure of extractLinkFromVimeoFor_briefVideoUrl()
        }else{
            self.setUpVideosARRAY()  // if briefVideoUrl = null
        }
        
        // Migrate Code of REST OF VIDEOS inside  extractLinkFromVimeoFor_briefVideoUrl()
    }
    
    @objc func returnToMainQueue()
    {
        self.hideSpinner()
        if self.arr_Videos.count > 0
        {
            let dicT:[String:Any] = arr_Videos.first!
            self.selectedUUID_playing = dicT["uuid"] as! String
            
            print(dicT)
            if let watch:Bool = dicT["watched"] as? Bool
            {
                if watch == false{
                    self.callServerToUpdateViewedVideoAndThenRefresh()
                }
            }
        }
    }
    
    func extractLinkFromVimeo(vidID:String)
    {
        VimeoVideoExtractor.extractVideoFromVideoID(videoID: vidID, thumbQuality: .eVimeoThumb640, videoQuality: .eVimeoVideo540) { (success, videoObj) in
            //  print(success)
            // print(videoObj)
            
            if success
            {
                if videoObj != nil
                {
                    
                    print(videoObj!.videoURL)
                    if let url = URL(string: videoObj!.videoURL)
                    {
                        self.arr_VideoLinks.append(url)
                    }
                    self.arrThumbnails.append(videoObj!.thumbnailURL)
                    
                    if self.arr_Videos.count == self.arr_VideoLinks.count
                    {
                        //    reshuflle here the array links as that must hv stored the u
                        
                        //    print("LINKS - - ", self.arr_VideoLinks)
                        //             print("Ids - - ", self.arr_VideoIdsNeedToCompareForShuffle)
                        //   print("Thumbnails - ", self.arrThumbnails)
                        
                        var arrTemp_Links:[URL] = []
                        var arrTemp_Thumbs:[String] = []
                        
                        for strId in self.arr_VideoIdsNeedToCompareForShuffle
                        {
                            for index in 0..<self.arr_VideoLinks.count
                            {
                                let link:URL = self.arr_VideoLinks[index]
                                let strLink:String = link.absoluteString
                                
                                var mainStrID = strId // on Oct20, we got crash where arrTemp_Thumbs count was getting decreased by 1 because when we compare 2 ids, there is one empty space in mainStrId, so it skips that case, so we implemented this use case
                                if strId.contains(" ") == true
                                {
                                    print("ToCompare Id- \(strId) , Current ID- \(strLink)")
                                    
                                    mainStrID = mainStrID.trimmingCharacters(in: .whitespacesAndNewlines)
                                }
                                
                                //          if strLink.contains(strId.trimmingCharacters(in: .whitespacesAndNewlines)) == true
                                if strLink.contains(mainStrID) == true
                                {
                                    arrTemp_Links.append(link)
                                    arrTemp_Thumbs.append(self.arrThumbnails[index])
                                    break
                                }
                            }
                        }
                        
                        self.arr_VideoLinks = arrTemp_Links // Sorted
                        self.arrThumbnails = arrTemp_Thumbs // Sorted
                        print("LINKS Count- - ", self.arr_VideoLinks.count)
                        //         print("Thumbs - - ", self.arrThumbnails)
                        print("Thumbs Count- - ", self.arrThumbnails.count)
                        
                        DispatchQueue.main.async {
                            self.lblTitle.text = self.strTitle
                            self.tblView.delegate = self
                            self.tblView.dataSource = self
                            self.tblView.reloadData()
                        }
                    }                    
                }
                else
                {
                    print("some error occured while extraction")
                }
            }
            else
            {
                print("some error occured while extraction")
            }
        }
    }
    
    func extractLinkFromVimeoFor_briefVideoUrl(vidID:String)
    {
        VimeoVideoExtractor.extractVideoFromVideoID(videoID: vidID, thumbQuality: .eVimeoThumb640, videoQuality: .eVimeoVideo540) { (success, videoObj) in
            //
            if success
            {
                if videoObj != nil
                {
                    if let url = URL(string: videoObj!.videoURL)
                    {
                        self.briefVideoUrl_URL = url
                    }
                    self.briefVideoUrl_Thumbnail = videoObj!.thumbnailURL
                }
                else
                {
                    print("some error occured while extraction")
                }
                self.setUpVideosARRAY()
            }
            else
            {
                print("some error occured while extraction")
                self.setUpVideosARRAY()
            }
        }
    }
    
    func setUpVideosARRAY(){
        if let arr:[[String:Any]] = dictCourse["videos"] as? [[String:Any]]
        {
            self.arr_Videos = arr
            self.arr_VideoIdsNeedToCompareForShuffle = []
            //            print(self.arr_Videos.count)
            
            for index in 0..<self.arr_Videos.count
            {
                let dic:[String:Any] = self.arr_Videos[index]
                
                if let name:String = dic["name"] as? String
                {
                    //                    print("Name - - ", name)
                }
                
                if let strVidPath:String = dic["url"] as? String
                {
                    //                    print("Link - - ", strVidPath)
                    var strVideo:String = strVidPath
                    
                    if strVideo.contains("?")
                    {
                        strVideo = strVideo.components(separatedBy: "?").first!
                        
                        let videoID = (strVideo as NSString).lastPathComponent
                        self.arr_VideoIdsNeedToCompareForShuffle.append(videoID)
                        self.extractLinkFromVimeo(vidID: videoID)
                    }
                    else
                    {
                        let videoID = (strVideo as NSString).lastPathComponent
                        self.arr_VideoIdsNeedToCompareForShuffle.append(videoID)
                        // print(videoID)
                        self.extractLinkFromVimeo(vidID: videoID)
                    }
                }
                
                if index == self.arr_Videos.count - 1
                {
                    DispatchQueue.main.async {
                        self.perform(#selector(self.returnToMainQueue), with: nil, afterDelay: 2.5)
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            if self.arr_Videos.count == 0
            {
                self.hideSpinner()
                
                // self.navigationController?.popViewController(animated: true)  // changed on March 2020
                
                self.lblTitle.text = self.strTitle
                self.tblView.delegate = self
                self.tblView.dataSource = self
                self.tblView.reloadData()
            }
        }
    }
    
    @IBAction func btnBackClick(btn:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func btnLockClick(btn:UIButton)
    {
        // just Alert & do nothing
        self.showAlertWithTitle(title: "Alerta", message: "Por favor vea el video anterior en una lista para desbloquear este video", okButton: "Ok", cancelButton: "", okSelectorName: nil)
    }
    
    @objc func btn_FAQclicked(btn:UIButton)
    {
        print("Open - FAQ - ")
        
        if let img:UIImage = getScreenshot()
        {
            // META TAG WILL SET ZOOM LEVEL FOR CONTENT
            let HTML = """
            <!DOCTYPE html>
            <head>
            <meta name="viewport" content="width=device-width, shrink-to-fit=YES">
            </head>
            <html>
            <body>
            
            \(strFAQ)
            
            </body>
            </html>
            """
            
            let vc:FaqVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "FaqVC_ID") as! FaqVC
            vc.strHTML = HTML
            vc.imgWindow = img
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}

extension CourseDetailVideosVC
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

extension CourseDetailVideosVC: UITableViewDelegate, UITableViewDataSource
{
    // MARK: TableView protocols
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (self.arr_Videos.count + 1) + arr_Downloads.count + 3 // ImgHeader + Desc + Faq + (Videos + 1) with video is for briefVideoUrl(which ll always be there in all courses & if null we just make its height zero)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0
        {
            // ImageHeader
            return 260
        }
        else if indexPath.row == 1
        {
            //  briefVideoUrl   VIDEO
            
            if self.briefVideoUrl_URL == nil
            {
                return 0
            }
            return 250
        }
        else if indexPath.row == 2
        {
            // Description
            return RowHeightDescription
        }
        else if indexPath.row == 3
        {
            // FAQ-Progress
            
            if strFAQ == ""
            {
                return 90
            }
            
            return 120
        }
        else
        {
            let maxIndexpathForDownload = 3 + arr_Downloads.count // 2 is for already shown 3indexs, 0 1 2 3
            
            if arr_Downloads.count > 0
            {
                if indexPath.row <= maxIndexpathForDownload
                {
                    return 40 // for Downloads
                }
            }
            
            // Videos
            return 250
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 0
        {
            // ImageHeader
            let cell:CellCourseDetail_Header = self.tblView.dequeueReusableCell(withIdentifier: "CellCourseDetail_Header") as! CellCourseDetail_Header
            cell.selectionStyle = .none
            
            cell.imgCover.setImageUsingUrl(strImgCoverUrl)
            cell.imgCover.backgroundColor = .clear
            cell.lblName.text = strName
            
            return cell
        }
        else if indexPath.row == 1  //  briefVideoUrl  Video
        {
            let cell:CellCourseDetail_Videos = self.tblView.dequeueReusableCell(withIdentifier: "CellCourseDetail_Videos_Brief") as! CellCourseDetail_Videos
            cell.selectionStyle = .none
            
            cell.imgV_Thumbnail.image = nil
            cell.lblTitle.text = ""
            cell.btnLock.isHidden = true
            cell.imgV_Play.isHidden = false
            cell.vVideoContainer.layer.cornerRadius = 5.0
            cell.vVideoContainer.layer.masksToBounds = true
            
            cell.imgV_Play.image = nil
            cell.imgV_Play.image = UIImage(named: "play")
            //  cell.imgV_Play.layer.cornerRadius = 20.0
            //  cell.imgV_Play.layer.masksToBounds = true
            
            cell.imgV_Thumbnail.setImageUsingUrl(self.briefVideoUrl_Thumbnail)
            
            return cell
        }
        else if indexPath.row == 2
        {
            // Description
            let cell:CellCourseDetail_Description = self.tblView.dequeueReusableCell(withIdentifier: "CellCourseDetail_Description") as! CellCourseDetail_Description
            cell.selectionStyle = .none
            
            cell.lblDesc.attributedText = strDescription
            
            return cell
        }
        else if indexPath.row == 3
        {
            // FAQ-Progress
            let cell:CellCourseDetail_FaqProgress = self.tblView.dequeueReusableCell(withIdentifier: "CellCourseDetail_FaqProgress") as! CellCourseDetail_FaqProgress
            cell.selectionStyle = .none
            
            cell.btnFaq.layer.cornerRadius = 5.0
            cell.btnFaq.layer.borderColor = UIColor.black.cgColor
            cell.btnFaq.layer.borderWidth = 0.3
            cell.btnFaq.addTarget(self, action: #selector(self.btn_FAQclicked(btn:)), for: .touchUpInside)
            
            cell.c_BtnFaq_Ht.constant = 30
            if strFAQ == ""
            {
                cell.c_BtnFaq_Ht.constant = 0
            }
            
            /////////////////////
            cell.lblProgress.text = "Avance %"
            /////////////////////
            
            cell.lblAvailableSession.isHidden = false
            if self.arr_Videos.count == 0
            {
                cell.lblAvailableSession.isHidden = true
            }
            
            var totalVideosCount:Float = 0.0
            var watchedVideos:Float = 0.0
            
            if let videosNotWatched:Int = dictCourse["totalVideosNotWatched"] as? Int
            {
                if let videosWatched:Int = dictCourse["totalVideosWatched"] as? Int
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
                cell.lblProgress.text = "Avance \(strValue.components(separatedBy: ".").first!)%"
            }
            
            cell.progressBar.barBorderColor = UIColor.colorWithHexString("8a2be2")
            cell.progressBar.barFillColor = k_baseColor
            cell.progressBar.barBackgroundColor = UIColor.colorWithHexString("d3d3d3") // gray
            cell.progressBar.barBorderWidth = 0.5
            cell.progressBar.displayLabel = false
            
            
            return cell
        }
        else
        {
            let maxIndexpathForDownload = 3 + arr_Downloads.count // 3 is for already shown 3indexs, 0 1 2 3
            
            //  print(arr_Downloads)
            if arr_Downloads.count > 0
            {
                if indexPath.row <= maxIndexpathForDownload
                {
                    // for Downloads
                    let cell:Cell_Course_DetailDownload = tblView.dequeueReusableCell(withIdentifier: "Cell_Course_DetailDownload", for: indexPath) as! Cell_Course_DetailDownload
                    cell.selectionStyle = .none
                    
                    let dictDown:[String:Any] = arr_Downloads[indexPath.row - 4]
                    var name:String = ""
                    var urlDown:String = ""
                    
                    if let nam:String = dictDown["name"] as? String
                    {
                        name = nam
                    }
                    if let ur:String = dictDown["url"] as? String
                    {
                        urlDown = ur
                    }
                    //   cell.lbl_MastersTitle.isHidden = true
                    cell.btnDownload.tag = indexPath.row
                    cell.btnDownload.layer.cornerRadius = 5
                    cell.btnDownload.layer.borderWidth = 0.6
                    cell.btnDownload.layer.backgroundColor = k_baseColor.cgColor
                    cell.btnDownload.setTitleColor(UIColor.white, for: .normal)
                    cell.btnDownload.layer.masksToBounds = true
                    
                    cell.btnDownload.setTitle(name, for: .normal)
                    cell.btnDownload.downloadUrl = urlDown
                    cell.btnDownload.addTarget(self, action: #selector(self.btn_DownloadClick(btn:)), for: .touchUpInside)
                    
                    return cell
                }
            }
            
            // Videos
            print(self.arr_Videos.count)
            print(self.arrThumbnails.count)
            let ind = (indexPath.row - arr_Downloads.count) - 4 // 4 for first 4 rows(img, desc, faq & briefVideoUrl)
            let dicVideo:[String:Any] = self.arr_Videos[ind]
            
            let cell:CellCourseDetail_Videos = self.tblView.dequeueReusableCell(withIdentifier: "CellCourseDetail_Videos") as! CellCourseDetail_Videos
            cell.selectionStyle = .none
            
            cell.lblTitle.text = ""
            cell.btnLock.isHidden = false
            cell.imgV_Play.isHidden = true
            cell.vVideoContainer.layer.cornerRadius = 5.0
            cell.vVideoContainer.layer.masksToBounds = true
            
            cell.imgV_Play.image = nil
            cell.imgV_Play.image = UIImage(named: "play")
            //  cell.imgV_Play.layer.cornerRadius = 20.0
            //  cell.imgV_Play.layer.masksToBounds = true
            
            if let strTitle:String = dicVideo["name"] as? String
            {
                cell.lblTitle.text = strTitle
            }
            
            //cell.btnLock.tag = indexPath.row - 3
            cell.btnLock.addTarget(self, action: #selector(self.btnLockClick(btn:)), for: .touchUpInside)
            
            if let watch:Bool = dicVideo["watched"] as? Bool
            {
                if watch == true{
                    cell.btnLock.isHidden = true
                    cell.imgV_Play.isHidden = false
                }
            }
            
            let linkThumbnail:String = self.arrThumbnails[ind]
            cell.imgV_Thumbnail.setImageUsingUrl(linkThumbnail)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.row != 0 && indexPath.row != 1 && indexPath.row != 2 && indexPath.row != 3
        {
            // Tapped Videos Only to Play
            
            let ind = indexPath.row - arr_Downloads.count - 4 // 4 for first 4 rows(img, desc, faq & briefVideoUrl)
            
            let dicVideo:[String:Any] = self.arr_Videos[ind]
            let linkToPlay:URL = self.arr_VideoLinks[ind]
            
            if let uuid:String = dicVideo["uuid"] as? String
            {
                print("- -Current UUid Tapped - - ", uuid)
                print(" - - - PLAY Video - - - - ")
                print(indexPath.row)
                print(arr_Videos.count)
                print(arr_Downloads.count)
                
                if self.arr_Videos.count - 1 != ind
                {
                    if let dicNextVideoToUnlock:[String:Any] = self.arr_Videos[(indexPath.row + 1) - arr_Downloads.count - 4] as? [String:Any]
                    {
                        if let nextuuid:String = dicNextVideoToUnlock["uuid"] as? String
                        {
                            self.selectedUUID_playing = "Do Not Call Api For This, As this is already unlocked"
                            
                            if let watch:Bool = dicNextVideoToUnlock["watched"] as? Bool
                            {
                                if watch == false{
                                    self.selectedUUID_playing = nextuuid
                                }
                            }
                            
                            print("- -   NEXT UUid Tapped - - ", nextuuid)
                        }
                        
                    }
                }
                else
                {
                    // if ind is equal then its a last item in array i.e. last Video
                    self.selectedUUID_playing = "Do Not Call Api For This, As this is already unlocked"
                }
                
                check_SetRotateWindow = true
                
                let player = AVPlayer(url: linkToPlay)
                
                NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                
                playerViewController = LandscapePlayer()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    self.playerViewController.player!.play()
                }
                
            }
        }
        else if indexPath.row == 1  //  briefVideoUrl  Video
        {
            check_SetRotateWindow = true
            
            let player = AVPlayer(url: briefVideoUrl_URL)
            
            playerViewController = LandscapePlayer()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                self.playerViewController.player!.play()
            }
        }
    }
    
    @objc func btn_DownloadClick(btn:ButtonDownload)
    {
        print(btn.downloadUrl)
        guard let url = URL(string: btn.downloadUrl) else {
            return //be safe
        }
        UIApplication.shared.open(url, options: [:])
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        
        print("- - - - - - - - -    Finish - - uuid > ", self.selectedUUID_playing)
        
        check_VideoFinishNowCallApi = true
        
        self.playerViewController.dismiss(animated: true, completion: nil)
        playerViewController = nil
        NotificationCenter.default.removeObserver(self)
        
        DispatchQueue.main.async {
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("- > > > > Handle FORCE ROTATION - - - - - - - ")
        
        if check_IfWindowRotated == true
        {
            self.view.rotate(angle: -90)
            check_IfWindowRotated = false
            self.view.frame = portraitFrame
            
            if check_VideoFinishNowCallApi == true
            {
                check_VideoFinishNowCallApi = false
                DispatchQueue.main.async {
                    self.perform(#selector(self.callServerToUpdateViewedVideoAndThenRefresh), with: nil, afterDelay: 0.5)
                }
            }
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if check_SetRotateWindow == true
        {
            check_SetRotateWindow = false
            check_IfWindowRotated = true
            self.view.rotate(angle: 90)
        }
    }
}

extension CourseDetailVideosVC
{
    @objc func callServerToUpdateViewedVideoAndThenRefresh()
    {
        if self.selectedUUID_playing == "Do Not Call Api For This, As this is already unlocked"
        {
            return
        }
        
        self.showSpinnerWith(title: "Cargando...")
        let urlStr = serviceName.PostVideoViewed.rawValue
        let param:[String:Any] = ["videoUuid":self.selectedUUID_playing]
        let headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        
        WebService.callApiWith(url: urlStr, method: .post, parameter: param, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
                print(jsonStr)
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
                    if let msg:String = json["response"] as? String
                    {
                        print("Video Updated as Watched, with \(self.selectedUUID_playing) - \n", msg)
                        DispatchQueue.main.async {
                            // REFRESH THE LIST AGAIN
                            self.getCourseDetailAgainAndrefreshList()
                            return
                        }
                    }
                }
            }
            
            if let _:String = json["error500"] as? String
            {
                // this is coming when we play already watched video and in its end then again call api
                // self.showAlertWithTitle(title: "Alerta", message: "Ocurrió algún error, intente nuevamente después de algún tiempo", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                return
            }
        }
    }
    
    func getCourseDetailAgainAndrefreshList()
    {
        self.showSpinnerWith(title: "Cargando...")
        let url2Pass = serviceName.GetSelectedCourse.rawValue + idToRefreshList
        let header:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
        WebService.callApiWith(url: url2Pass, method: .get, parameter: nil, header: header, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonString:String, error:Error?) in
            
            self.hideSpinner()
            // print(jsonString)
            
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
                        self.dictCourse = rootDict
                        DispatchQueue.main.async {
                            self.setUpDictValues()
                        }
                    }
                }
            }
        }
    }
}
