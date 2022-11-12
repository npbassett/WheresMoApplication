//
//  ContentView-ViewModel.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/12/22.
//

import Foundation
import MapKit

extension ContentView {
    @MainActor class ViewModel: ObservableObject {
        @Published var mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.0150,
                                           longitude: -105.2705),
            span: MKCoordinateSpan(latitudeDelta: 0.07,
                                   longitudeDelta: 0.07)
        )
        @Published private(set) var locations: [Location]
        @Published var selectedPlace: Location?
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
        
        func addLocation() {
            let newLocation = Location(id: UUID(), landmark: "", placedBy: "", latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude, description: "")
            locations.append(newLocation)
            save()
            endPlacingPin()
            selectedPlace = newLocation
        }
        
        func updateLocation(location: Location) {
            guard let selectedPlace = selectedPlace else { return }
            
            if let index = locations.firstIndex(of: selectedPlace) {
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
