//
//  MainViewModel.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/12/22.
//

import CryptoKit
import Firebase
import FirebaseStorage
import Foundation
import MapKit
import SwiftUI

@MainActor class MainViewModel: ObservableObject {
    var userLoggedIn: User
    
    @Published var locations = [Location]()
    @Published var userTrackingMode: MapUserTrackingMode = .follow
    @Published var selectedPlaceToDetail: Location?
    @Published var selectedPlaceToEdit: Location?
    @Published var isPlacingPin = false
    @Published var isLoadingLocations = false
    
    private var lastDocumentSnapshot: DocumentSnapshot?
            
    init(userLoggedIn: User) {
        self.userLoggedIn = userLoggedIn
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
    
    /// Fetches locations from Firebase Firestore. Each time this function is called, it appends the fetched locations to
    /// the locations array. The number of locations fetched each time the function is called can be changed through
    /// the `numLocationsToFetch` argument.
    ///
    /// Each time this function is called, `lastDocumentSnapshot` is updated. The next time the function
    /// is called, the query begins from `lastDocumentSnapshot`. This functionality is used to implement
    /// infinite scrolling in `FeedView`.
    ///
    /// - parameter numLocationsToFetch: number of new locations to fetch when this function is called.
    /// - returns: None
    func fetchLocations(numLocationsToFetch: Int = 4) async {
        var query: Query
        
        guard !isLoadingLocations else { return }
        
        isLoadingLocations = true
        let db = Firestore.firestore()
        let locationsCollectionRef = db.collection("Locations")
        if let nextStartingSnapshot = self.lastDocumentSnapshot {
            query = locationsCollectionRef.order(by: "timestamp", descending: true).start(afterDocument: nextStartingSnapshot).limit(to: numLocationsToFetch)
        } else {
            query = locationsCollectionRef.order(by: "timestamp", descending: true).limit(to: numLocationsToFetch)
        }
        
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
                    
                    self.locations.append(location)
                    self.isLoadingLocations = false
                }
                
                self.lastDocumentSnapshot = snapshot.documents.last
            }
        }
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
            self.locations.insert(location, at: 0)
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
