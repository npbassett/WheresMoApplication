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
                    
                    let id = data["id"] as? UUID ?? UUID()
                    let placedByEmail = data["placedByEmail"] as? String ?? ""
                    let latitude = data["latitude"] as? Double ?? 0.0
                    let longitude = data["longitude"] as? Double ?? 0.0
                    let landmark = data["landmark"] as? String ?? ""
                    let timestamp = data["timestamp"] as? Timestamp
                    let date = timestamp?.dateValue() ?? Date.now
                    let description = data["description"] as? String ?? ""
                    
                    let location = Location(id: id,
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
}
