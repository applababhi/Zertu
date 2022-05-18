//
//  Helper.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 19/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import Foundation

class Helper: NSObject {
    static let shared = Helper()
    private override init() {}
    
    var isNetworkAvailable = ""
    
    var arrCart_products_InTiendaScreen:[[String:Any]] = []
}
