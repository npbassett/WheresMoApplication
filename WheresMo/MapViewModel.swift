//
//  MapView-ViewModel.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/12/22.
//

import Foundation
import MapKit
import SwiftUI

extension MapView {
    @MainActor class ViewModel: ObservableObject {
        var dataManager: DataManager
        var userLoggedIn: User
        @Published var userTrackingMode: MapUserTrackingMode = .follow
        @Published var selectedPlaceToDetail: Location?
        @Published var selectedPlaceToEdit: Location?
        @Published var placingPin = false
                
        init(dataManager: DataManager, userLoggedIn: User) {
            self.dataManager = dataManager
            self.userLoggedIn = userLoggedIn
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
        
        func saveLocation(location: Location) {
            dataManager.addLocation(location: location)
            dataManager.fetchLocations()
        }
        
        func updateLocation(location: Location) {
            // TODO
        }
        
        func deleteLocation(location: Location) {
            // TODO
        }
    }
}
