//
//  ContentView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/11/22.
//

import MapKit
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    LocationMarkerView()
                        .onTapGesture {
                            viewModel.selectedPlace = location
                        }
                }
            }
            .ignoresSafeArea()
        }
        .sheet(item: $viewModel.selectedPlace) { place in
            LocationDetailView(location: place)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
