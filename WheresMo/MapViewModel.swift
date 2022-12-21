//
//  MapViewModel.swift
//  WheresMo
//
//  Created by Neil Bassett on 12/13/22.
//

import CryptoKit
import Firebase
import FirebaseStorage
import Foundation
import MapKit
import SwiftUI

@MainActor class MapViewModel: ObservableObject {
    var userLoggedIn: User
    
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.8, longitude: -98.58),
        span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
    )
    @Published var locations = [Location]()
    @Published var userTrackingMode: MapUserTrackingMode = .follow
    @Published var selectedPlaceToDetail: Location?
    @Published var selectedPlaceToEdit: Location?
    @Published var isPlacingPin = false
    @Published var showingLocationServicesAlert = false
    @Published var locationManager = LocationManager()
        
    private var lastSearchedRegion: MKCoordinateRegion?
    
    var currentLocation: CLLocationCoordinate2D? {
        return locationManager.manager.location?.coordinate
    }
    
    /// When true, a button will be shown in MapView that fetches locations within the current
    /// map region. If the current map region has already been searched, button is not shown.
    var showingSearchAreaButton: Bool {
        guard lastSearchedRegion != nil else {
            return true
        }
        return mapRegion.center.latitude != lastSearchedRegion!.center.latitude ||
            mapRegion.center.longitude != lastSearchedRegion!.center.longitude
    }
    
    init(userLoggedIn: User) {
        self.userLoggedIn = userLoggedIn
        self.locationManager = locationManager
    }
    
    func startPlacingPin() {
        isPlacingPin = true
    }
    
    func endPlacingPin() {
        isPlacingPin = false
    }
    
    func startEditingLocation(location: Location) {
        endPlacingPin()
        selectedPlaceToEdit = location
    }
    
    func getCurrentLocationCoordinate() -> CLLocationCoordinate2D? {
        if locationManager.manager.location != nil {
            return locationManager.manager.location!.coordinate
        } else {
            showingLocationServicesAlert.toggle()
            return nil
        }
    }
    
    /// This function moves the map region such that it is centered on the user's current location and
    /// changes the span to 0.1 degrees in latitude and longitude.
    func ZoomToUserLocation() {
        if let currentLocationCoordinate = locationManager.manager.location?.coordinate {
            mapRegion = MKCoordinateRegion(center: currentLocationCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        } else {
            print("Error retrieving current location.")
            showingLocationServicesAlert.toggle()
        }
    }
    
    /// This function moves the map region such that it is centered on the user's current location.
    /// The span of the map region is not changed.
    func moveToUserLocation() {
        if let currentLocationCoordinate = locationManager.manager.location?.coordinate {
            mapRegion = MKCoordinateRegion(center: currentLocationCoordinate, span: mapRegion.span)
        } else {
            print("Error retrieving current location.")
            showingLocationServicesAlert.toggle()
        }
    }
    
    /// This function fetches locations within the current map region.
    ///
    /// Firebase only allows queries to be filtered based on one variable, so the longitude is filtered in the Firebase query
    /// and then the latitude is filtered by hand before adding each location to the locations list.
    func fetchLocationsWithinMapRegion() async {
        locations.removeAll()
        
        let longitudeMin = mapRegion.center.longitude - (mapRegion.span.longitudeDelta / 2)
        let longitudeMax = mapRegion.center.longitude + (mapRegion.span.longitudeDelta / 2)
        let latitudeMin = mapRegion.center.latitude - (mapRegion.span.latitudeDelta / 2)
        let latitudeMax = mapRegion.center.latitude + (mapRegion.span.latitudeDelta / 2)
        
        let db = Firestore.firestore()
        let locationsCollectionRef = db.collection("Locations")
        // Firebase only allows filtering queries by a single variable. I have chosen to filter
        // on longitude for the Firebase query because I think there are likely to be fewer
        // locations in the same latitude region than locations in the same longitude region.
        // Latitude filtering is done below before adding each location to the locations list.
        let query = locationsCollectionRef
            .whereField("longitude", isGreaterThan: longitudeMin)
            .whereField("longitude", isLessThan: longitudeMax)
        let _ = query.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    
                    let id = data["id"] as? String ?? UUID().uuidString
                    let placedByEmail = data["placedByEmail"] as? String ?? "Unknown Email"
                    let placedByDisplayName = data["placedByDisplayName"] as? String ?? "Unknown Name"
                    let latitude = data["latitude"] as? Double ?? 0.0
                    let longitude = data["longitude"] as? Double ?? 0.0
                    let landmark = data["landmark"] as? String ?? ""
                    let timestamp = data["timestamp"] as? Double ?? Date.now.timeIntervalSince1970
                    let date = Date(timeIntervalSince1970: timestamp)
                    let description = data["description"] as? String ?? ""
                    
                    let placedByUser = User(email: placedByEmail, displayName: placedByDisplayName)
                    
                    let location = Location(id: UUID(uuidString: id) ?? UUID(),
                                            placedByUser: placedByUser,
                                            latitude: latitude,
                                            longitude: longitude,
                                            landmark: landmark,
                                            date: date,
                                            description: description
                    )
                    
                    // Firebase only allows filtering queries by a single variable. The query above filters
                    // based on longitude, so we have to do the latitude filter here before adding
                    // the location to the locations list.
                    if location.latitude >= latitudeMin && location.latitude <= latitudeMax {
                        self.locations.append(location)
                    }
                }
            }
        }
        
        lastSearchedRegion = mapRegion
    }
    
    /// If location is in locations array, this function updates the information of that location.
    /// Otherwise, the new location is appended to the front of the locations array.
    ///
    /// - parameter location: location to update or add to locations array.
    /// - returns: None
    ///
    /// - Note: This function should be passed as the `onSaveLocation` argument when creating a new
    ///         `LocationDetailView` from `FeedView` or `MapView`.
    func updateLocationList(location: Location) {
        let index = self.locations.firstIndex(of: location)
        if index != nil {
            self.locations[index!] = location
        } else {
            self.locations.append(location)
        }
    }
    
    /// This function removes the given location from the locations Array.
    ///
    /// - parameter location: location to remove from locations array.
    /// - returns: None
    ///
    /// - Note: This function should be passed as the `onDeleteLocation` argument when creating a new
    ///         `LocationDetailView` from `FeedView` or `MapView`.
    func removeLocationFromList(location: Location) {
        if let indexToRemove = self.locations.firstIndex(of: location) {
            self.locations.remove(at: indexToRemove)
            print("Location successfully removed from locations list!")
        } else {
            print("Location was not found in locations list so it could not be deleted.")
        }
        selectedPlaceToEdit = nil
        selectedPlaceToDetail = nil
    }
}
