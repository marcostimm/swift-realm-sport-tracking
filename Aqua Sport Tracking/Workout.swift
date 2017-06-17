//
//  Workout.swift
//  Aqua Sport Tracking
//
//  Created by Marcos Timm on 17/06/17.
//  Copyright © 2017 Timm. All rights reserved.
//

import RealmSwift

class Workout: Object {
    
    dynamic var timestamp           = NSDate()
    dynamic var duration            = 0
    dynamic var distance: Float     = 0.0
    dynamic var descent: Float      = 0.0
    dynamic var climb: Float        = 0.0
    var locations                   = List<Location>()
    
    func save() -> Bool {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self)
            }
            return true
        } catch let error as NSError {
            print(">>> Realm Error: ", error.localizedDescription)
            return false
        }
    }
    
}
