//
//  CoreDataManager.swift
//  GoEuro
//
//  Created by GlobalSysInfo-Mac-001 on 16/01/17.
//  Copyright © 2017 Rachit Vyas. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

protocol CoreDataManagerDelegate: NSObjectProtocol
{
    func refreshView()
}

class CoreDataManager: NSObject, SessionDownloadDelegate
{
    static let sharedManager = CoreDataManager()
    
    weak var delegate: CoreDataManagerDelegate?
    
    private var sortingOrder : TravleInfoSortBy = .Departure
    private var sortAscending : Bool = true

    
    override private init()
    {
        super.init()
    }
    
    func fetchRecords(ofType type: String) -> [TravelInfo]?
    {
        let fetchReq = NSFetchRequest<TravelInfo>(entityName: "TravelInfo") as! NSFetchRequest<NSFetchRequestResult>
        fetchReq.predicate = NSPredicate(format: "type == '\(type)'")
        
        // Sorting the NMOs in acending order of key 'departure' (deault) of Entity 'TravelInfo'
        
        let sortDescriptor = NSSortDescriptor(key: self.sortingOrder.rawValue, ascending: self.sortAscending)
        let sortDescriptors = [sortDescriptor]
        fetchReq.sortDescriptors = sortDescriptors

        
        do {
            let travelInfo = try appDelegate.stack.context.fetch(fetchReq) as! [TravelInfo]
            
            
            return travelInfo
        }
            
        catch {
            print("Error while fetching records of type: \(type): \(error.localizedDescription)")
            
            return nil
        }
    }
    
    func deleteRecords(ofType type: String)
    {
        let fetchReq = NSFetchRequest<TravelInfo>(entityName: "TravelInfo") as! NSFetchRequest<NSFetchRequestResult>
        fetchReq.predicate = NSPredicate(format: "type == '\(type)'")
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchReq)
        
        do
        {
            try appDelegate.stack.coordinator.execute(deleteRequest, with: appDelegate.stack.context)
        }
            
        catch {
            print("Error while deleting records of type: \(type): \(error.localizedDescription)")
        }
    }
    
    func saveTravelInfo(data: [[String:Any]], forType type: TravelMode)
    {
        deleteRecords(ofType: type.rawValue)
        
        for item in data
        {
            _ = TravelInfo(dictionary: item, forType: type.rawValue, context: appDelegate.stack.context)
        }
        
        appDelegate.stack.save()
    }
    
    func sortRecords(ascending : Bool, updateSortingFactor : Bool) -> TravleInfoSortBy{
        
        self.sortAscending = ascending
        
        if updateSortingFactor == true {
            
            if self.sortingOrder == .Departure {
                
                self.sortingOrder = .Arrival
            }
            else if(self.sortingOrder == .Arrival){
                
                self.sortingOrder = .TravelTime
            }
            else{
                
                self.sortingOrder = .Departure
            }

        }
        
        return self.sortingOrder
        
    }
    
    
    
    //MARK:- SessionDownloadDelegate Method
    
    func resourceDownloaded(status: URLSessionTask.State, resourceData: Data?, error: Error?)
    {
        guard error == nil else {
            
            print("Error while downloading resource: \(error)")
            return
        }
        
        if (status == .completed || status == .running)
        {
            if resourceData != nil
            {
                
                delegate?.refreshView()
                
            }
        }
    }
}

