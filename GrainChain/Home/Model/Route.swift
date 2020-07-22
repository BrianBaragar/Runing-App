//
//  Route.swift
//  GrainChain
//
//  Created by Brian Baragar on 20/07/20.
//  Copyright © 2020 Brian Baragar. All rights reserved.
//

import RealmSwift
import CoreLocation

class Route: Object {
    @objc dynamic var idRoute: Int = 0
    @objc dynamic var name: String =  ""
    @objc dynamic var distance: String = ""
    @objc dynamic var time: String = ""
    let latitudes = List<Double>()
    let longitudes = List<Double>()
    
    override static func primaryKey() -> String? {
        return "idRoute"
    }
}
