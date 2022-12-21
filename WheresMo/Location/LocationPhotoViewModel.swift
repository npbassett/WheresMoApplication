//
//  LocationPhotoViewModel.swift
//  WheresMo
//
//  Created by Neil Bassett on 12/11/22.
//

import FirebaseStorage
import Foundation
import Kingfisher

@MainActor class LocationPhotoViewModel: ObservableObject {
    let id: UUID
    
    @Published var locationPhotoLoadingState = LocationPhotoLoadingState.loading
    @Published var photoToShow: KFImage? = nil
    
    init(id: UUID) {
        self.id = id
    }
    
    /// Fetches location image from Firebase Storage database. Displays image within a Kingfisher KFImage, which
    /// automatically caches images on disk and in memory.
    ///
    /// - parameter id: UUID identifying the location that the photo is associated with.
    /// - returns: None
    func fetchLocationPhoto() async {
        let ref = Storage.storage().reference(withPath: "images/\(id.uuidString).jpg")
        ref.downloadURL { url, error in
            if let error {
                print("Error fetching image: \(error.localizedDescription)")
                self.locationPhotoLoadingState = .failed
            } else {
                self.photoToShow = KFImage(url!)
                self.locationPhotoLoadingState = .loaded
            }
        }
    }
}

/// Enum describing the loading state of location photo stored in Firebase.
///
/// - loading: In the process of retrieving photo from either Firebase or local cache
/// - loaded: Successfully retrieved photo from either Firebase or local cache
/// - failed: Could not retrieve photo from either Firebase or local cache
///
/// - Note: If loading state is .failed, this is usually because a photo has not been stored in Firebase under the location's UUID.
enum LocationPhotoLoadingState {
    case loading, loaded, failed
}
