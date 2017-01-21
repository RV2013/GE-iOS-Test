//
//  TravelInfo+CoreDataProperties.swift
//  GoEuro
//
//  Created by GlobalSysInfo-Mac-001 on 16/01/17.
//  Copyright © 2017 Rachit Vyas. All rights reserved.
//

import Foundation
import CoreData


extension TravelInfo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TravelInfo> {
        return NSFetchRequest<TravelInfo>(entityName: "TravelInfo");
    }
    
    @NSManaged public var arrival: String
    @NSManaged public var departure: String
    @NSManaged public var logo: String
    @NSManaged public var price: Float
    @NSManaged public var stops: Int16
    @NSManaged public var type: String
    @NSManaged public var traveltime: String
    @NSManaged public var traveltimeindex: Float
    
}

