//
//  FriendsRestaurantListVC.swift
//  Eatery
//
//  Created by Test on 10.06.24.
//

import UIKit
import SnapKit
import FirebaseFirestore
import CoreLocation
import GoogleMaps
import GooglePlaces

class FriendsRestaurantListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate, CLLocationManagerDelegate {

    // MARK: - Constants
    
    private var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(FriendsTableViewCell.self, forCellReuseIdentifier: FriendsTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = true
        return table
    }()
    
    private var models = [FriendRestaurantOption]()
    
    private var mapView = GMSMapView()
    private var placesClient = GMSPlacesClient()
    private var preciseLocationZoomLevel: Float = 17.0
    private var approximateLocationZoomLevel: Float = 10.0
    private let marker = GMSMarker()
    private var currentLocation: CLLocation?
    
    private var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        return locationManager
    }()
    
    private var longitude = GlobalConstants.defaultLocation.coordinate.longitude
    private var latitude = GlobalConstants.defaultLocation.coordinate.latitude
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromFirestore()
        
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        setTableViewConstraints()
        view.backgroundColor = .white
        
        locationManager.delegate = self
        placesClient = GMSPlacesClient.shared()
        setMapView()
        mapView.delegate = self
        
        mapView.isHidden = true
    }
    
    // MARK: - TableView functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendsTableViewCell.identifier, for: indexPath) as? FriendsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: model)
        return cell
    }
    
    private func setTableViewConstraints() {
        tableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().dividedBy(3)
            make.width.equalToSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        longitude = FriendsInRestaurantNow.longitudes[indexPath.row]
        latitude = FriendsInRestaurantNow.latitudes[indexPath.row]
        mapView.camera = GMSCameraPosition(
            latitude: latitude,
            longitude: longitude,
            zoom: locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        )
    }
    
    // MARK: - Firestore functions
    
    private func getDataFromFirestore() {
        FriendsInRestaurantNow.friends.removeAll()
        FriendsInRestaurantNow.restauraunts.removeAll()
        FriendsInRestaurantNow.longitudes.removeAll()
        FriendsInRestaurantNow.latitudes.removeAll()
        
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("Restaurants").addSnapshotListener { snapshot, error in
            
            if error != nil {
                print(error?.localizedDescription ?? "error")
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    for document in snapshot!.documents {
                        
                        if let name = document.get("friendName") as? String, let rest = document.get("restaurant") as? String {
                            if name != CurrentUser.username {
                                FriendsInRestaurantNow.friends.append(name)
                                FriendsInRestaurantNow.restauraunts.append(rest)
                                
                            }
                        }
                        
                        if let longitude = document.get("longitude") as? Double, let latitude = document.get("latitude") as? Double {
                            FriendsInRestaurantNow.longitudes.append(longitude)
                            FriendsInRestaurantNow.latitudes.append(latitude)
                        }
                    }

                    for number in 0...FriendsInRestaurantNow.friends.count - 1 {
                        self.models.append(FriendRestaurantOption(
                            name: FriendsInRestaurantNow.friends[number],
                            restaurant: FriendsInRestaurantNow.restauraunts[number]
                        ))
                    }
                    self.tableView.reloadData()
                    
                    var bounds = GMSCoordinateBounds.init()
                    for num in 0...FriendsInRestaurantNow.friends.count - 1 {
                        let mapCenter = CLLocationCoordinate2DMake(FriendsInRestaurantNow.latitudes[num], FriendsInRestaurantNow.longitudes[num])
                        let marker = GMSMarker(position: mapCenter)
                        marker.title = FriendsInRestaurantNow.friends[num]
                        marker.snippet = FriendsInRestaurantNow.restauraunts[num]
                        marker.map = self.mapView
                        bounds = bounds.includingCoordinate(marker.position)
                    }
                    var update = GMSCameraUpdate.fit(bounds)
                    self.mapView.moveCamera(update)
                }
            }
        }
    }
    
    // MARK: - MapView functions
    
    private func setMapView() {
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(
            withLatitude: GlobalConstants.defaultLocation.coordinate.latitude,
            longitude: GlobalConstants.defaultLocation.coordinate.longitude,
            zoom: zoomLevel
        )
        
        mapView = GMSMapView(options: options)
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        mapView.settings.scrollGestures = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tableView.snp.bottom)
            make.height.equalToSuperview().dividedBy(1.5)
            make.width.equalToSuperview()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last ?? GlobalConstants.defaultLocation
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(
            withLatitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: zoomLevel
        )
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
