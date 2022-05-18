//
//  Network.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 19/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

struct WebService
{
    static func callApiWith(url:String, method:HTTPMethod, parameter: Parameters?, header:HTTPHeaders, encoding:String, vcReff:UIViewController, completion: @escaping CompletionHandler)
    {
        let urlToPass:String = baseUrl + url
        var encode:ParameterEncoding!
        
        if encoding == "JSON"
        {
            encode = JSONEncoding.default
        }
        else if encoding == "URL"
        {
            encode = URLEncoding.default
        }
        else
        {
            encode = URLEncoding.queryString
        }
        
        Alamofire.request(urlToPass, method: method, parameters: parameter, encoding: encode, headers: header).responseJSON { (response:DataResponse) in
            
            let data:Data = response.data!
            let strJson:String = String(data: data, encoding: .utf8)!
            // print(strJson)
            
            var statusCode = response.response?.statusCode
            
            print(" - - - - -  - - - - - - -")
            print("_ _ _ statusCode _ _ is _ _ _ ")
            print(statusCode)
            
            if statusCode != nil{
                if statusCode! > 300
                {
                    completion(["error500":strJson], strJson, nil)
                }
            }
            
            switch response.result
            {
            case .success:
                if let json:[String:Any] = response.result.value as? [String:Any]
                {
                    if let errorStr:String = json["error"] as? String
                    {
                        if errorStr == "invalid_token"
                        {
                            print("- - - - - - - - ")
                            print("- - - - - - - - ")
                            print("- - - - - - Token ERRRRRRRRRRROOOOOOOOOOORRRRRRRRRRRR - - - - - ")
                            print("- - - - - - - - ")
                            print("- - - - - - - - ")
                            
                            if isUserTappedSkipButton == true
                            {
                                DispatchQueue.main.async(execute: {
                                    vcReff.hideSpinner()
                                })
                                return
                            }
                            
                            NotificationCenter.default.post(name: Notification.Name("UpdateRereshToken"), object: nil)
                            completion([:], strJson, nil)
                        }
                        return
                    }
                    
                    completion(json, strJson, nil)
                }
                else if let jsonArray:[[String:Any]] = response.result.value as? [[String:Any]]
                {
                    // print("JSON is ARRAY : \(jsonArray)")
                    completion(["createdArray": jsonArray], strJson, nil)
                }
                break
            case .failure(let err):
                print("- - Error Came for - -> \(url)")
                print("- - - -")
                print("Request failed with error ->   \(err.localizedDescription)")
                
                completion([:], strJson, err)
                break
            }
        }
    }
}
