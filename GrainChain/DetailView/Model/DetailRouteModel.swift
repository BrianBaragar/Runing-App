//
//  DetailRouteModel.swift
//  GrainChain
//
//  Created by Brian Baragar on 20/07/20.
//  Copyright © 2020 Brian Baragar. All rights reserved.
//

import Foundation
import RealmSwift

class DetailRouteModel: Object {
    @objc dynamic var idRoute: Int = 0
    @objc dynamic var name: String =  ""
    @objc dynamic var distance: String = ""
    @objc dynamic var time: String = ""
}
