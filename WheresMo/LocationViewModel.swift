//
//  LocationViewModel.swift
//  WheresMo
//
//  Created by Neil Bassett on 12/11/22.
//

import Firebase
import FirebaseStorage
import Foundation
import Kingfisher

@MainActor class LocationViewModel: ObservableObject {
    let location: Location
    let userLoggedIn: User
    // Closure passed to onDeleteLocation should remove location from list of
    // locations stored in MainViewModel.
    let onDeleteLocation: () -> Void
    // Closure passed to onDeleteLocation should add location to list of
    // locations stored in MainViewModel.
    let onSaveLocation: (Location) -> Void
    
    @Published var locationPhotoLoadingState = LocationPhotoLoadingState.loading
    @Published var photoToShow: KFImage? = nil
    
    init(location: Location, userLoggedIn: User, onDeleteLocation: @escaping () -> Void, onSaveLocation: @escaping (Location) -> Void) {
        self.location = location
        self.userLoggedIn = userLoggedIn
        self.onDeleteLocation = onDeleteLocation
        self.onSaveLocation = onSaveLocation
    }
    
    var ableToEdit: Bool {
        return userLoggedIn.email == location.placedByUser.email
    }
    
    /// Saves new location information to Firebase Firestore database.
    ///
    /// - parameter location: Location to be saved
    /// - returns: None
    func saveLocation(location: Location) async {
        let db = Firestore.firestore()
        let ref = db.collection("Locations").document(location.id.uuidString)
        let _ = ref.setData(["id": location.id.uuidString,
                     "placedByEmail": location.placedByUser.email,
                     "placedByDisplayName": location.placedByUser.displayName,
                     "latitude": location.latitude,
                     "longitude": location.longitude,
                     "landmark": location.landmark,
                     "timestamp": location.date.timeIntervalSince1970,
                     "description": location.description
                    ]
        ) { error in
            if let error {
                print("Error saving location:", error.localizedDescription)
            } else {
                self.onSaveLocation(location)
                print("Location saved successfully!")
            }
        }
    }
    
    /// Deletes location information from Firebase Firestore database.
    ///
    /// - parameter location: Location to be deleted
    /// - returns: None
    ///
    /// - Note: Upon deleting location from Firebase Firestore, the `onDeleteLocation` function is run. This
    ///         function should remove the location from the locations list stored in `MainViewModel` so that
    ///         the deleted location is no longer shown in the feed or on the map.
    func deleteLocation(location: Location) async {
        let db = Firestore.firestore()
        let _ = db.collection("Locations").document(location.id.uuidString).delete() { error in
            print("Deleting location...")
            if let error {
                print("Error deleting location from Firebase Firestore: \(error)")
            } else {
                print("Successfully deleted location from Firebase Firestore!")
                self.onDeleteLocation()
            }
        }
    }
    
    /// Save photo to Firebase Storage under the UUID of the location it is associated with.
    ///
    /// - parameters:
    ///     - data: Photo data to be saved.
    ///     - id: UUID identifying the location that the photo is associated with.
    /// - returns: None
    func saveLocationPhoto(data: Data, id: UUID, onCompletion: @escaping () async -> Void) async {
        let url = "gs://wheresmo-415ab.appspot.com/images/\(id.uuidString).jpg"
        let gsReference = Storage.storage().reference(forURL: url)
        gsReference.putData(data, metadata: nil) { metadata, error in
            guard metadata != nil else {
                print("Error saving image to Firebase.")
                return
            }
            Task {
                await onCompletion()
            }
        }
    }
    
    /// Deletes photo from Firebase Storage with a given UUID.
    ///
    /// - parameter id: UUID identifying the location that the photo is associated with.
    /// - returns: None
    func deleteLocationPhoto(id: UUID) async {
        let url = "gs://wheresmo-415ab.appspot.com/images/\(id.uuidString).jpg"
        let gsReference = Storage.storage().reference(forURL: url)
        gsReference.delete { error in
            if let error {
                print("Unable to delete photo: \(error.localizedDescription)")
            } else {
                print("Photo deleted successfully!")
            }
        }
    }
}
