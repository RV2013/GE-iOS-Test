//
//  Constants.swift
//  GoEuro
//
//  Created by GlobalSysInfo-Mac-001 on 16/01/17.
//  Copyright © 2017 Rachit Vyas. All rights reserved.
//

import UIKit

enum TravelMode: String
{
    case Train = "3zmcy"
    
    case Bus = "37yzm"
    
    case Flight = "w60i"
}

enum TravelType: String
{
    case Train = "Train"
    
    case Bus = "Bus"
    
    case Flight = "Flight"
}

// MARK: - Constants

struct Constants {
    
    // MARK: GoEuro
    struct GoEuro {
        static let APIScheme = "https"
        static let APIHost = "api.myjson.com"
        static let APIPath = "/bins/"
    }
    
    // MARK: Flickr Response Keys
    struct ResponseKeys {
        static let Logo = "provider_logo"
        static let Price = "price_in_euros"
        static let Arrival = "arrival_time"
        static let Departure = "departure_time"
        static let Stops = "number_of_stops"
    }
    
    // MARK: Flickr Response Values
    struct ResponseValues {
        static let OKStatus = "ok"
    }
}

