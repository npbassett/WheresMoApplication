//
//  DataManager.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/16/22.
//

import Firebase
import FirebaseStorage
import Foundation

class DataManager: ObservableObject {
    @Published var locations = [Location]()
    
    init() {
        fetchLocations()
    }
    
    func fetchLocations() {
        locations.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Locations").order(by: "timestamp", descending: true)
        ref.getDocuments { snapshot, error in
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
                }
            }
        }
    }
    
    func saveLocation(location: Location) {
        let db = Firestore.firestore()
        let ref = db.collection("Locations").document(location.id.uuidString)
        ref.setData(["id": location.id.uuidString,
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
    
    func deleteLocation(location: Location) {
        let db = Firestore.firestore()
        db.collection("Locations").document(location.id.uuidString).delete() { error in
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
    
    func savePhoto(data: Data, id: UUID) {
        let url = "gs://wheresmo-415ab.appspot.com/images/\(id.uuidString).jpg"
        let gsReference = Storage.storage().reference(forURL: url)
        gsReference.putData(data, metadata: nil) { metadata, error in
            guard metadata != nil else {
                print("Error saving image to Firebase.")
                return
            }
        }
    }
    
    func deletePhoto(id: UUID) {
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
