//
//  DataManager.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/16/22.
//

import Firebase
import Foundation

class DataManager: ObservableObject {
    @Published var locations = [Location]()
    
    init() {
        fetchLocations()
    }
    
    func fetchLocations() {
        locations.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Locations")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    
                    let id = data["id"] as? String ?? UUID().uuidString
                    let placedByEmail = data["placedByEmail"] as? String ?? ""
                    let latitude = data["latitude"] as? Double ?? 0.0
                    let longitude = data["longitude"] as? Double ?? 0.0
                    let landmark = data["landmark"] as? String ?? ""
                    let timestamp = data["timestamp"] as? Timestamp
                    let date = timestamp?.dateValue() ?? Date.now
                    let description = data["description"] as? String ?? ""
                    
                    let location = Location(id: UUID(uuidString: id) ?? UUID(),
                                            placedBy: User(email: placedByEmail),
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
                     "placedByEmail": location.placedBy.email,
                     "latitude": location.latitude,
                     "longitude": location.longitude,
                     "landmark": location.landmark,
                     "timestamp": location.date.timeIntervalSince1970,
                     "description": location.description
                    ]
        ) { error in
            if let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteLocation(location: Location) {
        let db = Firestore.firestore()
        print(location.id.uuidString)
        print(location.id.uuidString)
        db.collection("Locations").document(location.id.uuidString).delete() { error in
            print("Deleting location...")
            if let error {
                print("Error removing document: \(error)")
            } else {
                print("Location successfully deleted!")
            }
        }
    }
}
