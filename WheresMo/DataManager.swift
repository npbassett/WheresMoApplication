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
    @Published var userTable = [String: User]()
    @Published var locations = [Location]()
    
    init() {
        fetchUsers()
        fetchLocations()
    }
    
    func fetchUsers() {
        userTable.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Users")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    
                    let email = data["email"] as? String ?? "Unknown Email"
                    let displayName = data["displayName"] as? String ?? "Unknown User"
                    
                    let user = User(email: email, displayName: displayName)
                    
                    self.userTable[email] = user
                }
            }
        }
    }
    
    func addUser(user: User) {
        let db = Firestore.firestore()
        let ref = db.collection("Users").document(user.email)
        ref.setData(["email": user.email,
                     "displayName": user.displayName
                    ]
        ) { error in
            if let error {
                print(error.localizedDescription)
            } else {
                self.userTable[user.email] = user
            }
        }
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
                    let timestamp = data["timestamp"] as? Double ?? Date.now.timeIntervalSince1970
                    let date = Date(timeIntervalSince1970: timestamp)
                    let description = data["description"] as? String ?? ""
                    
                    let location = Location(id: UUID(uuidString: id) ?? UUID(),
                                            placedByEmail: placedByEmail,
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
                     "placedByEmail": location.placedByEmail,
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
                self.locations.append(location)
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
}
