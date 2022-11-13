//
//  ContentView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/11/22.
//

import MapKit
import SwiftUI

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $locationManager.mapRegion,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: $viewModel.userTrackingMode,
                annotationItems: viewModel.locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    if !viewModel.placingPin {
                        LocationMarkerView()
                            .onTapGesture {
                                viewModel.selectedPlace = location
                            }
                    }
                }
            }
            .ignoresSafeArea()
                        
            if viewModel.placingPin {
                ZStack {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    VStack {
                        Spacer()
                        
                        Button {
                            viewModel.addLocation(latitude: locationManager.mapRegion.center.latitude,
                                                  longitude: locationManager.mapRegion.center.longitude
                            )
                        } label: {
                            Text("Confirm Placement")
                                .padding()
                                .background(.black.opacity(0.75))
                                .foregroundColor(.blue)
                                .font(.headline)
                                .clipShape(Capsule())
                        }
                        
                        Button {
                            viewModel.endPlacingPin()
                        } label: {
                            Text("Cancel")
                                .padding()
                                .background(.black.opacity(0.75))
                                .foregroundColor(.white)
                                .font(.headline)
                                .clipShape(Capsule())
                        }
                    }
                }
            } else {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            viewModel.startPlacingPin()
                        } label: {
                            Image(systemName: "mappin")
                                .padding()
                                .background(.black.opacity(0.75))
                                .foregroundColor(.white)
                                .font(.title)
                                .clipShape(Circle())
                                .padding(.trailing)
                        }
                    }
                }
            }
        }
        .sheet(item: $viewModel.selectedPlace) { place in
            LocationEditView(location: place,
                             onSave: { newLocation in viewModel.updateLocation(location: newLocation)},
                             onDelete: { newLocation in viewModel.deleteLocation(location: newLocation)}
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
