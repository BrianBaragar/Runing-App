//
//  DetailViewModel.swift
//  GrainChain
//
//  Created by Brian Baragar on 20/07/20.
//  Copyright © 2020 Brian Baragar. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

class DetailViewModel {
    private var database: Database?
    private weak var view: DetailView?
    private var router: DetailRouter?
    var routeId: Int = 0
    var route = Route()
    var notificationToken: NotificationToken? = nil
    
    func bind(view: DetailView, router: DetailRouter){
        self.view = view
        self.router = router
    }
    
    func getId(idRoute:Int){
        self.routeId = idRoute
    }
    
    func deleteRoute(){
        database?.delete(routeId: routeId)
        notificationToken?.invalidate()
    }
    
    func getData(){
        database =  Database.singleton
        let itemRoute = database?.fetchUnique(routeId: routeId)
        notificationToken = itemRoute?.observe({ [weak self] (changes: RealmCollectionChange) in
            switch(changes){
            case .initial:
                itemRoute?.forEach({ (itemRouteIdentity) in
                    let itemRoute = itemRouteIdentity
                    self!.view?.getData(route: itemRoute)
                })
                break
            case .update(_, let deletions, _,_):
                deletions.forEach { (index) in
                    print("Dato borrado")
                }
                break
            case .error(_):
                print("Error en base de datos")
                break
            }
        })
    }
    
    init() {}
    deinit {
        notificationToken?.invalidate()
    }
}
