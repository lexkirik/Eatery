//
//  FriendsRestaurantListVC.swift
//  Eatery
//
//  Created by Test on 10.06.24.
//

import UIKit
import SnapKit
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
        if models.count > 0 {
            return models.count
        } else {
            return 1
        }
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
        longitude = models[indexPath.row].longitude
        latitude = models[indexPath.row].latitude
        mapView.camera = GMSCameraPosition(
            latitude: latitude,
            longitude: longitude,
            zoom: locationManager.accuracyAuthorization == .fullAccuracy ? GlobalConstants.preciseLocationZoomLevel : GlobalConstants.approximateLocationZoomLevel
        )
    }
    
    // MARK: - Firestore functions
    
    private func getDataFromFirestore() {
        let restaurantInfoPostMaker = RestaurantInfoPostMaker()
        restaurantInfoPostMaker.getDataFromRestaurantInfoPostForLast12Hours { result in
            if result == .success {
                self.models.append(FriendRestaurantOption(
                    friendName: RestaurantInfoPostMaker.friendName,
                    restaurant: RestaurantInfoPostMaker.restaurant,
                    longitude: RestaurantInfoPostMaker.longitude,
                    latitude: RestaurantInfoPostMaker.latitude)
                )
            }
            if result == .error {
                print("Error getting data from a Firestore post")
            }
            self.tableView.reloadData()
            self.createMarkersWithinBounds()
        }
    }
    
    // MARK: - MapView functions
    
    private func setMapView() {
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? GlobalConstants.preciseLocationZoomLevel : GlobalConstants.approximateLocationZoomLevel
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
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? GlobalConstants.preciseLocationZoomLevel : GlobalConstants.approximateLocationZoomLevel
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
    
    func createMarkersWithinBounds() {
        var bounds = GMSCoordinateBounds.init()
        for num in 0...models.count - 1 {
            let mapCenter = CLLocationCoordinate2DMake(models[num].latitude, models[num].longitude)
            let marker = GMSMarker(position: mapCenter)
            marker.title = models[num].friendName
            marker.snippet = models[num].restaurant
            marker.map = mapView
            bounds = bounds.includingCoordinate(marker.position)
        }
        let update = GMSCameraUpdate.fit(bounds)
        mapView.moveCamera(update)
    }
}
