//
//  ProfileViewModel.swift
//  WheresMo
//
//  Created by Neil Bassett on 12/9/22.
//

import CryptoKit
import Firebase
import FirebaseStorage
import Foundation
import Kingfisher
import SwiftUI

@MainActor class ProfileViewModel: ObservableObject {
    var userToShow: User
    var userLoggedIn: User
    var navigatedFromMainView: Bool
    
    @Published var locationsPlacedByUser = [Location]()
    
    init(userToShow: User, userLoggedIn: User, navigatedFromMainView: Bool) {
        self.userToShow = userToShow
        self.userLoggedIn = userLoggedIn
        self.navigatedFromMainView = navigatedFromMainView
    }
    
    var userLoggedInProfile: Bool {
        return userToShow == userLoggedIn && navigatedFromMainView
    }
    
    /// Fetches locations placed by the user from Firebase Firestore and puts them in `locationsPlacedByUser` array.
    ///
    /// - returns: None
    func fetchLocationsPlacedByUser() async {
        locationsPlacedByUser.removeAll(keepingCapacity: false)
        
        let db = Firestore.firestore()
        let locationsCollectionRef = db.collection("Locations")
        let query = locationsCollectionRef.whereField("placedByEmail", isEqualTo: userToShow.email).limit(to: 10)
        
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
                    
                    self.locationsPlacedByUser.append(location)
                }
            }
        }
    }
    
    /// If location is already in `locationPlacedByUser` array, this function updates the information of that location.
    /// Otherwise, the new location is appended to the front of the array.
    ///
    /// - parameter location: location to either update or add to `locationsPlacedByUser`.
    /// - returns: None
    ///
    /// - Note: This function should be passed as the `onSaveLocation` argument when creating a new
    ///         `LocationDetailView` from `ProfileView`.
    func updateLocationList(location: Location) {
        let index = self.locationsPlacedByUser.firstIndex(of: location)
        if index != nil {
            self.locationsPlacedByUser[index!] = location
        } else {
            self.locationsPlacedByUser.insert(location, at: 0)
        }
    }
    
    /// This function removes the given location from the `locationsPlacedByUser` Array.
    ///
    /// - parameter location: location to remove from `locationsPlacedByUser` array.
    /// - returns: None
    ///
    /// - Note: This function should be passed as the `onDeleteLocation` argument when creating a new
    ///         `LocationDetailView` from `ProfileView`.
    func removeLocationFromList(location: Location) {
        if let indexToRemove = self.locationsPlacedByUser.firstIndex(of: location) {
            self.locationsPlacedByUser.remove(at: indexToRemove)
            print("Location successfully removed from locationsPlacedByUser list!")
        } else {
            print("Location was not found in locationsPlacedByUser list so it could not be deleted.")
        }
    }
}
