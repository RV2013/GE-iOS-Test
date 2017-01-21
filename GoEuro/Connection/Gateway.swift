//
//  Gateway.swift
//  GoEuro
//
//  Created by GlobalSysInfo-Mac-001 on 16/01/17.
//  Copyright © 2017 Rachit Vyas. All rights reserved.
//

import Foundation
import CoreLocation

extension Client
{
    func getListForTravel(mode: TravelMode, apiCompletionHandler: @escaping APICompletionHandler)
    {
        let url = getURLFor(travelOption: mode.rawValue)
        
        weak var weakSelf = self
        getDataFromURL(url: url) { (status, responseData, error) in
            
            if(status && responseData != nil)
            {
                let results = responseData as! [[String:Any]]
                                
                weakSelf?.downloadLogos(forList: results)
                
                apiCompletionHandler(status, results, error)
            }
                
            else
            {
                apiCompletionHandler(status, responseData, error)
            }
        }
    }
    
    func downloadLogos(forList list: [[String:Any]])
    {
        for item in list
        {
            let urlStr = item[Constants.ResponseKeys.Logo] as! String
            let urlString = urlStr.replacingOccurrences(of: "{size}", with: "63")
            
            let url = URL(string:urlString)
            
            if(url != nil)
            {
                if let fileName = urlString.components(separatedBy: "/").last
                {
                    let path = "/logos/\(fileName)"
                    
                    let localPath = getLocalPath(forDirectory: .documentDirectory, withPath: path)
                    downloadResource(fromUrl: url!, atLocation: localPath)
                }
            }
        }
    }
}

