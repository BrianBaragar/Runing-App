//
//  HomeRouter.swift
//  GrainChain
//
//  Created by Brian Baragar on 19/07/20.
//  Copyright © 2020 Brian Baragar. All rights reserved.
//

import Foundation
import UIKit
class HomeRouter {
     var viewController: UIViewController{
        return createViewController()
    }
    private var sourceView: UIViewController?
    
    func setSourceView(_ sourceView: UIViewController?){
        guard let view = sourceView else {fatalError("Error desconocido")}
        self.sourceView = view
    }
    
    private func createViewController() -> UIViewController{
        let view = HomeView(nibName: "HomeView", bundle: Bundle.main)
        return view
    }
    
    func navigateToDetailView(routeId: Int){
        let detailView = DetailRouter(routeId: routeId).viewController
        sourceView?.navigationController?.pushViewController(detailView, animated: true)
    }
}

