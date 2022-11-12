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
        @Published private(set) var locations = [Location.exampleLocation]
        @Published var selectedPlace: Location?
    }
}
