//
//  LocationManager.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/13/22.
//

import CoreLocation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var mapRegion = MKCoordinateRegion()

    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }
    }
    
    func getCurrentLocationCoordinate() -> CLLocationCoordinate2D? {
        return manager.location?.coordinate
    }
    
    func resetMapRegion() {
        if let currentLocationCoordinate = manager.location?.coordinate {
            mapRegion = MKCoordinateRegion(center: currentLocationCoordinate, span: mapRegion.span)
        } else {
            print("Error getting current location.")
        }
    }
}
