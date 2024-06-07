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

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    // MARK: - Constants
    
    private var mapView = GMSMapView()
    private var placesClient = GMSPlacesClient()
    private var preciseLocationZoomLevel: Float = 15.0
    private var approximateLocationZoomLevel: Float = 10.0
    private let infoMarker = GMSMarker()
    
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
    
    private let placeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search"
        textField.translatesAutoresizingMaskIntoConstraints = true
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0, alpha: 0.1)
        textField.addTarget(nil, action: #selector(placeTextFieldTapped), for: .touchDown)
        return textField
    }()
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        setMapView()
        mapView.delegate = self
        mapView.isHidden = true
        
        view.addSubview(userMenuButton)
        view.addSubview(placeTextField)
        setPlaceTextFieldConstraints()
        setUserMenu()
        setUserMenuButtonConstraints()
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
        let location: CLLocation = locations.last!
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
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        infoMarker.snippet = placeID
        infoMarker.position = location
        infoMarker.title = name
        infoMarker.opacity = 0
        infoMarker.infoWindowAnchor.y = 1
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
    }
    
    // MARK: - Search textfield functions
    
    private func setPlaceTextFieldConstraints() {
        placeTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(userMenuButton.snp.top).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-90)
            make.size.height.equalTo(30)
        }
    }
    
    @objc private func placeTextFieldTapped() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        let filter = GMSAutocompleteFilter()
        filter.types = ["restaurant"]
        filter.countries = ["US"]
        autocompleteController.autocompleteFilter = filter
        
        let fields: GMSPlaceField = [.name, .placeID]
        autocompleteController.placeFields = fields
        
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if let name = place.name {
            placeTextField.text = name
        }
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: any Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - User menu functions
    
    private func setUserMenuButtonConstraints() {
        userMenuButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(70)
            make.trailing.equalToSuperview().offset(-30)
            make.leading.equalTo(placeTextField.snp.trailing).offset(10)
        }
    }
    
    private func setUserMenu() {
        
        let myFriendsInfo = UIAction(title: "My friends") { _ in
            
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

