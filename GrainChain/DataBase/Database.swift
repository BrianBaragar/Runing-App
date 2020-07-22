//
//  Database.swift
//  GrainChain
//
//  Created by Brian Baragar on 20/07/20.
//  Copyright © 2020 Brian Baragar. All rights reserved.
//

import RealmSwift
import RxSwift

class Database {
    static let singleton = Database()
    private init(){}
    
    func createrOrUpdate(route: Route){
        let realm = try! Realm()
        var routeId: Int? = 1
        if let lastEntity = realm.objects(Route.self).last{
            routeId = lastEntity.idRoute + 1
        }
        let routeEntity = route
        routeEntity.idRoute = routeId!
        routeEntity.name = route.name
        routeEntity.distance = route.distance
        routeEntity.time = route.time
        for latitudes in route.latitudes{
            routeEntity.latitudes.append(latitudes)
        }
        for longitudes in route.longitudes{
            routeEntity.longitudes.append(longitudes)
        }
        try! realm.write {
            realm.add(routeEntity)
        }
    }
    
    func fetch() -> (Results<Route>){
        let realm = try! Realm()
        
        let routesItemsResult = realm.objects(Route.self)
        
        return routesItemsResult
    }
    
    func fetchUnique(routeId: Int) -> (Results<Route>){
        let realm = try! Realm()
        let routeItemResult = realm.objects(Route.self).filter("idRoute == \(routeId)")
        return routeItemResult
    }
    
    func delete(routeId: Int){
        let realm = try! Realm()
        print(routeId)
        if let routeEntity = realm.object(ofType: Route.self, forPrimaryKey: routeId){
            try! realm.write{
                print(routeEntity)
                realm.delete(routeEntity)
            }
        }
    }
}
