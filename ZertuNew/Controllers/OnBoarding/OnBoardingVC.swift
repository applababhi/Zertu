//
//  OnBoardingVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 19/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit

class OnBoardingVC: UIViewController {

    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var btnSkip:UIButton!
    @IBOutlet weak var btnNext:UIButton!
    
    @IBOutlet weak var vSkip:UIView!
    @IBOutlet weak var vNext:UIView!
    
    var pageContReff:OnBoardingPageVC!
        
    var currentScreenIndex: Int = 1
    let numberOfScreens = 3

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
        let btnCornerRadius = vNext.frame.size.height/2.0
        vSkip.layer.cornerRadius = btnCornerRadius
        vNext.layer.cornerRadius = btnCornerRadius
        
        loadPageVC()
    }
    
    func setupConstraints()
    {
        let strModel = getDeviceModel()
        if strModel == "iPhone XS"
        {

        }
        else if strModel == "iPhone Max"
        {

        }
        else if strModel == "iPhone 6+"
        {

        }
        else if strModel == "iPhone 6"
        {

        }
        else if strModel == "iPhone 5"
        {

        }
        else if strModel == "iPhone XR"
        {

        }
    }
    
    func loadPageVC()
    {
        let controller: OnBoardingPageVC = AppStoryboards.OnBoarding.instance.instantiateViewController(withIdentifier: "OnBoardingPageVC_ID") as! OnBoardingPageVC
        pageContReff = controller
        addChild(controller)
        controller.view.frame = vwContainer.frame
        vwContainer.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    @IBAction func nextBtn_Click(btn:UIButton)
    {
        print(currentScreenIndex)
        
        if currentScreenIndex != numberOfScreens
        {
            currentScreenIndex = currentScreenIndex + 1
        }
        else
        {
            currentScreenIndex = numberOfScreens
          
            k_userDef.setValue("Done", forKey: userDefaultKeys.onBoardingShown.rawValue)
            k_userDef.synchronize()

            // Take to Login
            let vc:LoginVC = AppStoryboards.Login.instance.instantiateViewController(withIdentifier: "LoginVC_ID") as! LoginVC
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
        
        pageContReff.toNextScene()
    }
    
    @IBAction func skipBtn_Click(btn:UIButton)
    {
        k_userDef.setValue("Done", forKey: userDefaultKeys.onBoardingShown.rawValue)
        k_userDef.synchronize()

        let vc:LoginVC = AppStoryboards.Login.instance.instantiateViewController(withIdentifier: "LoginVC_ID") as! LoginVC
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

extension OnBoardingVC
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
