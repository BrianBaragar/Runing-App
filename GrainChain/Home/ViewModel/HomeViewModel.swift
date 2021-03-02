//
//  HomeViewModel.swift
//  GrainChain
//
//  Created by Brian Baragar on 19/07/20.
//  Copyright © 2020 Brian Baragar. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import CoreLocation

class HomeViewModel {
    private weak var view: HomeView?
    private var router: HomeRouter?
    var database: Database?
    var notificationtToken: NotificationToken? = nil
    
    func bind(view: HomeView, router: HomeRouter){
        self.view = view
        self.router = router
        self.router?.setSourceView(view)
    }
    
    func saveRoute(name: String, time: String, coordinates: [CLLocationCoordinate2D]){
        let distanceDouble = getDistance(initialLocation: (lat: Double(coordinates.first!.latitude), lon: Double(coordinates.first!.longitude)), endLocation: (lat: Double(coordinates.last!.latitude), lon: Double(coordinates.last!.longitude)))
        let distance = String(format: "%.3f", distanceDouble!)
        let route = Route()
        route.name = name
        route.distance = distance
        route.time = time
        for coord in coordinates{
            route.latitudes.append(coord.latitude)
            route.longitudes.append(coord.longitude)
        }
        database?.createrOrUpdate(route: route)
    }
    
    func getDistance(initialLocation: (lat: Double, lon: Double), endLocation: (lat: Double, lon: Double)) -> Double? {
        let initial = CLLocation(latitude: initialLocation.lat, longitude: initialLocation.lon)
        let final = CLLocation(latitude: endLocation.lat, longitude: endLocation.lon)
        let distance = final.distance(from: initial) / 1000
        return distance
    }
    
    func deleteRoute(routeId: Int){
        database?.delete(routeId: routeId)
    }
    
    init() {
        database = Database.singleton
    }
    
    func connectToDataBase() -> Observable<[Route]>{
        let itemRoutes = database?.fetch()
        return Observable.create{ observer in
            self.notificationtToken = itemRoutes?.observe({ [weak self] (changes: RealmCollectionChange) in
                var routesList = [Route]()
                itemRoutes?.forEach({ (itemRouteIdentity) in
                    routesList.append(itemRouteIdentity)
                })
                observer.onNext(routesList)
            })
            //observer.onCompleted()
            return Disposables.create()
        }
    }
    
    
    func makeDetailView(routeId: Int){
        router?.navigateToDetailView(routeId: routeId)
    }
    
    deinit {
        notificationtToken?.invalidate()
    }
}
