//
//  ModuleDetailVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 8/2/21.
//  Copyright © 2021 Shalini Sharma. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ModuleDetailVC: UIViewController {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnBack:UIImageView!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    var strTitle = ""
    
    var arr_Questions:[[String:Any]] = []
    var arr_Answers:[[String:Any]] = []
    
    var dictMain:[String:Any] = [:]
    var arr_ModuleID:[String] = []
    var currentID = ""
        
    var strDescription:NSAttributedString!
    var RowHeightDescription:CGFloat = 0
    
    var briefVideoUrl_URL:URL!
    var briefVideoUrl_Thumbnail:String = ""
    
    var check_IfWindowRotated = false
    var check_SetRotateWindow = false
    var portraitFrame:CGRect!
    var playerViewController:LandscapePlayer!
    
    var showEvaluationRow = false
    
    var reffStaticVC:StaticItemTapDetailVC!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        portraitFrame = self.view.frame
        
        setUpTopBar()
        
        lblTitle.text = ""
        btnBack.setImageColor(color: UIColor.black)
        
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.estimatedRowHeight = 90
        self.tblView.rowHeight = UITableView.automaticDimension
        
        setupData()
    }
    
    func setupData()
    {
        if let strTitle1:String = dictMain["titulo"] as? String
        {
            if let strTitle2:String = dictMain["nombre"] as? String
            {
                self.strTitle = strTitle1 + " " + strTitle2
            }
            else{
                self.strTitle = strTitle1
            }            
        }
        
        if let ar:[[String:Any]] = dictMain["videos"] as? [[String:Any]]
        {
            if ar.count > 0
            {
                let df:[String:Any] = ar.first!
                
                if let str:String = df["url"] as? String
                {
                    var strVideo:String = str
                    
                    if strVideo.contains("?")
                    {
                        strVideo = strVideo.components(separatedBy: "?").first!
                        
                        let videoID = (strVideo as NSString).lastPathComponent
                        self.extractLinkFromVimeo(vidID: videoID)
                    }
                    else
                    {
                        let videoID = (strVideo as NSString).lastPathComponent
                        self.extractLinkFromVimeo(vidID: videoID)
                    }
                }
            }
        }
        
        if let strDes:String = dictMain["descripcion"] as? String
        {
            let attributes = [NSAttributedString.Key.font: UIFont(name: CustomFont.GSLRegular, size: 22)!,
                              NSAttributedString.Key.foregroundColor: UIColor.darkGray]

            self.strDescription = NSAttributedString(string: strDes.htmlToString, attributes: attributes)
            
            let height = strDes.heightWithConstrainedWidth(UIScreen.main.bounds.width - 15, font: UIFont.boldSystemFont(ofSize: 18.0))
            self.RowHeightDescription = height! // + 40
        }
        
        if let check:Bool = dictMain["aprobado"] as? Bool
        {
            
        }
        
        if let ar:[[String:Any]] = dictMain["respuestasDelUsuario"] as? [[String:Any]]
        {
            self.arr_Answers = ar
            
            if ar.count > 0
            {
                showEvaluationRow = true
            }
        }
        
        if let ar:[[String:Any]] = dictMain["preguntas"] as? [[String:Any]]
        {
            self.arr_Questions = ar
            
            // Adding "selected" key to all answers
            for index in 0..<arr_Questions.count
            {
                var d:[String:Any] = arr_Questions[index]
                var arrAns:[[String:Any]] = []
                if let arr:[[String:Any]] = d["respuestas"] as? [[String:Any]]
                {
                    for ind in 0..<arr.count
                    {
                        var dA:[String:Any] = arr[ind]
                        dA["selected"] = false
                        arrAns.append(dA)
                    }
                }
                d["respuestas"] = arrAns
                
                self.arr_Questions[index] = d
            }
        }
        
        self.tblView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if check_SetRotateWindow == true
        {
            check_SetRotateWindow = false
            check_IfWindowRotated = true
            self.view.rotate(angle: 90)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("- > > > > Handle FORCE ROTATION - - - - - - - ")
        if check_IfWindowRotated == true
        {
            self.view.rotate(angle: -90)
            check_IfWindowRotated = false
            self.view.frame = portraitFrame
        }
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
        self.navigationController?.popToViewController(reffStaticVC, animated: true)
    }
    
    func extractLinkFromVimeo(vidID:String)
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
                    DispatchQueue.main.async {
                        self.tblView.reloadData()
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
}

extension ModuleDetailVC
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

extension ModuleDetailVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0
        {
            // title
            return UITableView.automaticDimension
        }
        else if indexPath.row == 1
        {
            // Video
            return 210
        }
        else if indexPath.row == 2
        {
            // Description
            return RowHeightDescription
        }
        else
        {
            return 180
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        if indexPath.row == 0
        {
            // title
            let cell:CellShoppingDetail_Label = self.tblView.dequeueReusableCell(withIdentifier: "CellShoppingDetail_Label") as! CellShoppingDetail_Label
            cell.selectionStyle = .none
            cell.lblTitle.text = ""
            cell.lblTitle.textColor = .darkGray

            cell.lblTitle.text = strTitle
            return cell
        }
        else if indexPath.row == 1
        {
            // Video
            let cell:CellCourseDetail_Videos = self.tblView.dequeueReusableCell(withIdentifier: "CellCourseDetail_Videos") as! CellCourseDetail_Videos
            cell.selectionStyle = .none
            
            cell.imgV_Thumbnail.image = nil
            cell.imgV_Play.isHidden = false
            cell.vVideoContainer.layer.cornerRadius = 5.0
            cell.vVideoContainer.layer.masksToBounds = true
            cell.imgV_Play.image = nil
            cell.imgV_Play.image = UIImage(named: "play")
                        
            DispatchQueue.main.async {
                cell.imgV_Thumbnail.setImageUsingUrl(self.briefVideoUrl_Thumbnail)
            }
            
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
        else
        {
           let cell:CellModuleEvaluation = self.tblView.dequeueReusableCell(withIdentifier: "CellModuleEvaluation") as! CellModuleEvaluation
                cell.selectionStyle = .none
            cell.btnBottom.isHidden = false
            
            if showEvaluationRow == true
            {
                // show Answers
                cell.btnTop.setTitle("VER MIS RESPUESTAS", for: .normal)
            }
            else
            {
                // take questionarie
                cell.btnTop.setTitle("Evaluar", for: .normal)
            }
                
            cell.btnBottom.setTitle("Siguiente Módulo", for: .normal)
            
            cell.btnTop.layer.cornerRadius = 5.0
            cell.btnTop.layer.masksToBounds = true
            
            cell.btnBottom.layer.cornerRadius = 5.0
            cell.btnBottom.layer.masksToBounds = true
            
            cell.btnTop.addTarget(self, action: #selector(self.btnTopClick(btn:)), for: .touchUpInside)
            cell.btnBottom.addTarget(self, action: #selector(self.btnBottomClick(btn:)), for: .touchUpInside)
            
            if showEvaluationRow == false
            {
                cell.btnBottom.isHidden = true
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1
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
    }
    
    @objc func btnTopClick(btn:UIButton)
    {
        if showEvaluationRow == true
        {
            // show Answers
            
          // print(arr_Answers)
            DispatchQueue.main.async {
                let vc:ShowAnswersVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "ShowAnswersVC_ID") as! ShowAnswersVC
                vc.arr_Answers = self.arr_Answers
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else
        {
            // take questionarie
            DispatchQueue.main.async {
                let vc:ShowQuestionVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "ShowQuestionVC_ID") as! ShowQuestionVC
                vc.arr_Questions = self.arr_Questions
                vc.reffStaticVC = self.reffStaticVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func btnBottomClick(btn:UIButton)
    {
        // take to Next Module
        print("Current ID: ", currentID)
        print("- - - - -")
        var nextID = ""
        for index in 0..<arr_ModuleID.count
        {
            let str:String = arr_ModuleID[index]
            if str == currentID && index != (arr_ModuleID.count - 1)
            {
                let nextStr_ID:String = arr_ModuleID[index + 1]
                nextID = nextStr_ID
                print("Next ID: ", nextID)
                
                callGetDetailModule(id: nextID)
                break
            }
        }
    }
}

extension ModuleDetailVC
{
    func callGetDetailModule(id:String)
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.GetModuleDetail.rawValue + id
        var headers:[String:String] = ["Content-Type":"application/json", "Authorization" : "Bearer \(bearerToken)"]
      
        if isUserTappedSkipButton == true{
            headers = ["Content-Type":"application/json"]
        }
        
        WebService.callApiWith(url: urlStr, method: .get, parameter: nil, header: headers, encoding: "JSON", vcReff: self) { (json:[String:Any], jsonStr:String, error:Error?) in
          //  print(jsonStr)
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
                    if let Dd_main:[String:Any] = json["response"] as? [String:Any]
                    {
                     
                        DispatchQueue.main.async {
                            let vc:ModuleDetailVC = AppStoryboards.Home.instance.instantiateViewController(identifier: "ModuleDetailVC_ID") as! ModuleDetailVC
                            vc.currentID = id
                            vc.arr_ModuleID = self.arr_ModuleID
                            vc.dictMain = Dd_main
                            vc.reffStaticVC = self.reffStaticVC
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
        }
    }
}
