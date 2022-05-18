//
//  Constants.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 18/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import Foundation
import UIKit

//  let baseUrl:String = "http://zertu.medialima-api.com:8090"  // OLD Prod
  let baseUrl:String = "https://zertu.applab-api.com"  // NEW Prod 21/May/2021
//  let baseUrl:String = "http://ec2-34-222-54-64.us-west-2.compute.amazonaws.com:8090"  // New dev Url 19April19

let baseImgUrl:String = "https://s3-us-west-1.amazonaws.com/zertu/"

let k_baseColor:UIColor = UIColor.colorWithHexString("#8B31A7")
let k_window:UIWindow = UIApplication.shared.delegate!.window! as! UIWindow
let k_appDel:AppDelegate = UIApplication.shared.delegate! as! AppDelegate
let localTimeZoneName: String = TimeZone.current.localizedName(for: .generic, locale: .current) ?? ""
let k_helper:Helper = Helper.shared
var devicePushToken:String = ""
var bearerToken = ""
let k_userDef = UserDefaults.standard
typealias CompletionHandler = ([String:Any], String, Error?) -> ()

struct CustomFont{
    static let GSLRegular = "GeosansLight"
    static let GSLOblique = "GeosansLight-Oblique"
}

enum serviceName:String
{
    case Dashboard = "/main/dashboard"
    case CheckVersionNumber = "/user/version"
    case LoginAPIAndRefreshToken = "/oauth/token"
    case GetAllCategories = "/category/find/all"
    case GetEachCategory = "/category/find/"
    case GetEachCategoryNew = "/category/find/slug/"
    case Register = "/user/register"
    case GetSelectedCourse = "/course/"
    case FBLogin = "/user/signin/facebook"
    case InPersonCourses = "/course/in-person/list"
    case InPersonCourseID = "/course/in-person/+++"
    case userCardList = "/user/payment/list"
    case getUserProfile = "/user/profile"
    case postBusiness = "/contact/send"
    case CheckoutStore = "/store/order"
    case AddCardConekta = "/user/payment/create"
    case PayByOXXO = "/course/in-person/oxxo/pay"
    case MakeCardDefault = "/user/payment/default"
    case SendIAPReceipt = "/course/iap/paid"
    case SendIAPReceipt_Module = "/certificacion/iap"
    case DeleteCardDefault = "/user/payment/delete"
    case PayByConekta = "/course/in-person/conekta/pay"
    case PayCourseByConekta = "/course/conekta/pay"
    case GetPayPalToken = "/user/payment/paypal/token"
    case MakePayPalPayment = "/course/in-person/paypal/pay"
    case ForgotPassword = "/user/password/recovery"
    case UpdateProfile = "/user/profile/update"
    case GetContactInfo = "/user/contact"
    case GetMyTickets = "/user/tickets"
    case GetOXXOList = "/user/oxxo-requests"
    case SendPushDeviceToken = "/user/device/ios"
    case PostVideoViewed = "/video/finished"
    case GetProductsList = "/store/products"
    case GetMusicList = "/music/playlist"
    case GetCertifications = "/certificacion/list"
    case GetModuleDetail = "/certificacion/modulo/"
    case POSTModuleSubmit = "/certificacion/evaular/"
    case PostFreePayCourse = "/course/v2/conekta/pay"
}

enum userDefaultKeys :String
{
    case AccessToken = "-access-Token-"
    case RefreshToken = "-refresh-access-Token-"
    case onBoardingShown = "onBoardingShown"
    case userRestoredAllPurchases = "userRestoredAllPurchases"
}

enum AppStoryboards : String
{
    case Login, OnBoarding, BaseTabBar, Home, Shopping, MyProfile, More, InPerson
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
}

