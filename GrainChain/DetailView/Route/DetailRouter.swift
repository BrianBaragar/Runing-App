//
//  DetailRouter.swift
//  GrainChain
//
//  Created by Brian Baragar on 20/07/20.
//  Copyright © 2020 Brian Baragar. All rights reserved.
//

import UIKit
class DetailRouter {
     var viewController: UIViewController{
        return createViewController()
    }
    var routeId: Int?
    private var sourceView: UIViewController?
    
    init(routeId: Int? = nil) {
        self.routeId = routeId
    }
    
    func setSourceView(_ sourceView: UIViewController?){
        guard let view = sourceView else {fatalError("Error desconocido")}
        self.sourceView = view
    }
    
    private func createViewController() -> UIViewController{
        let view = DetailView(nibName: "DetailView", bundle: Bundle.main)
        view.routeId = routeId
        return view
    }
    
}
