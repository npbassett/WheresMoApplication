//
//  MapView-ViewModel.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/12/22.
//

import Foundation
import MapKit
import SwiftUI


@MainActor class MapViewModel: ObservableObject {
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
    
    var ableToEdit: Bool {
        if selectedPlaceToDetail != nil {
            return userLoggedIn == selectedPlaceToDetail!.placedBy
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
    
    func saveLocation(location: Location) {
        dataManager.saveLocation(location: location)
        dataManager.fetchLocations()
    }
    
    func deleteLocation(location: Location) {
        dataManager.deleteLocation(location: location)
    }
}
