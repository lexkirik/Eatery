//
//  ViewController.swift
//  Eatery
//
//  Created by Test on 30.05.24.
//

import UIKit
import MapKit
import SnapKit
import CoreLocation
import FirebaseAuth

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate {

    // MARK: - Constants
    
    private var locationManager = CLLocationManager()
    
    // MARK: - viewDidLoad, viewWillAppear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        setMapConstraints()
        view.addSubview(userMenuButton)
        setUserMenuButtonConstraints()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
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
                self.present(SignUpViewController(), animated: true)
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
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .dark
        return map
    }()

    private func setMapConstraints() {
        mapView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @objc private func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: mapView)
            let touchedCoordinates = mapView.convert(touchedPoint, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = "Restaurant"
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: - User menu
    
    private let userMenuButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
        button.setTitle("U", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.layer.cornerRadius = 0.5 * button.frame.width
        button.clipsToBounds = true
        button.backgroundColor = .blue
        return button
    }()
    
    private func setUserMenuButtonConstraints() {
        userMenuButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(50)
        }
    }
    
    @objc func userMenuButtonClicked() {
        print("Clicked user menu button")
    }
}

