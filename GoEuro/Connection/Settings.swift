//
//  Settings.swift
//  GoEuro
//
//  Created by GlobalSysInfo-Mac-001 on 16/01/17.
//  Copyright © 2017 Rachit Vyas. All rights reserved.
//

import Foundation

extension Client
{
    func getURLFor(travelOption: String, parameters: [String:Any]? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.GoEuro.APIScheme
        components.host = Constants.GoEuro.APIHost
        components.path = Constants.GoEuro.APIPath + travelOption
        
        if let parameters = parameters
        {
            components.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters
            {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    
    //Not used in this app
    func getRequestOfType(type: String!, url: URL!) -> NSMutableURLRequest
    {
        let request = NSMutableURLRequest(url: url!)
        
        request.httpMethod = type
        
        if(type == "DELETE")
        {
            var xsrfCookie: HTTPCookie? = nil
            let sharedCookieStorage = HTTPCookieStorage.shared
            for cookie in sharedCookieStorage.cookies!
            {
                if cookie.name == "XSRF-TOKEN"
                {
                    xsrfCookie = cookie
                    
                    break
                }
            }
            
            if let xsrfCookie = xsrfCookie
            {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
        }
            
        else
        {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        }
        
        return request
    }
}

