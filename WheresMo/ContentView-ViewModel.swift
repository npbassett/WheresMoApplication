//
//  ContentView-ViewModel.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/12/22.
//

import Foundation
import MapKit
import SwiftUI

extension ContentView {
    @MainActor class ViewModel: ObservableObject {
        @Published var userTrackingMode: MapUserTrackingMode = .follow
        @Published private(set) var locations: [Location]
        @Published var selectedPlaceToDetail: Location?
        @Published var selectedPlaceToEdit: Location?
        @Published var placingPin = false
        
        let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedMoLocations")
        
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func startPlacingPin() {
            placingPin = true
        }
        
        func endPlacingPin() {
            placingPin = false
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }
        
        func addLocation(latitude: Double, longitude: Double) {
            let newLocation = Location(latitude: latitude,
                                       longitude: longitude)
            locations.append(newLocation)
            save()
            endPlacingPin()
            selectedPlaceToEdit = newLocation
        }
        
        func updateLocation(location: Location) {
            guard let selectedPlaceToEdit = selectedPlaceToEdit else { return }
            
            if let index = locations.firstIndex(of: selectedPlaceToEdit) {
                locations[index] = location
                save()
            }
        }
        
        func deleteLocation(location: Location) {
            if let index = locations.firstIndex(of: location) {
                locations.remove(at: index)
                save()
            }
        }
    }
}
