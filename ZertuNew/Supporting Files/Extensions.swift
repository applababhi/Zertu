//
//  Extensions.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 18/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import SDWebImage
import AVKit
import AVFoundation

//MARK: //////    Device Check ////////
extension UIViewController
{
    func getDeviceModel() -> String
    {
        var model = ""
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
                model = "iPhone 5"
            case 1334:
                print("iPhone 6/6S/7/8")
                model = "iPhone 6"
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
                model = "iPhone 6+"
            case 2436:
                print("iPhone X, XS")
                model = "iPhone XS"
            case 2688:
                print("iPhone XS Max")
                model = "iPhone Max"
            case 1792:
                print("its iPhone XR & 11")
                model = "iPhone XR"
            default:
                print("Unknown")
                model = "Unknown"
            }
        }
        return model
    }
}

//MARK: //////    Hide Keyboard on Tap  ////////

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapOutKeyboard = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapOutKeyboard)
    }
    
    @objc private func hideKeyboard()
    {
        // private because when we start typing hideKeyboard in any UIViewController then these 2 function names start showing in intelligence, so just to avaoid confusion add it Private
        view.endEditing(true)
    }
}

//MARK: //////    Add Shadow to UIView  ////////
extension UIView {
    
    func dropShadow() {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 2
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        
        self.layer.rasterizationScale = UIScreen.main.scale
        
    }
}

//MARK: //////    UIViewcontroller  ////////
extension UIViewController {
        
    func addCustomBackButton()
    {
        let backImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        /*** If needed Assign Title Here ***/
        self.navigationController?.navigationBar.topItem?.title = " "
    }

    func hideNavigationBar(){
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func showNavigationBar() {
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func addLeftPaddingTo(tf:UITextField)
        {
            let viewT = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
            viewT.backgroundColor = .clear
            
            tf.leftViewMode = UITextField.ViewMode.always
            tf.leftView = viewT
        }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func checkInternetAvailable()
    {
        // created a common function in Ext, as it ll be needed when ever we call API
        
        let connection:NetworkMonitor = NetworkMonitor()
        connection.checkAvailableNetwork { (isAvailable:Bool, networkType:String) in
            
            if isAvailable == true
            {
                print("Network is Available - via - ", networkType)
                
                DispatchQueue.main.sync {
                    k_helper.isNetworkAvailable =  "Available"
                }
            }
            else
            {
                print("Network NOT Available - via - ", networkType)
                
                DispatchQueue.main.async {
                    k_helper.isNetworkAvailable =  "Not Available"
                    self.showAlertWithTitle(title: "Alerta", message: "No hay conexión a internet disponible", okButton: "Ok", cancelButton: "", okSelectorName: nil)
                }
            }
        }
    }
    
    func showAlertWithTitle(title:String, message:String, okButton:String, cancelButton:String, okSelectorName:Selector?)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if okSelectorName != nil
        {
            let OKAction = UIAlertAction(title: okButton, style: .default) { (action:UIAlertAction!) in
                self.perform(okSelectorName)
            }
            alertController.addAction(OKAction)
        }
        else
        {
            let OKAction = UIAlertAction(title: okButton, style: .default, handler: nil)
            alertController.addAction(OKAction)
        }
        
        if cancelButton != ""
        {
            let cancleAction = UIAlertAction(title: cancelButton, style: .destructive) { (action:UIAlertAction!) in
                print("cancel")
            }
            alertController.addAction(cancleAction)
        }
        
        self.present(alertController, animated: true, completion:nil)
    }
    
    func setViewBackgroundImage(name:String) {
        let backgroundImgView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImgView.image = UIImage(named: name)
        self.view.insertSubview(backgroundImgView, at: 0)
    }
}

//MARK: //////    Colour Hexa String  ////////
extension UIColor
{
    class func colorWithHexString (_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in:(NSCharacterSet.whitespacesAndNewlines as NSCharacterSet) as CharacterSet).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}

// MARK: Activity Indicator
extension UIViewController : NVActivityIndicatorViewable
{
    func showSpinnerWith(title:String)
    {
        DispatchQueue.main.async {
            let size = CGSize(width: 50, height: 50)
            
            self.startAnimating(size, message: "", type: .ballScaleMultiple, color: k_baseColor)
        }
    }
    
    func hideSpinner()
    {
        DispatchQueue.main.async {
            self.stopAnimating()
        }
    }
}

// MARK: HTML to Attributed String
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard
            let data = self.data(using: .utf8)
            else { return nil }
        do {
            return try NSAttributedString(data: data, options: [
                NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
                ], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    var htmlTo_UTF8String: String {
        return htmlToAttributedString_UTF8?.string ?? ""
    }
    
    var htmlToAttributedString_UTF8: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
}

// MARK: TEXTFIELD PH Color
extension UITextField
{
    func setPlaceHolderColorWith(strPH:String){
        self.attributedPlaceholder = NSAttributedString(string: strPH, attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)])
    }
}

extension Float {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UIImageView {
    
    func setImageUsingUrl(_ imageUrl: String?){
        self.sd_setImage(with: URL(string: imageUrl!), placeholderImage:UIImage(named: "ph"))
    }
}

extension String{

    func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)

        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }

    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat? {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }
}


extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

class LandscapePlayer: AVPlayerViewController {
      override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
          return .landscapeLeft
       }
}

extension UIView {
    /**
     Rotate a view by specified degrees

     - parameter angle: angle in degrees
     */
    func rotate(angle angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians);
        self.transform = rotation
    }

}

extension UIViewController
{
    func getScreenshot() -> UIImage? {
        //creates new image context with same size as view
        // UIGraphicsBeginImageContextWithOptions (scale=0.0) for high res capture
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0.0)

        // renders the view's layer into the current graphics context
        if let context = UIGraphicsGetCurrentContext() { view.layer.render(in: context) }

        // creates UIImage from what was drawn into graphics context
        let screenshot: UIImage? = UIGraphicsGetImageFromCurrentImageContext()

        // clean up newly created context and return screenshot
        UIGraphicsEndImageContext()
        return screenshot
    }
}

extension Double {
    
    private var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    func secondsToString() -> String {
        return formatter.string(from: self) ?? ""
    }
    
}

// Dictionary to STRING
extension Dictionary {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
            return nil
        }

        return String(data: theJSONData, encoding: .ascii)
    }
}

extension NSAttributedString {

    func height(containerWidth: CGFloat) -> CGFloat {

        let rect = self.boundingRect(with: CGSize.init(width: containerWidth, height: CGFloat.greatestFiniteMagnitude),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return ceil(rect.size.height)
    }

    func width(containerHeight: CGFloat) -> CGFloat {

        let rect = self.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: containerHeight),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return ceil(rect.size.width)
    }
}
