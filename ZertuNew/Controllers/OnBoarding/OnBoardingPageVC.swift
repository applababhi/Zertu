//
//  OnBoardingPageVC.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 19/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit

class OnBoardingPageVC: UIPageViewController {
    fileprivate var items: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        self.isPagingEnabled = false  // To Stop SwipeGesture Scrolling
        
        decoratePageControl()
        
        populateItems()
        if let firstViewController = items.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    fileprivate func decoratePageControl() {
        let pc = UIPageControl.appearance(whenContainedInInstancesOf: [OnBoardingPageVC.self])
        pc.currentPageIndicatorTintColor = .white
        pc.pageIndicatorTintColor = .gray
    }
    
    fileprivate func populateItems()
    {
        let textArr = ["Bienvenido a Zertú", "Bienvenido a Zertú", "Bienvenido a Zertú"]
        
        let descArr = ["ZERTÚ es una PLATAFORMA de BIENESTAR INTEGRAL que promueve prácticas energéticas con una metodología que te permite ZERTÚ MEJOR VERSIÓN", "A través del poder energético de los alimentos puedes sanar tus emociones desde la raíz, eliminando bloqueos energéticos que muchas veces te ocasionan malestares y enfermedades.", "Los cuarzos son minerales que al ser energizados funcionan como una herramienta para lograr todo aquello que deseas. En el taller “Alinea tu energía a través de los cuarzos” aprenderás a elegir, limpiar, alimentar y energizar tu propio cuarzo."]
        
        
        for (index, txt) in textArr.enumerated() {
            let des:String = descArr[index]
            let c = createOnboardingScenesControler(with: txt, with: des)
            items.append(c)
        }
    }
    
    fileprivate func createOnboardingScenesControler(with titleText: String, with descText: String) -> UIViewController {
        let c = UIViewController()
        c.view = OnboardingScenes(titleText: titleText, strDesc: descText)
        
        return c
    }
}

extension OnBoardingPageVC
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

// MARK: - DataSource

extension OnBoardingPageVC: UIPageViewControllerDataSource
{
    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = items.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            // return items.last  // For Infinte Scroll
            return nil
        }
        
        guard items.count > previousIndex else {
            return nil
        }
        
        return items[previousIndex]
    }
    
    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = items.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        guard items.count != nextIndex else {
           // return items.first   // For Infinte Scroll
            return nil
        }
        
        guard items.count > nextIndex else {
            return nil
        }
        
        return items[nextIndex]
    }
    
    func presentationCount(for _: UIPageViewController) -> Int {
        return items.count
    }
    
    func presentationIndex(for _: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = items.firstIndex(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
}

extension OnBoardingPageVC
{
    // Functions for clicking next and previous in the navbar, Updated for swift 4
    @objc func toNextScene(){
        guard let currentViewController = self.viewControllers?.first else { return }
        
        guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
        
        // Has to be set like this, since else the delgates for the buttons won't work
        setViewControllers([nextViewController], direction: .forward, animated: true, completion: { completed in self.delegate?.pageViewController?(self, didFinishAnimating: true, previousViewControllers: [], transitionCompleted: completed) })
    }
    
    @objc func toPreviousScene(){
        guard let currentViewController = self.viewControllers?.first else { return }
        
        guard let previousViewController = dataSource?.pageViewController( self, viewControllerBefore: currentViewController ) else { return }
        
        // Has to be set like this, since else the delgates for the buttons won't work
        setViewControllers([previousViewController], direction: .reverse, animated: true, completion:{ completed in self.delegate?.pageViewController?(self, didFinishAnimating: true, previousViewControllers: [], transitionCompleted: completed) })
    }

}

extension UIPageViewController {
    var isPagingEnabled: Bool {
        get {
            var isEnabled: Bool = true
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    isEnabled = subView.isScrollEnabled
                }
            }
            return isEnabled
        }
        set {
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    subView.isScrollEnabled = newValue
                }
            }
        }
    }
}
