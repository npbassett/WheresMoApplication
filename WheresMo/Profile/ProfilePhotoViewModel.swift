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
    
    /// Removes user's profile photo from the Kingfisher local image cache. This function should be called after a new profile
    /// photo is saved to Firebase so that the new photo can be fetched and re-cached.
    ///
    /// - returns: None
    func clearProfilePhotoCache() async {
        let emailHash = SHA256.hash(data: Data(email.utf8))
        let emailHashString = emailHash.compactMap { String(format: "%02x", $0) }.joined()
        ImageCache.default.removeImage(forKey: emailHashString, fromMemory: true, fromDisk: true)
    }
    
    /// When a user updates their profile photo, this function saves the photo to Firebase Storage. Upon completion
    /// of the upload to Firebase, old photo is cleared from cache and new one is fetched.
    ///
    /// - parameter data: photo data to save.
    /// - returns: None
    func saveProfilePhoto(data: Data) async {
        self.profilePhotoLoadingState = .loading
        
        let emailHash = SHA256.hash(data: Data(email.utf8))
        let emailHashString = emailHash.compactMap { String(format: "%02x", $0) }.joined()
        let url = "gs://wheresmo-415ab.appspot.com/profilePhotos/\(emailHashString).jpg"
        
        let gsReference = Storage.storage().reference(forURL: url)
        gsReference.putData(data, metadata: nil) { metadata, error in
            guard metadata != nil else {
                print("Error saving image to Firebase.")
                self.profilePhotoLoadingState = .loaded
                return
            }
            Task {
                await self.clearProfilePhotoCache()
                await self.fetchProfilePhoto()
            }
        }
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
