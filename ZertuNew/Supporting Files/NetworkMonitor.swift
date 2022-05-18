//
//  NetworkMonitor.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 19/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import Foundation
import Network   // NWPathMonitor

class NetworkMonitor
{
    // create DispatchQueue to run Concurrently to keep track on any change in newtork
    private var concurrentQueue = DispatchQueue(label: "MonitorConnectivity", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    
    // create a function to return the status of Conncetion in closure
    func checkAvailableNetwork(handler: @escaping (Bool, String) -> ())
    {
            let pathMonitor = NWPathMonitor()
            
            pathMonitor.pathUpdateHandler = { path in
                
                if path.status == NWPath.Status.satisfied {
                    
                    if path.usesInterfaceType(.wifi) {
                        handler(true, "WiFi")
                    } else if path.usesInterfaceType(.cellular) {
                        handler(true, "cellular")
                    } else if path.usesInterfaceType(.wiredEthernet) {
                        handler(true, "wiredEthernet")
                    } else {
                        handler(true, "others")
                    }
                } else {
                    handler(false, "None")
                }
                print("is Cellular data: \(path.isExpensive)") //Checking is this is a Cellular data
        }
        
        // start the process
        pathMonitor.start(queue: concurrentQueue)
    }
}
