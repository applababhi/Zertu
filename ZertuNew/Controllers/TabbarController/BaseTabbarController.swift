//
//  BaseTabbarController.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 19/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit

// Just set the TabrBar of UITabBarController in Storyboard to class "RollingPitTabBar"

class BaseTabbarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        self.selectedIndex = 1 // Home
        
        UITabBar.appearance().tintColor = UIColor.white // selected Tab Color
        self.tabBar.unselectedItemTintColor = UIColor.white // UnSelected Tab Color
        
        // change font for TabItem
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "STHeitiTC-Medium", size: 12)!], for: .normal)
        
        // for equal spacing between Tabs
        tabBar.itemPositioning = .fill
        
        // from below 2 lines we can remove the LINE which comes on top of TabBar
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true

        setUpTitleInBottomBar()
    }
    
    func setUpTitleInBottomBar()
    {
        // in this app, we are basically moving titles very down, which ll not be visible, and only appear on Tap, as 3rd party Lib, on selection raise the imaage and Title
        
        let strModel = getDeviceModel()
        if strModel == "iPhone XS"
        {
            UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 17.5) // Change Position of title
        }
        else if strModel == "iPhone Max"
        {
            UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 17.5) // Change Position of title
        }
        else if strModel == "iPhone 6+"
        {
            UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 20) // Change Position of title
        }
        else if strModel == "iPhone 6"
        {
            UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 20) // Change Position of title
        }
        else if strModel == "iPhone 5"
        {
            UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 22) // Change Position of title
        }
        else if strModel == "iPhone XR"
        {
            UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 17.5) // Change Position of title
        }
    }
    
    //MARK: Delegate methods
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    {
        if viewController is UINavigationController
        {
            // let vc:UIViewController = ((viewController as? UINavigationController)?.viewControllers.first!)!
        }
        
        return true;
    }
}

extension BaseTabbarController
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
