//
//  Client.swift
//  GoEuro
//
//  Created by GlobalSysInfo-Mac-001 on 16/01/17.
//  Copyright © 2017 Rachit Vyas. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit

protocol SessionDownloadDelegate
{
    func resourceDownloaded(status: URLSessionTask.State, resourceData: Data?, error: Error?) -> Void
}

class Client: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, URLSessionDownloadDelegate
{
    static let sharedInstance = Client()
    
    private let operationQueue : OperationQueue
    private var dataSession = URLSession()
    private var bgSession = URLSession()
    
    let bgSessionIdentifier: String = "bg.session.id"
    
    override private init()
    {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 5
        
        super.init()
        
        initializeSessions()
    }
    
    private func initializeSessions()
    {
        let dataConfiguration = URLSessionConfiguration.default
        dataConfiguration.allowsCellularAccess = true
        dataConfiguration.timeoutIntervalForRequest = 60
        dataConfiguration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        let bgConfiguration = URLSessionConfiguration.background(withIdentifier: bgSessionIdentifier)
        bgConfiguration.allowsCellularAccess = true
        bgConfiguration.timeoutIntervalForRequest = 60
        bgConfiguration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        dataSession = URLSession(configuration: dataConfiguration, delegate: self, delegateQueue: operationQueue)
        dataSession.sessionDescription = "session.data"
        
        bgSession = URLSession(configuration: bgConfiguration, delegate: self, delegateQueue: operationQueue)
        bgSession.sessionDescription = "session.bg"
    }
    
    internal func getDataFromURL(url: URL?, apiCompletionHandler: @escaping APICompletionHandler)
    {
        if(isNetworkConnectionAvailable())
        {
            let request = getRequestOfType(type: "GET", url: url)
            
            startNetworkIndicator()
            weak var weakSelf = self
            let task = dataSession.dataTask(with: request as URLRequest) { responseData, response, error in
                
                weakSelf?.processResponse(responseData: responseData, response: response, error: error, applyOffset: false, apiCompletionHandler: apiCompletionHandler)
                
                stopNetworkIndicator()
            }
            
            task.resume()
        }
            
        else
        {
            apiCompletionHandler(false, nil, nil)
        }
    }
    
    internal func post(data: Data?, toURL url: URL?, applyOffSet: Bool!, apiCompletionHandler: @escaping APICompletionHandler)
    {
        if(isNetworkConnectionAvailable())
        {
            let request = getRequestOfType(type: "POST", url: url)
            
            if data != nil
            {
                request.httpBody = data
            }
            
            startNetworkIndicator()
            weak var weakSelf = self
            let task = dataSession.dataTask(with: request as URLRequest, completionHandler:{ responseData, response, error in
                
                weakSelf?.processResponse(responseData: responseData, response: response, error: error, applyOffset: applyOffSet, apiCompletionHandler: apiCompletionHandler)
                
                stopNetworkIndicator()
            })
            
            task.resume()
        }
            
        else
        {
            apiCompletionHandler(false, nil, nil)
        }
    }
    
    internal func put(data: Data?, toURL url: URL!, apiCompletionHandler: @escaping APICompletionHandler)
    {
        if(isNetworkConnectionAvailable())
        {
            let request = getRequestOfType(type: "PUT", url: url)
            
            if data != nil
            {
                request.httpBody = data
            }
            
            startNetworkIndicator()
            
            weak var weakSelf = self
            let task = dataSession.dataTask(with: request as URLRequest, completionHandler:{ responseData, response, error in
                
                weakSelf?.processResponse(responseData: responseData, response: response, error: error, applyOffset: false, apiCompletionHandler: apiCompletionHandler)
                
                stopNetworkIndicator()
            })
            
            task.resume()
        }
            
        else
        {
            apiCompletionHandler(false, nil, nil)
        }
    }
    
    internal func delete(url: URL, apiCompletionHandler: @escaping APICompletionHandler)
    {
        if(isNetworkConnectionAvailable())
        {
            let request = getRequestOfType(type: "DELETE", url: url)
            
            weak var weakSelf = self
            let task = dataSession.dataTask(with: request as URLRequest) { data, response, error in
                
                weakSelf?.processResponse(responseData: data, response: response, error: error, applyOffset: true, apiCompletionHandler: apiCompletionHandler)
            }
            
            task.resume()
        }
            
        else
        {
            apiCompletionHandler(false, nil, nil)
        }
    }
    
    internal func downloadResource(fromUrl url: URL, atLocation location: String?)
    {
        if(isNetworkConnectionAvailable())
        {
            let task = bgSession.downloadTask(with: url)
            
            
            if(location == nil)
            {
                task.taskDescription = "delegate"
            }
                
            else
            {
                task.taskDescription = location
            }
            
            task.resume()
        }
    }
    
    private func processResponse(responseData: Data?, response: URLResponse?, error: Error?, applyOffset: Bool, apiCompletionHandler: APICompletionHandler)
    {
        guard (error == nil) else {
            print("There was an error with your request: \(error)")
            apiCompletionHandler(false, nil, error)
            return
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            apiCompletionHandler(false, nil, error)
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let respData = responseData else {
            apiCompletionHandler(false, nil, error)
            return
        }
        
        do
        {
            var parsedString = String.init(data: respData, encoding: String.Encoding.utf8)
            
            if(applyOffset)
            {
                let startIndex = parsedString?.index((parsedString?.startIndex)!, offsetBy: 5)
                parsedString = parsedString?.substring(from: startIndex!)
            }
            
            let jsonData = parsedString?.data(using: String.Encoding.utf8)
            
            let parsedResult = try JSONSerialization.jsonObject(with: jsonData!, options: [.allowFragments,.mutableContainers,.mutableLeaves])
            
            apiCompletionHandler(true, parsedResult, nil)
        }
            
        catch
        {
            print("Error while parsing the response data: \(error)")
            apiCompletionHandler(false, nil, error)
        }
    }
    
    
    //MARK:- TaskDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        
    }
    
    //MARK:- DataDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
    }
    
    //MARK:- BackgroundDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        if(downloadTask.taskDescription == "delegate")
        {
            let data = FileManager.default.contents(atPath: location.relativePath)
            
            CoreDataManager.sharedManager.resourceDownloaded(status: downloadTask.state, resourceData: data, error: downloadTask.error)
            
            
        }
            
        else
        {
            let sourcePath = location.relativePath
            
            guard let destinationPath = downloadTask.taskDescription else {
                print("Destination path is nil")
                return
            }
            
            do {
                if(!FileManager.default.fileExists(atPath: destinationPath))
                {
                    try FileManager.default.copyItem(atPath: sourcePath, toPath: destinationPath)
                }
            }
            catch
            {
                print("Error while copying & removing downloaded file \(error.localizedDescription)")
            }
        }
    }
}

