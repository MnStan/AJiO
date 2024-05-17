//
//  LocationManager.swift
//  AJiO
//
//  Created by Maksymilian Stan on 16/05/2024.
//

import SwiftUI
import MapKit

final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private let circleRadius: CLLocationDistance = 1000
    private let numberOfPointsOnCircle = 5
    
    @Published var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.049683, longitude: 19.944544),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    ))
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var state: String?
    @Published private var surroundingVoivodeships: [String] = []
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.setup()
    }
    
    func setup() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    func getVoivodeship(from location: CLLocation){
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard error == nil else {
                print("Error retrieving location info: \(error!.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                if let state = placemark.administrativeArea {
                    self.state = state
                } else {
                    self.state = "Nie można odczytać województwa"
                }
            } else {
                self.state = "Nie można odczytać województwa"
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
                center: $0.coordinate,
                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
            
            userLocation = $0.coordinate
            getVoivodeship(from: CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude))
        }
    }
}
