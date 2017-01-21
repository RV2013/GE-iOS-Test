//
//  Helper.swift
//  GoEuro
//
//  Created by GlobalSysInfo-Mac-001 on 16/01/17.
//  Copyright © 2017 Rachit Vyas. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

//public typealias CLGeocodeCompletionHandler = ([CLPlacemark]?, Error?) -> Swift.Void
public typealias ObjectHandler = (Any?) -> Void
public typealias APICompletionHandler = (Bool, Any?, Error?) -> Void
public typealias testCompletionHandler = (Data?, URLResponse?, Error?) -> Void

func performOnMain(updates: @escaping () -> Void) {
    
    DispatchQueue.main.async{
        
        updates()
    }
}

func performInBackground(tasks: @escaping () -> Void) {
    
    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
        
        tasks()
    }
}

func getRootVC() -> UIViewController?
{
    let window: UIWindow? = UIApplication.shared.keyWindow
    let vc: UIViewController? = window?.rootViewController
    
    return vc
    
}

func showAlert(title: String?, message: String?, vc: UIViewController?)
{
    var myVC = vc
    if(myVC == nil)
    {
        myVC = getRootVC()
    }
    
    let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let alertAction = UIAlertAction(title: "OK", style: .default, handler: { action in
        
    })
    
    alertView.addAction(alertAction)
    
    performOnMain {
        
        myVC?.present(alertView, animated: true, completion: nil)
    }
}

func showBooleanAlert(title: String?, message: String?, vc: UIViewController!, completionHandler handler: @escaping (Bool) -> Void)
{
    let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let actionYes = UIAlertAction(title: "Yes", style: .default, handler: { action in
        
        handler(true)
    })
    
    let actionNo = UIAlertAction(title: "No", style: .default, handler: { action in
        
        handler(false)
    })
    
    alertView.addAction(actionYes)
    alertView.addAction(actionNo)
    
    vc.present(alertView, animated: true, completion: nil)
}

func startNetworkIndicator()
{
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
}

func stopNetworkIndicator()
{
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
}

func isNetworkConnectionAvailable() -> Bool
{
    //http://stackoverflow.com/questions/38726100/best-approach-for-checking-internet-connection-in-ios
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    }) else {
        return false
    }
    
    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return false
    }
    
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    
    let status = (isReachable && !needsConnection)
    
    if(status == false)
    {
        //showAlert(title: "Failed", message: "No Interntet Connection Available", vc: nil)
    }
    
    
    return status
}

func createDirectory(atPath dirPath: String)
{
    do {
        
        try FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
    }
        
    catch {
        
        print("Unable to create directory at path: \(dirPath) \n error: \(error.localizedDescription)")
    }
    
}

func getLocalPath(forDirectory directory: FileManager.SearchPathDirectory, withPath path: String) -> String
{
    let documentsPath = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)[0] as NSString
    
    let fullPath = documentsPath.appending(path)
    var isDir : ObjCBool = true
    
    if !FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir)
    {
        let directoryPath = documentsPath.appending("/logos/")
        createDirectory(atPath: directoryPath)
    }
    
    return fullPath
}

