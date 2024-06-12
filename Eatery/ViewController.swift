//
//  ViewController.swift
//  Eatery
//
//  Created by Test on 30.05.24.
//

import UIKit
import SnapKit
import CoreLocation
import FirebaseAuth
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteResultsViewControllerDelegate {
    
    // MARK: - Constants
    
    private var mapView = GMSMapView()
    private var placesClient = GMSPlacesClient()
    private var preciseLocationZoomLevel: Float = 17.0
    private var approximateLocationZoomLevel: Float = 10.0
    private let infoMarker = GMSMarker()
    private var resultsViewController: GMSAutocompleteResultsViewController?
    private var searchController: UISearchController?
    private var resultView: UITextView?
    private var currentLocation: CLLocation?
    
    private var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        return locationManager
    }()
    
    private let userMenuButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("U", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 34)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.frame.size.width = 50
        button.frame.size.height = 50
        button.layer.cornerRadius = button.frame.size.width / 2.0
        button.clipsToBounds = true
        button.backgroundColor = .blue
        return button
    }()
    
    private let searchBarView: UIView = {
        let subView = UIView()
        return subView
    }()
    
    private var searchFilter: GMSAutocompleteFilter = {
        let filter = GMSAutocompleteFilter()
        filter.countries = ["US"]
        filter.types = ["restaurant", "cafe"]
        return filter
    }()
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        setMapView()
        mapView.delegate = self

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        searchBarView.addSubview((searchController?.searchBar)!)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        let center = CLLocationCoordinate2DMake(currentLocation?.coordinate.latitude ?? GlobalConstants.defaultLocation.coordinate.latitude, currentLocation?.coordinate.longitude ?? GlobalConstants.defaultLocation.coordinate.longitude)
        let radius = 5000.0
        searchFilter.locationBias = GMSPlaceCircularLocationOption(center, radius)
        
        resultsViewController?.autocompleteFilter = searchFilter
        
        mapView.gestureRecognizers?.removeAll()
        mapView.addSubview(searchBarView)
        setSearchBarViewConstraints()
        view.addSubview(userMenuButton)

        setUserMenu()
        setUserMenuButtonConstraints()
        mapView.isHidden = true
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
        options.frame = view.bounds
        
        mapView = GMSMapView(options: options)
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        mapView.settings.scrollGestures = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.frame = view.bounds
        view.addSubview(mapView)
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
    
    // MARK: - Marker functions
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        infoMarker.snippet = nil
        infoMarker.position = location
        infoMarker.title = name
        infoMarker.icon = UIImage(systemName: "fork.knife.circle.fill")
        infoMarker.opacity = 0
        infoMarker.infoWindowAnchor.y = 1
        RestaurantInfoModel.name = infoMarker.title ?? ""
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let VC = RestaurantInfoVC()
        VC.modalPresentationStyle = .popover
        VC.modalTransitionStyle = .crossDissolve
        present(VC, animated: true, completion: nil)
    }
    
    // MARK: - Search functions
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        
        func updateLocation(finished: () -> Void) {
            locationManager(CLLocationManager(), didUpdateLocations: [CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)])
            
            infoMarker.snippet = place.editorialSummary
            infoMarker.position = place.coordinate
            infoMarker.title = place.name
            infoMarker.icon = UIImage(systemName: "fork.knife.circle.fill")
            infoMarker.opacity = 0
            infoMarker.infoWindowAnchor.y = 1
            infoMarker.map = mapView
            mapView.selectedMarker = infoMarker
            
            RestaurantInfoModel.name = place.name ?? "no information"
            RestaurantInfoModel.address = place.formattedAddress ?? "no information"
            RestaurantInfoModel.openingHours = place.openingHours?.description ?? "no information"
            RestaurantInfoModel.website = place.website?.description ?? "no information"
            RestaurantInfoModel.phoneNumber = place.phoneNumber ?? "no information"
            RestaurantInfoModel.description = place.editorialSummary ?? ""
            RestaurantInfoModel.priceLevel = String(place.priceLevel.rawValue)
            RestaurantInfoModel.rating = String(place.rating)
            finished()
        }
        updateLocation {
            mapView.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: any Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    private func setSearchBarViewConstraints() {
        searchBarView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(50)
            make.leading.equalToSuperview()
            make.size.height.equalTo(30)
        }
    }
    
    // MARK: - User menu functions
    
    private func setUserMenuButtonConstraints() {
        userMenuButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(120)
            make.trailing.equalToSuperview().offset(-15)
            make.size.width.equalTo(50)
        }
    }
    
    private func setUserMenu() {
        
        let myFriendsInfo = UIAction(title: "My friends") { _ in
            let destinationVC = FriendsRestaurantListVC()
            destinationVC.modalPresentationStyle = .fullScreen
            destinationVC.modalTransitionStyle = .crossDissolve
            self.present(destinationVC, animated: true)
        }
        
        let settings = UIAction(title: "Settings") { _ in
            
        }
        
        let logOut = UIAction(title: "Log out") { _ in
            do {
                try Auth.auth().signOut()
                let destinationVC = SignUpViewController()
                destinationVC.modalPresentationStyle = .fullScreen
                destinationVC.modalTransitionStyle = .crossDissolve
                self.present(destinationVC, animated: true)
            } catch {
                print(error)
            }
        }
        
        let userMenu = UIMenu(title: "User", children: [myFriendsInfo, settings, logOut])
        userMenuButton.menu = userMenu
        userMenuButton.showsMenuAsPrimaryAction = true
        userMenuButton.addTarget(nil, action: #selector(userMenuButtonClicked), for: .menuActionTriggered)
    }
    
    @objc func userMenuButtonClicked() {
        
    }

}

