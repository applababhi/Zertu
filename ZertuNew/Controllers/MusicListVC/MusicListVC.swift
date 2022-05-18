//
//  MusicListVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 31/12/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit
import SwiftAudio
import AVFoundation
import MediaPlayer

class MusicListVC: UIViewController {

    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    
    var arrMusicList:[[String:Any]] = []
    let audioPlayer = AudioPlayer()
    
    var refCell:CellMusicList!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblView.dataSource = self
        self.tblView.delegate = self
        setUpTopBar()
        setupAudioPlayer()
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
        else
        {
            // UNKNOWN CASE - Like iPhone 11 or XR
            c_TopBar_Ht.constant = 90
        }
    }
    
    func setupAudioPlayer()
    {
        // To listen for events in the AudioPlayer, subscribe to events found in the event property of the AudioPlayer
        
        audioPlayer.event.stateChange.addListener(self, handleAudioPlayerStateChange)
        audioPlayer.event.secondElapse.addListener(self, handleAudioPlayerSecondElapsed)
        audioPlayer.event.seek.addListener(self, handleAudioPlayerDidSeek)
        audioPlayer.event.updateDuration.addListener(self, handleAudioPlayerUpdateDuration)
        audioPlayer.event.fail.addListener(self, handlePlayerFailure)
        
        audioPlayer.remoteCommands = [
            .stop,
            .play,
            .pause,
            .togglePlayPause,
            .skipForward(preferredIntervals: [30]),
            .skipBackward(preferredIntervals: [30]),
            .changePlaybackPosition
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        callGetMusicList()
    }
    
    deinit {
        if audioPlayer.playerState == .playing
        {
            audioPlayer.stop()
        }
        if refCell != nil
        {
            refCell = nil
        }
    }    
    
    @IBAction func btnBackClick(btn:UIButton)
    {
        if audioPlayer.playerState == .playing
        {
            audioPlayer.stop()
        }
        if refCell != nil
        {
            refCell = nil
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension MusicListVC
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

extension MusicListVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrMusicList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict:[String:Any] = arrMusicList[indexPath.row]
        let cell:CellMusicList = tblView.dequeueReusableCell(withIdentifier: "CellMusicList", for: indexPath) as! CellMusicList
        cell.selectionStyle = .none
        cell.tag = indexPath.row
        cell.playButton.tag = indexPath.row
        
        cell.vBk.layer.cornerRadius = 5.0
        cell.vBk.layer.borderColor = UIColor.darkGray.cgColor
        cell.vBk.layer.borderWidth = 0.5
        cell.vBk.layer.masksToBounds = true
        cell.titleLabel.text = ""
        cell.imgView.image = nil
        cell.elapsedTimeLabel.text = "--:--"
        cell.remainingTimeLabel.text = "--:--"
        cell.playButton.setImage(UIImage(named: "playW"), for: .normal)
        
        if let str:String = dict["title"] as? String{
            cell.titleLabel.text = str
        }
        
        if refCell != nil
        {
            if cell.tag == refCell.tag
            {
                if audioPlayer.playerState == .playing
                {
                    cell.playButton.setImage(UIImage(named: "pauseW"), for: .normal)
                }
                else
                {
                    cell.playButton.setImage(UIImage(named: "playW"), for: .normal)
                }
            }
        }
                
        cell.playButton.addTarget(self, action: #selector(self.togglePlay(btn:)), for: .touchUpInside)
        cell.slider.addTarget(self, action: #selector(self.scrubbingValueChanged(_:)), for: .valueChanged)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    @objc func togglePlay(btn: UIButton)
    {
        let indexPath = IndexPath(row: btn.tag, section: 0)
        let cell:CellMusicList = tblView.cellForRow(at: indexPath) as! CellMusicList
        
        var strURL = ""
        let dict:[String:Any] = arrMusicList[btn.tag]
        if let url:String = dict["url"] as? String{
            strURL = url
        }
        
        if refCell != nil
        {
            if cell.tag == refCell.tag
            {
                // Current CELL Playing Audio
                
                if audioPlayer.playerState == .playing
                {
                    audioPlayer.pause()
                    if refCell != nil
                    {
                        refCell.playButton.setImage(UIImage(named: "playW"), for: .normal)
                    }
                }
                else if audioPlayer.playerState == .paused
                {
                    audioPlayer.play()
                    if refCell != nil
                    {
                        refCell.playButton.setImage(UIImage(named: "pauseW"), for: .normal)
                    }
                }
                else if audioPlayer.playerState == .ready
                {
                    audioPlayer.play()
                  if refCell != nil
                  {
                      refCell.playButton.setImage(UIImage(named: "pauseW"), for: .normal)
                  }
                }
                else if audioPlayer.playerState == .idle
                {
                    let audioItem = DefaultAudioItem(audioUrl: strURL, sourceType: .stream)
                    try? audioPlayer.load(item: audioItem, playWhenReady: false) // Load the item and start playing when the player is ready.

                    refCell.playButton.setImage(UIImage(named: "playW"), for: .normal)
                }
            }
            else
            {
                // first stop already playing player then assign new
                audioPlayer.stop()
                refCell.playButton.setImage(UIImage(named: "playW"), for: .normal)
                refCell.slider.value = 0 // make slider value = 0, so that it don't show slider value for previous when u tap next play
                refCell.elapsedTimeLabel.text = "--:--"
                refCell.remainingTimeLabel.text = "--:--"

                refCell = nil
                
                refCell = cell
                let audioItem = DefaultAudioItem(audioUrl: strURL, sourceType: .stream)
                try? audioPlayer.load(item: audioItem, playWhenReady: true) // Load the item and start playing when the player is ready.

                refCell.playButton.setImage(UIImage(named: "pauseW"), for: .normal)
            }
        }
        else
        {
            refCell = cell
            let audioItem = DefaultAudioItem(audioUrl: strURL, sourceType: .stream)
            try? audioPlayer.load(item: audioItem, playWhenReady: true) // Load the item and start playing when the player is ready.

            refCell.playButton.setImage(UIImage(named: "pauseW"), for: .normal)
        }
        
        
        

        
        
        
        
    }
    
    @objc func scrubbingValueChanged(_ sender: UISlider) {
        let value = Double(sender.value)
        if refCell != nil
        {
            refCell.elapsedTimeLabel.text = value.secondsToString()
            refCell.remainingTimeLabel.text = (audioPlayer.duration - value).secondsToString()
        }
        audioPlayer.seek(to: Double(sender.value))
    }
}

//MARK: AudioPlayer Events

extension MusicListVC
{
    func updateTimeValues() {
        if refCell != nil
        {
            refCell.slider.maximumValue = Float(self.audioPlayer.duration)
            refCell.slider.setValue(Float(self.audioPlayer.currentTime), animated: true)
            refCell.elapsedTimeLabel.text = self.audioPlayer.currentTime.secondsToString()
            refCell.remainingTimeLabel.text = (self.audioPlayer.duration - self.audioPlayer.currentTime).secondsToString()
        }
    }
    
    func handleAudioPlayerStateChange(data: AudioPlayer.StateChangeEventData) {
        print(data)
        DispatchQueue.main.async {

            switch data {
            case .loading:
                self.showSpinnerWith(title: "")
                self.updateTimeValues()
            case .buffering:
                self.showSpinnerWith(title: "")
            case .ready:
                self.hideSpinner()
                self.updateTimeValues()
            case .playing, .paused, .idle:
                self.hideSpinner()
                self.updateTimeValues()
            }
        }
    }
    
    func handleAudioPlayerSecondElapsed(data: AudioPlayer.SecondElapseEventData) {
        DispatchQueue.main.async {
            self.updateTimeValues()
        }
    }
    
    func handleAudioPlayerDidSeek(data: AudioPlayer.SeekEventData) {

    }
    
    func handleAudioPlayerUpdateDuration(data: AudioPlayer.UpdateDurationEventData) {
        DispatchQueue.main.async {
            self.updateTimeValues()
        }
    }
        
    func handlePlayerFailure(data: AudioPlayer.FailEventData) {
        if let error = data as NSError? {
            if error.code == -1009 {
                DispatchQueue.main.async {
                    self.hideSpinner()
                    print("Network disconnected. Please try again...")
                }
            }
        }
    }
}

extension MusicListVC
{
    func callGetMusicList()
    {
        self.showSpinnerWith(title: "Cargando...")
        
        let urlStr = serviceName.GetMusicList.rawValue
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

            self.arrMusicList.removeAll()
            if let code:Int = json["code"] as? Int
            {
                if code >= 200 && code < 300
                {
                    if let arrItems:[[String:Any]] = json["response"] as? [[String:Any]]
                    {
                        self.arrMusicList = arrItems
                        
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
