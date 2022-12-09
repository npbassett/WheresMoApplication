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
    @Published var profilePhotoLoadingState = LoadingState.loading
    @Published var profilePhotoToShow: KFImage? = nil
    
    init(userToShow: User, userLoggedIn: User, navigatedFromMainView: Bool) {
        self.userToShow = userToShow
        self.userLoggedIn = userLoggedIn
        self.navigatedFromMainView = navigatedFromMainView
    }
    
    var userLoggedInProfile: Bool {
        return userToShow == userLoggedIn && navigatedFromMainView
    }
    
    func fetchLocationsByUser(user: User) async {
        locationsPlacedByUser.removeAll(keepingCapacity: false)
        
        let db = Firestore.firestore()
        let locationsCollectionRef = db.collection("Locations")
        let query = locationsCollectionRef.whereField("placedByEmail", isEqualTo: user.email).limit(to: 6)
        
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
    
    func clearProfilePhotoCache(email: String) async {
        let emailHash = SHA256.hash(data: Data(email.utf8))
        let emailHashString = emailHash.compactMap { String(format: "%02x", $0) }.joined()
        ImageCache.default.removeImage(forKey: emailHashString, fromMemory: true, fromDisk: true)
    }
}
