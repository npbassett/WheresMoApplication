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
//    @Published var locationsPlacedByUser = [Location]()
    @Published var userTrackingMode: MapUserTrackingMode = .follow
    @Published var selectedPlaceToDetail: Location?
    @Published var selectedPlaceToEdit: Location?
    @Published var placingPin = false
    @Published var isLoadingLocations = false
    
    private var lastDocumentSnapshot: DocumentSnapshot?
            
    init(userLoggedIn: User) {
        self.userLoggedIn = userLoggedIn
    }
    
    var ableToEdit: Bool {
        if selectedPlaceToDetail != nil {
            return userLoggedIn.email == selectedPlaceToDetail!.placedByUser.email
        } else {
            return false
        }
    }
    
    func startPlacingPin() {
        placingPin = true
    }
    
    func endPlacingPin() {
        placingPin = false
    }
    
    func startEditingLocation(location: Location) {
        endPlacingPin()
        selectedPlaceToEdit = location
    }
    
    func fetchLocations() async {
        var query: Query
        
        guard !isLoadingLocations else { return }
        
        isLoadingLocations = true
        let db = Firestore.firestore()
        let locationsCollectionRef = db.collection("Locations")
        if let nextStartingSnapshot = self.lastDocumentSnapshot {
            query = locationsCollectionRef.order(by: "timestamp", descending: true).start(afterDocument: nextStartingSnapshot).limit(to: 4)
        } else {
            query = locationsCollectionRef.order(by: "timestamp", descending: true).limit(to: 4)
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
    
//    func fetchLocationsByUser(user: User) async {
//        locationsPlacedByUser.removeAll(keepingCapacity: false)
//        
//        let db = Firestore.firestore()
//        let locationsCollectionRef = db.collection("Locations")
//        let query = locationsCollectionRef.whereField("placedByEmail", isEqualTo: user.email).limit(to: 5)
//        
//        let _ = query.getDocuments { snapshot, error in
//            guard error == nil else {
//                print(error!.localizedDescription)
//                return
//            }
//            
//            if let snapshot {
//                for document in snapshot.documents {
//                    let data = document.data()
//                    
//                    let id = data["id"] as? String ?? UUID().uuidString
//                    let placedByEmail = data["placedByEmail"] as? String ?? "Unknown Email"
//                    let placedByDisplayName = data["placedByDisplayName"] as? String ?? "Unknown Name"
//                    let latitude = data["latitude"] as? Double ?? 0.0
//                    let longitude = data["longitude"] as? Double ?? 0.0
//                    let landmark = data["landmark"] as? String ?? ""
//                    let timestamp = data["timestamp"] as? Double ?? Date.now.timeIntervalSince1970
//                    let date = Date(timeIntervalSince1970: timestamp)
//                    let description = data["description"] as? String ?? ""
//                    
//                    let placedByUser = User(email: placedByEmail, displayName: placedByDisplayName)
//                    
//                    let location = Location(id: UUID(uuidString: id) ?? UUID(),
//                                            placedByUser: placedByUser,
//                                            latitude: latitude,
//                                            longitude: longitude,
//                                            landmark: landmark,
//                                            date: date,
//                                            description: description
//                    )
//                    
//                    self.locationsPlacedByUser.append(location)
//                }
//            }
//        }
//    }
    
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
                print(error.localizedDescription)
            } else {
                self.locations.insert(location, at: 0)
            }
        }
    }
    
    func deleteLocation(location: Location) async {
        let db = Firestore.firestore()
        let _ = db.collection("Locations").document(location.id.uuidString).delete() { error in
            print("Deleting location...")
            if let error {
                print("Error removing document: \(error)")
            } else {
                if let indexToRemove = self.locations.firstIndex(of: location) {
                    self.locations.remove(at: indexToRemove)
                }
                print("Location successfully deleted!")
            }
        }
    }
    
    func savePhoto(data: Data, id: UUID) async {
        let url = "gs://wheresmo-415ab.appspot.com/images/\(id.uuidString).jpg"
        let gsReference = Storage.storage().reference(forURL: url)
        gsReference.putData(data, metadata: nil) { metadata, error in
            guard metadata != nil else {
                print("Error saving image to Firebase.")
                return
            }
        }
    }
    
    func deletePhoto(id: UUID) async {
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
    
//    func saveProfilePhoto(data: Data, email: String) async {
//        let emailHash = SHA256.hash(data: Data(email.utf8)).description
//        
//        let url = "gs://wheresmo-415ab.appspot.com/profilePhotos/\(emailHash).jpg"
//        let gsReference = Storage.storage().reference(forURL: url)
//        gsReference.putData(data, metadata: nil) { metadata, error in
//            guard metadata != nil else {
//                print("Error saving image to Firebase.")
//                return
//            }
//        }
//    }
}
