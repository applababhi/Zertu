//
//  ShowPDFVC.swift//
//  Created by Abhishek Visa on 3/7/19.
//  Copyright © 2019 Shalini. All rights reserved.
//

import UIKit
import WebKit

class ShowPDFVC: UIViewController {
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var c_TopBar_Ht:NSLayoutConstraint!
    @IBOutlet weak var btnShare:UIButton!
    var webView: WKWebView!
    @IBOutlet weak var viewWeb:UIView!

    var strTitle = ""
    var pdfFilePath = ""
    
    var strExtension = ""
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTopBar()
        clearTempFolderDocDirectory()        
        
        lblTitle.text = strTitle
        strExtension = pdfFilePath.components(separatedBy: ".").last!
        // self.perform(#selector(self.loadWebV), with: nil, afterDelay: 0.2)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadWebV()
    }
    
    @IBAction func btnBackClick(btn:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func loadWebV()
    {
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: viewWeb.frame.size.width, height: viewWeb.frame.size.height))
        
        self.webView.navigationDelegate = self
        print("- - - - - - - - - - - - - - - - - - - - - - - - - - ")
        print(pdfFilePath)
        print("- - - - - - - - - - - - - - - - - - - - - - - - - - ")
                
        let encodedPath = pdfFilePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        print(encodedPath)
        //        let pdfFilePath = "http://www.fao.org/3/i2469e/i2469e00.pdf"
        let urlRequest = URLRequest.init(url: URL(string: encodedPath!)!)
        webView.load(urlRequest)
        self.viewWeb.addSubview(webView)
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
    
    @IBAction func backShareClick(btn:UIButton)
    {
        loadPDFAndShare()
    }
}

extension ShowPDFVC
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

extension ShowPDFVC : WKNavigationDelegate
{
    func webView(_ webView: WKWebView, didFinish navigation:
        WKNavigation!) {        
        self.hideSpinner()
        savePdfToDocDir()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation
        navigation: WKNavigation!) {
        self.showSpinnerWith(title: "Cargando...")
    }
    
    func webView(_ webView: WKWebView, didFail navigation:
        WKNavigation!, withError error: Error) {
        self.hideSpinner()
    }
    
    func savePdfToDocDir(){
        // Need to save Pdf to Doc Dir, before opening UIActivityViewController
        let fileManager = FileManager.default
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        
      //  print(strExtension)
        if strExtension == "pdf"
        {
            paths = paths.appendingPathComponent("documento.pdf") as NSString
        }
        else if strExtension == "xlsx"
        {
            paths = paths.appendingPathComponent("documento.xlsx") as NSString
        }
        else if strExtension == "txt"
        {
            paths = paths.appendingPathComponent("documento.txt") as NSString
        }
        else
        {
            paths = paths.appendingPathComponent("documento.pdf") as NSString
        }
        
        
        let encodedPath = pdfFilePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let pdfDoc = NSData(contentsOf:URL(string: encodedPath!)!)
        fileManager.createFile(atPath: paths as String, contents: pdfDoc as Data?, attributes: nil)
    }
    
    func loadPDFAndShare(){
        
        let fileManager = FileManager.default
        //  let documentoPath = (self.getDirectoryPath() as NSString).appendingPathComponent("documento.pdf")
        
        var documentoPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        
      //  print(strExtension)
        if strExtension == "pdf"
        {
            documentoPath = documentoPath.appendingPathComponent("documento.pdf") as NSString
        }
        else if strExtension == "xlsx"
        {
            documentoPath = documentoPath.appendingPathComponent("documento.xlsx") as NSString
        }
        else if strExtension == "txt"
        {
            documentoPath = documentoPath.appendingPathComponent("documento.txt") as NSString
        }
        else
        {
            documentoPath = documentoPath.appendingPathComponent("documento.pdf") as NSString
        }
        
        if fileManager.fileExists(atPath: documentoPath as String){
            let documento = NSData(contentsOfFile: documentoPath as String)
            
            let url = NSURL.fileURL(withPath: documentoPath as String)
            
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView=self.view
            present(activityViewController, animated: true, completion: nil)
        }
        else {
            print("document was not found")
        }
    }
    
    func clearTempFolderDocDirectory()
    {
        let fileManager = FileManager.default
        let tempFolderPath = NSTemporaryDirectory()
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: tempFolderPath + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
}
