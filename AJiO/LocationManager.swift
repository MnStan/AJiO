//
//  LocationManager.swift
//  AJiO
//
//  Created by Maksymilian Stan on 16/05/2024.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationData: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var position: MapCameraPosition = .userLocation(
        followsHeading: true, fallback: .automatic
    )
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var state: String?
    @Published private var surroundingVoivodeships: [String] = []
    @Published var locations: [LocationData] = []
    @Published var nearVoivodeships: Set<String> = []
    @Published var isLoadingNearVoivodeships = true
    @Published var shouldShowThrottledError = false
    
    private let geocoder = CLGeocoder()
    private let radius: CLLocationDistance = 100000 // 100 km
    private let numberOfPoints = 20
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.setup()
    }
    
    private func setup() {
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
    
    private func getVoivodeship(from location: CLLocation, completion: @escaping (String?) -> Void) {
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self else { return }
            if error != nil {
                self.shouldShowThrottledError = true
                nearVoivodeships.removeAll()
                completion(nil)
            }
            
            if let placemark = placemarks?.first, placemark.country == "Polska" {
                let voivodeship = placemark.administrativeArea
                completion(voivodeship)
            } else {
                completion(nil)
            }
        }
    }

    private func getPointsVoivodeships(from points: [LocationData], completion: @escaping ([String]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var voivodeships: [String] = []

        var delay: TimeInterval = 0.0
        for point in points {
            var leaveDispatchGroup = true
            
            dispatchGroup.enter()
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self else { return }
                self.getVoivodeship(from: CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)) { voivodeship in
                    if let voivodeship = voivodeship {
                        if voivodeship != self.state {
                            voivodeships.append(voivodeship)
                        }
                    }
                    
                    if leaveDispatchGroup {
                        dispatchGroup.leave()
                        leaveDispatchGroup = false
                    }
                }
            }
            delay += 0.5
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.isLoadingNearVoivodeships = false
            completion(voivodeships)
        }
    }
    
    func getPointsVoivodeshipsAgain() {
        isLoadingNearVoivodeships = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak self] in
            guard let self else { return }
            self.getPointsVoivodeships(from: self.locations) { voivodeships in
                self.nearVoivodeships = Set(voivodeships)
                print(self.nearVoivodeships)
            }
        }
    }
    
    private func pointsOnCircle(center: CLLocationCoordinate2D, radius: CLLocationDistance, numberOfPoints: Int) {
        var points: [LocationData] = []
        let earthRadius: CLLocationDistance = 6371000
        
        for i in 0..<numberOfPoints {
            let bearing = Double(i) * 360.0 / Double(numberOfPoints) * .pi / 180
            
            let lat1 = center.latitude * .pi / 180
            let lon1 = center.longitude * .pi / 180
            
            let lat2 = asin(sin(lat1) * cos(radius / earthRadius) + cos(lat1) * sin(radius / earthRadius) * cos(bearing))
            var lon2 = lon1 + atan2(sin(bearing) * sin(radius / earthRadius) * cos(lat1), cos(radius / earthRadius) - sin(lat1) * sin(lat2))
            
            lon2 = (lon2 + 3 * .pi).truncatingRemainder(dividingBy: 2 * .pi) - .pi
            
            let lat2Degrees = lat2 * 180 / .pi
            let lon2Degrees = lon2 * 180 / .pi
            
            points.append(LocationData(coordinate: CLLocationCoordinate2D(latitude: lat2Degrees, longitude: lon2Degrees)))
        }
        
        self.locations = points
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong: \(error.localizedDescription)")
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map { location in
            userLocation = location.coordinate
            
            getVoivodeship(from: CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)) { [weak self] voivodeship in
                guard let self else { return }
                self.state = voivodeship
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self else { return }
                pointsOnCircle(center: location.coordinate, radius: radius, numberOfPoints: numberOfPoints)
                getPointsVoivodeships(from: self.locations) { voivodeships in
                    self.nearVoivodeships = Set(voivodeships)
                    print(self.nearVoivodeships)
                }
            }
        }
    }
}
