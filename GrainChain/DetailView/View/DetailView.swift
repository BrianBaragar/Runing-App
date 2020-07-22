//
//  DetailView.swift
//  GrainChain
//
//  Created by Brian Baragar on 20/07/20.
//  Copyright © 2020 Brian Baragar. All rights reserved.
//

import UIKit
import GoogleMaps

class DetailView: UIViewController {
    @IBOutlet weak var mapViewDetail: GMSMapView!
    @IBOutlet weak var route: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var facebookButtonShare: UIButton!
    @IBOutlet weak var twitterButtonShare: UIButton!
    @IBOutlet weak var whatsappButtonShare: UIButton!
    @IBOutlet weak var deleteButon: UIButton!

    private var router = DetailRouter()
    private var viewModel = DetailViewModel()
    var routeObject = Route()
    var routeId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showRouteData()
        viewModel.bind(view: self, router: router)
        setupUI()
        setId(idRoute: routeId!)
        conectToDataBase()
        deleteButon.addTarget(self, action: #selector(self.deleteRoute), for: .touchUpInside)
        facebookButtonShare.addTarget(self, action: #selector(self.share), for: .touchUpInside)
        twitterButtonShare.addTarget(self, action: #selector(self.share), for: .touchUpInside)
        whatsappButtonShare.addTarget(self, action: #selector(self.share), for: .touchUpInside)
    }
    
    private func setupUI(){
        deleteButon.layer.cornerRadius = 10
    }
    
    @objc func deleteRoute(){
        viewModel.deleteRoute()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func share(){
        let activityController = UIActivityViewController(activityItems: ["En mi ruta :",routeObject.name, "Distancia :", routeObject.distance, "Tiempo :", routeObject.time], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    func setId(idRoute: Int){
        viewModel.getId(idRoute: routeId!)
    }
    
    func getData(route: Route){
        self.routeObject = route
    }
    
    func conectToDataBase(){
        viewModel.getData()
    }
    
    private func showRouteData(){
        DispatchQueue.main.async {
            self.route.text = self.routeObject.name
            self.distance.text = self.routeObject.distance
            self.time.text = self.routeObject.time
            self.addMarksToMap()
        }
    }
}
//MARK: - Google Maps
extension DetailView{
    private func addMarksToMap(){
        var coordinates: [CLLocationCoordinate2D] = []
        for lat in routeObject.latitudes{
            for lon in routeObject.longitudes{
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                coordinates.append(coordinate)
            }
        }
        let initialLocation =  CLLocationCoordinate2DMake(routeObject.latitudes.first!, routeObject.longitudes.first!)
        let endLocation = CLLocationCoordinate2DMake(routeObject.latitudes.last!, routeObject.longitudes.last!)
        self.mapViewDetail.camera =  GMSCameraPosition(latitude:initialLocation.latitude , longitude: initialLocation.longitude, zoom: 15)
        createInitialLocationMark(initial: initialLocation)
        createEndlLocationMark(end: endLocation)
        addLinesToMap(locations: coordinates)
    }
    private func createInitialLocationMark(initial: CLLocationCoordinate2D){
        let marker = GMSMarker(position: initial)
        marker.title = "Inicio"
        marker.appearAnimation = .pop
        marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1))
        marker.map = self.mapViewDetail
    }
    private func createEndlLocationMark(end: CLLocationCoordinate2D){
        let marker = GMSMarker(position: end)
        marker.title = "Final"
        marker.appearAnimation = .pop
        marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1))
        marker.map = self.mapViewDetail
    }
    
    private func addLinesToMap(locations: [CLLocationCoordinate2D]){
        DispatchQueue.main.async {
            let path = GMSMutablePath()
            path.add(locations.first!)
            path.add(locations.last!)
            //Existe un problema cuando la ruta no está en linea recta
            //La forma de corregirlo es hacer una petición a google junto con los "locations" este nos devuelve un
            //dato que es posible manejarlo con el GMSPolyLine pero al intentarlo por la cantidad de locations no es buena idea
            //Al dejar este for se hace un cuatrado con la ruta aproximada
//            for coor in locations{
//                path.add(coor)
//            }
            let line = GMSPolyline(path: path)
            line.strokeColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
            line.strokeWidth = 5.0
            line.map = self.mapViewDetail
        }
    }
}
