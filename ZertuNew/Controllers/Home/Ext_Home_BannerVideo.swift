//
//  Ext_Home_BannerVideo.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 26/3/21.
//  Copyright © 2021 Shalini Sharma. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

extension HomeVC
{
    override func viewWillDisappear(_ animated: Bool) {
        
        print("- - here Dismiss the Floating Button - -")
        floaty.close()
        
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
