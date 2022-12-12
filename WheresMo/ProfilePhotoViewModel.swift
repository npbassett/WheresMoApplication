//
//  ProfilePhotoViewModel.swift
//  WheresMo
//
//  Created by Neil Bassett on 12/12/22.
//

import CryptoKit
import FirebaseStorage
import Foundation
import Kingfisher

@MainActor class ProfilePhotoViewModel: ObservableObject {
    let email: String
    
    @Published var profilePhotoLoadingState = ProfilePhotoLoadingState.loading
    @Published var profilePhotoToShow: KFImage? = nil
    
    init(email: String) {
        self.email = email
    }
    
    /// Fetches the profile photo of the user from either Firebase Storage or the local cache (using Kingfisher).
    ///
    /// - returns: None
    func fetchProfilePhoto() async {
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
    
    /// When a user updates their profile photo, this function saves the photo to Firebase Storage.
    ///
    /// - parameter data: photo data to save.
    /// - returns: None
    func saveProfilePhoto(data: Data) async {
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
    
    /// Removes user's profile photo from the Kingfisher local image cache. This function should be called after a new profile
    /// photo is saved to Firebase so that the new photo can be fetched and re-cached.
    ///
    /// - returns: None
    func clearProfilePhotoCache() async {
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
        await saveProfilePhoto(data: newProfilePhotoData)
        await clearProfilePhotoCache()
        // Wait 1 second before fetching new profile photo from Firebase Storage. I found that if I didn't
        // allow any time here, Firebase would return old profile photo, not the newly saved one.
        try await Task.sleep(for: .seconds(1))
        await fetchProfilePhoto()
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
