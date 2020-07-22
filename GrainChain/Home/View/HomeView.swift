//
//  HomeView.swift
//  GrainChain
//
//  Created by Brian Baragar on 19/07/20.
//  Copyright © 2020 Brian Baragar. All rights reserved.
//

import UIKit
import GoogleMaps
import RealmSwift
import RxSwift

class HomeView: UIViewController {
    @IBOutlet weak var mapViewHome: GMSMapView!
    @IBOutlet weak var tableView: UITableView!
    
    private var router = HomeRouter()
    private var viewModel = HomeViewModel()
    private let locationManager = CLLocationManager()
    private var currentLocation = CLLocationCoordinate2D()
    private var recentLocations = [CLLocationCoordinate2D]()
    private var isActiveTracking: Bool = false
    private var disposeBag = DisposeBag()
    private var routes = [Route]()
    private var time = ""
    private var counter = 0.0
    private var timer = Timer()
    
    var markButton =  UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.bind(view:self, router: router)
        addMapToView()
        configureTableView()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        routes = []
        viewModel.connectToDataBase()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupUI()
    }
    
    func getData(route : Route){
        self.routes.append(route)
        reloadTableView()
    }
    
    private func reloadTableView(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func configureTableView(){
        tableView.register(UINib(nibName: "detailCell", bundle: Bundle.main), forCellReuseIdentifier: "detailCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupUI(){
        self.navigationItem.title = "Grain Chain Test Developer"
        markButton.frame = CGRect(x: self.view.center.x - 40, y: self.view.center.y + 40, width: 80, height: 30)
        markButton.backgroundColor = #colorLiteral(red: 0.03078400157, green: 0.4549298882, blue: 0.4940516949, alpha: 1)
        markButton.setTitle("Inicio", for: .normal)
        markButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        markButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        markButton.layer.cornerRadius = 10
        markButton.layer.borderWidth = 5
        markButton.layer.borderColor = #colorLiteral(red: 0.03078400157, green: 0.4549298882, blue: 0.4940516949, alpha: 0.6304312928)
        markButton.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        self.view.addSubview(markButton)
    }
    
    @objc func buttonClicked(){
        let colorMarker = self.isActiveTracking == false ? #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1) : #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        let marker = GMSMarker()
        marker.icon = GMSMarker.markerImage(with: colorMarker)
        marker.position = currentLocation
        marker.appearAnimation = .pop
        marker.map = mapViewHome
        if isActiveTracking == true{
            alertSaveRoute()
            self.isActiveTracking = false
            self.timer.invalidate()
        }else{
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            self.isActiveTracking = true
        }
        colorButton(isActive: isActiveTracking)
    }
    
    @objc func updateTimer(){
        counter = counter + 0.1
    }
    
    func colorButton(isActive: Bool){
        let backGroundColor = isActive == true ? #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1) : #colorLiteral(red: 0.4390888214, green: 0.6784642339, blue: 0.278391242, alpha: 1)
        let borderColor: CGColor = isActive == true ? #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.3048212757) : #colorLiteral(red: 0.2174585164, green: 0.8184141517, blue: 0, alpha: 0.2913099315)
        let tittleButton = isActive == true ? "Fin": "Inicio"
        markButton.backgroundColor = backGroundColor
        markButton.setTitle(tittleButton, for: .normal)
        markButton.layer.borderColor = borderColor
    }
    
    func alertSaveRoute(){
        let alert = UIAlertController(title: "¿Nombre de la ruta?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Caminata 1"
        })

        alert.addAction(UIAlertAction(title: "Guardar", style: .default, handler: { action in

            if let name = alert.textFields?.first?.text {
                let minutes = self.counter / 60.0
                self.time = String(format: "%.2f", minutes)
                self.viewModel.saveRoute(name: name, time: self.time, coordinates: self.recentLocations)
                self.mapViewHome.clear()
                self.counter = 0.0
            }
        }))

        self.present(alert, animated: true)
    }
}

//MARK: - Google Maps
extension HomeView{
    func addMapToView(){
        mapViewHome.isMyLocationEnabled = true
        mapViewHome.settings.myLocationButton = true
    }
}

//MARK: - Location Manager Protocols
extension HomeView: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedAlways else {return}
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{return}
        mapViewHome.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        self.currentLocation = location.coordinate
        if isActiveTracking == true{
            self.recentLocations.append(location.coordinate)
            let path = GMSMutablePath()
            for coord in recentLocations{
                path.add(coord)
            }
            let line = GMSPolyline(path: path)
            line.strokeColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            line.strokeWidth = 3.0
            line.map = mapViewHome
        }
    }
}


//MARK: - Table View
extension HomeView: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height:50))
        headerView.backgroundColor = #colorLiteral(red: 0.03078400157, green: 0.4549298882, blue: 0.4940516949, alpha: 1)
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        label.text = "Rutas"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.textAlignment = .center
        headerView.addSubview(label)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell") as! detailCell
        cell.nameRoute.text = routes[indexPath.row].name
        cell.distanceRute.text = routes[indexPath.row].distance + "Km"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let idRoute = self.routes[indexPath.row].idRoute
        viewModel.makeDetailView(routeId: idRoute)
    }
}

