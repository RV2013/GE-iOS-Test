//
//  TravelInfo.swift
//  GoEuro
//
//  Created by GlobalSysInfo-Mac-001 on 16/01/17.
//  Copyright © 2017 Rachit Vyas. All rights reserved.
//

import Foundation
import CoreData

enum TravleInfoSortBy : String {
    case Departure = "departure"
    case Arrival = "arrival"
    case TravelTime = "traveltimeindex"
    
    func getTypeBy(indexValue  :  Int) -> TravleInfoSortBy{
        
        switch indexValue {
        case 0:
            return .Departure
        case 1:
            return .Arrival
        case 2:
            return .TravelTime
        default:
            return .Departure
        }
    }
    
    
    func getlabelFor(indexValue  :  Int) -> String{
        
        switch indexValue {
        case 0:
            return "DEPARTURE TIME"
        case 1:
            return "ARRIVAL TIME"
        case 2:
            return "TRAVEL TIME"
        default:
            return ""
        }
    }

}


public class TravelInfo: NSManagedObject
{
    convenience init(dictionary: [String:Any], forType type: String, context: NSManagedObjectContext)
    {
        if let ent = NSEntityDescription.entity(forEntityName: "TravelInfo", in: context)
        {
            self.init(entity: ent, insertInto: context)
            self.logo = dictionary[Constants.ResponseKeys.Logo] as? String ?? ""
            self.arrival = dictionary[Constants.ResponseKeys.Arrival] as? String ?? ""
            self.departure = dictionary[Constants.ResponseKeys.Departure] as? String ?? ""
            self.stops = Int16(dictionary[Constants.ResponseKeys.Stops] as? Int ?? -1)
            self.price = dictionary[Constants.ResponseKeys.Price] as? Float ?? 0
            if (price == 0.0)
            {
                if let priceStr = dictionary[Constants.ResponseKeys.Price] as? String
                {
                    price = Float(priceStr)!
                }
            }
            
             self.traveltime = self.calculateTravelTime(timeFrom: self.departure, timeTo: self.arrival)!
            
            //print("\(self.traveltime) --- \(self.traveltimeindex)")
            
            self.type = type
        }
            
        else
        {
            fatalError("Unable to find Entity name!")
        }
    }
    
    
    
    /*
     
     Below 2 function will be used to caluclate the time interval or difference between two time values given as string in format
     hh:mm:ss and returns the time interval again in teh same format as hh:mm:ss
     
     @param     :   timeFrom -> String - e.g. "9:45" or "11:59"
     @param     :   timeTo -> String - e.g. "9:45" or "11:59"
     
     @return    :   String (optional) - e.g. "4:21h", "42:1m", "4s" OR nil
     
     */
    
    private func calculateTravelTime(timeFrom : String, timeTo : String) -> String?{
     
        
        // convert timing strings to independent Int values
        
        let aTuple : (Int?, Int?, Int?) = self.getTimeComponentsFrom(timingText: timeFrom)!
        
        let bTuple : (Int?, Int?, Int?)  = self.getTimeComponentsFrom(timingText: timeTo)!
    
        
        let difference :  (Int?, Int?, Int?) = (aTuple.0! - bTuple.0! > 0 ? aTuple.0! - bTuple.0! : (aTuple.0! - bTuple.0!) * (-1),
                                                aTuple.1! - bTuple.1! > 0 ? aTuple.1! - bTuple.1! : (aTuple.1! - bTuple.1!) * (-1),
                                                aTuple.2! - bTuple.2! > 0 ? aTuple.2! - bTuple.2! : (aTuple.2! - bTuple.2!) * (-1))
        
        var message : String?
        
        if difference.0! > 0 {
            
            message = "\(difference.0!):\(difference.1!)h"
            
            let total  :  Float = Float((difference.0! * 100) + difference.1!)
            
            self.traveltimeindex = total / 100
        }
        else if(difference.1! > 0){
            
            message = "\(difference.1!):\(difference.2!)m"
            
            self.traveltimeindex = Float(((difference.1! * 100) + difference.2!) / 100)
        }
        else if(difference.2! > 0){
            
            message = "\(difference.2!)s"
            
             self.traveltimeindex = Float(difference.2!)
        }
        else{
            
            return message
        }
        
        return message
        
    }
    
    private func getTimeComponentsFrom(timingText :  String) -> (hour : Int?, minutes : Int?, seconds : Int?)?{
        
        let arrComponents = timingText.components(separatedBy: ":")
        
        
        if (arrComponents.count <= 1 || arrComponents.count > 3) {
            
            return nil
        }
        else if arrComponents.count == 3{
            
            return(Int(arrComponents[0]), Int(arrComponents[1]), Int(arrComponents[2]))
        }
        else if arrComponents.count == 2{
            
            return(Int(arrComponents[0]), Int(arrComponents[1]), Int(0))
        }
        else{
            
            return nil
        }
        
    }
    

}
