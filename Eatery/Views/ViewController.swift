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

private enum UserMenuConstants {
    static let buttonTitle = "U"
    static let title = "User"
    static let myFriendsInfoTitle = "My friends"
    static let logOutTitle = "Log out"
}

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteResultsViewControllerDelegate {
    
    // MARK: - Constants
    
    private var mapView = GMSMapView()
    private var placesClient = GMSPlacesClient()
    private var marker = GMSMarker()
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
        button.setTitle(UserMenuConstants.buttonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 34)
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonSize = 50.0
        button.snp.makeConstraints { $0.size.width.equalTo(buttonSize) }
        button.layer.cornerRadius = buttonSize / 2.0
        button.clipsToBounds = true
        button.backgroundColor = .blue
        return button
    }()
    
    private let searcBarContainerView = UIView()
    
    private var searchFilter: GMSAutocompleteFilter = {
        let filter = GMSAutocompleteFilter()
        filter.countries = ["US"]
        filter.types = ["restaurant", "cafe"]
        return filter
    }()
    
    private var currentRestarauntInfo: RestaurantInfoModel?
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userAuth = UserAuthorizer()
        userAuth.getCurrentUserName()
        
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        setMapView()

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        searcBarContainerView.addSubview((searchController?.searchBar)!)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        resultsViewController?.autocompleteFilter = searchFilter
        
        mapView.gestureRecognizers?.removeAll()
        mapView.addSubview(searcBarContainerView)
        setSearchBarViewConstraints()
        view.addSubview(userMenuButton)

        setUserMenu()
        setUserMenuButtonConstraints()
        mapView.isHidden = true
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
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        mapView.settings.scrollGestures = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview()
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
    
    // MARK: - Marker functions
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        let placeRequest = GMSFetchPlaceRequest(placeID: placeID, placeProperties: GMSPlacePropertyArray(), sessionToken: nil)
        placesClient.fetchPlace(with: placeRequest) { (place: GMSPlace?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let place = place {
                self.addMarker(place: place)
                self.currentRestarauntInfo = RestaurantInfoModel(
                    name: place.name ?? "no information",
                    description: place.editorialSummary ?? "",
                    rating: place.rating.description,
                    priceLevel: place.priceLevel.rawValue,
                    address: place.formattedAddress ?? "no information",
                    website: place.website?.description ?? "no information",
                    phoneNumber: place.phoneNumber ?? "no information",
                    url: place.website,
                    openingHoursArray: place.openingHours?.weekdayText ?? [""],
                    coordinate: place.coordinate
                )
            }
        }
    }
    
    private func addMarker(place: GMSPlace) {
        marker.snippet = place.editorialSummary
        marker.position = place.coordinate
        marker.title = place.name
        marker.map = mapView
        mapView.selectedMarker = marker
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let VC = RestaurantInfoVC()
        VC.modalPresentationStyle = .popover
        VC.modalTransitionStyle = .crossDissolve
        VC.restaurantInfo = currentRestarauntInfo
        VC.completion?(currentRestarauntInfo ?? RestaurantInfoModel(name: "", description: "", rating: "", priceLevel: 0, address: "", website: "", phoneNumber: "", openingHoursArray: [""], coordinate: GlobalConstants.defaultLocation.coordinate))
        present(VC, animated: true, completion: nil)
    }
    
    // MARK: - Search functions
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        updateLocation(place: place) {
            mapView.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    
    private func updateLocation(place: GMSPlace, finished: () -> Void) {
        locationManager(CLLocationManager(), didUpdateLocations: [
            CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        ])
        
        addMarker(place: place)
        currentRestarauntInfo = RestaurantInfoModel(
            name: place.name ?? "no information",
            description: place.editorialSummary ?? "",
            rating: place.rating.description,
            priceLevel: place.priceLevel.rawValue,
            address: place.formattedAddress ?? "no information",
            website: place.website?.description ?? "no information",
            phoneNumber: place.phoneNumber ?? "no information",
            url: place.website,
            openingHoursArray: place.openingHours?.weekdayText ?? [""],
            coordinate: place.coordinate
        )
        finished()
    }
    
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: any Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    private func setSearchBarViewConstraints() {
        searcBarContainerView.snp.makeConstraints { make in
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
        }
    }
    
    private func setUserMenu() {
        
        let myFriendsInfo = UIAction(title: UserMenuConstants.myFriendsInfoTitle) { _ in
            let destinationVC = FriendsRestaurantListVC()
            destinationVC.modalPresentationStyle = .pageSheet
            destinationVC.modalTransitionStyle = .crossDissolve
            self.present(destinationVC, animated: true)
        }
        
        let logOut = UIAction(title: UserMenuConstants.logOutTitle) { _ in
            do {
                try Auth.auth().signOut()
                CurrentUser.shared.name = ""
                let destinationVC = SignUpViewController()
                destinationVC.modalPresentationStyle = .fullScreen
                destinationVC.modalTransitionStyle = .crossDissolve
                self.present(destinationVC, animated: true)
            } catch {
                print(error)
            }
        }
        
        let userMenu = UIMenu(title: "\(UserMenuConstants.title) \(Auth.auth().currentUser?.email ?? "")", children: [myFriendsInfo, logOut])
        userMenuButton.menu = userMenu
        userMenuButton.showsMenuAsPrimaryAction = true
    }
}
