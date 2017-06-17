//
//  Location.swift
//  Aqua Sport Tracking
//
//  Created by Marcos Timm on 17/06/17.
//  Copyright © 2017 Timm. All rights reserved.
//

import RealmSwift

class Location: Object {
    
    dynamic var timestamp = NSDate()
    dynamic var longitude: Double = 0.0
    dynamic var latitude: Double = 0.0
}
