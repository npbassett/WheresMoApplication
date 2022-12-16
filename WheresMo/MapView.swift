//
//  MapView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/11/22.
//

import Firebase
import MapKit
import SwiftUI

struct MapView: View {
    var userLoggedIn: User

    @StateObject var viewModel: MapViewModel
    
    init(userLoggedIn: User) {
        self.userLoggedIn = userLoggedIn
        self._viewModel = StateObject(wrappedValue: MapViewModel(userLoggedIn: userLoggedIn))
    }
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.mapRegion,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: $viewModel.userTrackingMode,
                annotationItems: viewModel.locations
            ) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    if !viewModel.isPlacingPin {
                        LocationMarkerView()
                            .onTapGesture {
                                viewModel.selectedPlaceToDetail = location
                            }
                    }
                }
            }
            .ignoresSafeArea()
                        
            if viewModel.isPlacingPin {
                ZStack {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    VStack {
                        Button {
                            if let coordinate = viewModel.getCurrentLocationCoordinate() {
                                
                                viewModel.startEditingLocation(location: Location(placedByUser: viewModel.userLoggedIn,
                                                                                  latitude: coordinate.latitude,
                                                                                  longitude: coordinate.longitude))
                            } else {
                                print("Could not access current location.")
                            }
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                
                                Text("Use Current Location")
                            }
                            .padding()
                            .background(.black.opacity(0.75))
                            .foregroundColor(.blue)
                            .font(.headline)
                            .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        Button {
                            viewModel.startEditingLocation(
                                location: Location(placedByUser: viewModel.userLoggedIn,
                                                   latitude: viewModel.mapRegion.center.latitude,
                                                   longitude: viewModel.mapRegion.center.longitude
                                                  )
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
                                .padding(.bottom)
                        }
                    }
                }
            } else {
                VStack {
                    
                    if viewModel.showingSearchAreaButton {
                        Button {
                            Task {
                                await viewModel.fetchLocationsWithinMapRegion()
                            }
                        } label: {
                            HStack {
                                Text("Search this area")
                            }
                            .padding()
                            .background(.black.opacity(0.75))
                            .foregroundColor(.white)
                            .font(.headline)
                            .clipShape(Capsule())
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            Button {
                                withAnimation {
                                    viewModel.ZoomToUserLocation()
                                }
                            } label: {
                                Image(systemName: "location.fill")
                                    .padding()
                                    .background(.black.opacity(0.75))
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .clipShape(Circle())
                                    .padding(.trailing)
                            }
                            
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
                            .padding(.bottom)
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: viewModel.isPlacingPin)
        .animation(.easeInOut(duration: 0.75), value: viewModel.showingSearchAreaButton)
        .sheet(item: $viewModel.selectedPlaceToDetail) { location in
            NavigationView {
                LocationDetailView(location: location,
                                   userLoggedIn: viewModel.userLoggedIn,
                                   onDeleteLocation: { viewModel.removeLocationFromList(location: location) },
                                   onSaveLocation: { location in viewModel.updateLocationList(location: location) }
                )
            }
        }
        .sheet(item: $viewModel.selectedPlaceToEdit) { location in
            NavigationView {
                LocationEditView(location: location, navigatedFromDetailView: false)
                    .environmentObject(LocationViewModel(location: location,
                                                         userLoggedIn: viewModel.userLoggedIn,
                                                         // Passing empty closure because new location is not in self.locations, so it does
                                                         // not need to be removed if deleted.
                                                         onDeleteLocation: { },
                                                         onSaveLocation: { location in viewModel.updateLocationList(location: location) }
                                                        )
                    )
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(userLoggedIn: User.exampleUser)
    }
}
