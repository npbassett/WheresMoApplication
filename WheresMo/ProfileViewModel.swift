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
    @Published var locationsPlacedByUserPhotos = [KFImage]()
    @Published var profilePhotoLoadingState = ProfilePhotoLoadingState.loading
    @Published var profilePhotoToShow: KFImage? = nil
    
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
    
    /// When a user updates their profile photo, this function saves the photo to Firebase Storage.
    ///
    /// - parameters:
    ///     - data: photo data to save.
    ///     - email: email address associated with the user. This value is hashed and then used to store the photo in Firebase.
    /// - returns: None
    func saveProfilePhoto(data: Data, email: String) async {
        let emailHash = SHA256.hash(data: Data(email.utf8))
        let emailHashString = emailHash.compactMap { String(format: "%02x", $0) }.joined()
        let url = "gs://wheresmo-415ab.appspot.com/profilePhotos/\(emailHashString).jpg"
        
        let gsReference = Storage.storage().reference(forURL: url)
        gsReference.putData(data, metadata: nil) { metadata, error in
            guard metadata != nil else {
                print("Error saving image to Firebase.")
                return
            }
        }
    }
    
    /// Fetches the profile photo of the user from either Firebase Storage or the local cache (using Kingfisher).
    ///
    /// - parameter email: email address associated with the user.
    /// - returns: None
    func fetchProfilePhoto(email: String) async {
        profilePhotoLoadingState = .loading
        
        let emailHash = SHA256.hash(data: Data(email.utf8))
        let emailHashString = emailHash.compactMap { String(format: "%02x", $0) }.joined()
        let ref = Storage.storage().reference(withPath: "profilePhotos/\(emailHashString).jpg")
        ref.downloadURL { url, error in
            if let error {
                print("Error fetching image: \(error.localizedDescription)")
                self.profilePhotoLoadingState = .failed
            } else {
                if ImageCache.default.isCached(forKey: emailHashString) {
                    print("Profile photo is cached, fetching from local storage.")
                } else {
                    print("Profile photo is not cached, fetching from firebase.")
                }
                var resource: Resource {
                    ImageResource(downloadURL: url!, cacheKey: emailHashString)
                }
                self.profilePhotoToShow = KFImage(source: .network(resource))
                self.profilePhotoLoadingState = .loaded
            }
        }
    }
    
    /// Removes user's profile photo from the Kingfisher local image cache. This function should be called after a new profile
    /// photo is saved to Firebase so that the new photo can be fetched and re-cached.
    ///
    /// - parameter email: email address associated with the user.
    /// - returns: None
    func clearProfilePhotoCache(email: String) async {
        let emailHash = SHA256.hash(data: Data(email.utf8))
        let emailHashString = emailHash.compactMap { String(format: "%02x", $0) }.joined()
        ImageCache.default.removeImage(forKey: emailHashString, fromMemory: true, fromDisk: true)
    }
    
    /// This function saves new profile photo to Firebase, clears the local cache of the profile photo, sleeps for 1 second, then
    /// fetches the new profile photo from Firebase.
    ///
    /// If `Task.sleep` is cancelled before the time ends, this function throws `CancellationError`.
    ///
    /// - parameter newProfilePhotoData: photo data to save.
    /// - returns: None
    func onProfilePhotoChange(newProfilePhotoData: Data) async throws {
        print("Setting new profile photo.")
        await saveProfilePhoto(data: newProfilePhotoData, email: userLoggedIn.email)
        await clearProfilePhotoCache(email: userLoggedIn.email)
        // Wait 1 second before fetching new profile photo from Firebase Storage. I found that if I didn't
        // allow any time here, Firebase would return old profile photo, not the newly saved one.
        try await Task.sleep(for: .seconds(1))
        await fetchProfilePhoto(email: userLoggedIn.email)
    }
}

/// Enum describing the loading state of profile photo stored in Firebase.
///
/// - loading: In the process of retrieving photo from either Firebase or local cache
/// - loaded: Successfully retrieved photo from either Firebase or local cache
/// - failed: Could not retrieve photo from either Firebase or local cache
///
/// - Note: If loading state is .failed, this is usually because a photo has not been stored in Firebase under the user's hashed email.
enum ProfilePhotoLoadingState {
    case loading, loaded, failed
}
