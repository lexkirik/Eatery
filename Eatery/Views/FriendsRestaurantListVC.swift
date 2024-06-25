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
        locationManager.delegate = self
        mapView.delegate = self
        placesClient = GMSPlacesClient.shared()
        
        
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        setTableViewConstraints()
        view.backgroundColor = .white
        
        setMapView()
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
        
        
        let mapCenter = CLLocationCoordinate2DMake(latitude, longitude)
        let marker = GMSMarker(position: mapCenter)
        
        marker.icon = UIImage(systemName: "fork.knife.circle.fill")
        marker.title = FriendsInRestaurantNow.friends[indexPath.row]
        marker.snippet = FriendsInRestaurantNow.restauraunts[indexPath.row]
        marker.map = mapView
        print(longitude, latitude)
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
                    self.mapView.reloadInputViews()
                }
            }
        }
    }
    
    // MARK: - MapView functions
    
    private func setMapView() {
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(
            withLatitude: latitude,
            longitude: longitude,
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
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(
            withLatitude: latitude,
            longitude: longitude,
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
