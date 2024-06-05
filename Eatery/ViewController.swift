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

class ViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: - Constants
    private var mapView: GMSMapView!
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    private var placesClient: GMSPlacesClient!
    private var preciseLocationZoomLevel: Float = 15.0
    private var approximateLocationZoomLevel: Float = 10.0
    
    // MARK: - viewDidLoad, viewWillAppear

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
        
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(
            withLatitude: defaultLocation.coordinate.latitude,
            longitude: defaultLocation.coordinate.longitude,
            zoom: zoomLevel
        )
        options.frame = view.bounds
        mapView = GMSMapView(options: options)
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        mapView.settings.scrollGestures = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        let gestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecogniser.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecogniser)
        
        view.addSubview(mapView)
        mapView.isHidden = true
        view.addSubview(userMenuButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let myFriendsInfo = UIAction(title: "My friends") { _ in
            print("myFriendsInfo selected")
        }
        let settings = UIAction(title: "Settings") { _ in
            print("settings selected")
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
    // MARK: - Map functions
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        
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
    
    @objc private func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {

         if gestureRecognizer.state == .began {
             mapView.clear()
             
             
         }
     }
    
    // MARK: - User menu
    
    private let userMenuButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 320, y: 80, width: 50, height: 50))
        button.setTitle("U", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 34)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.layer.cornerRadius = button.frame.size.width / 2.0
        button.clipsToBounds = true
        button.backgroundColor = .blue
        return button
    }()
    
    @objc func userMenuButtonClicked() {
        print("Clicked user menu button")
    }

}

