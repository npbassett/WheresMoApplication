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
    @ObservedObject var dataManager: DataManager
    var userLoggedInEmail: String
    var onLogout: () -> Void
    
    @StateObject var locationManager = LocationManager()
    @StateObject private var viewModel: MapViewModel
    
    init(dataManager: DataManager, userLoggedInEmail: String, onLogout: @escaping () -> Void) {
        self.dataManager = dataManager
        self.userLoggedInEmail = userLoggedInEmail
        self.onLogout = onLogout
        self._viewModel = StateObject(wrappedValue: MapViewModel(dataManager: dataManager, userLoggedInEmail: userLoggedInEmail))
    }
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $locationManager.mapRegion,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: $viewModel.userTrackingMode,
                annotationItems: viewModel.dataManager.locations
            ) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    if !viewModel.placingPin {
                        LocationMarkerView()
                            .onTapGesture {
                                viewModel.selectedPlaceToDetail = location
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
                        Button {
                            if let coordinate = locationManager.getCurrentLocationCoordinate() {
                                
                                viewModel.startEditingLocation(location: Location(placedByEmail: userLoggedInEmail,
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
                                location: Location(placedByEmail: userLoggedInEmail,
                                                   latitude: locationManager.mapRegion.center.latitude,
                                                   longitude: locationManager.mapRegion.center.longitude
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
                        }
                    }
                }
            } else {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button {
                            onLogout()
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                .padding()
                                .background(.black.opacity(0.75))
                                .foregroundColor(.white)
                                .font(.title)
                                .clipShape(Capsule())
                                .padding(.trailing)
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            Button {
                                withAnimation {
                                    locationManager.resetMapRegion()
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
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: viewModel.placingPin)
        .sheet(item: $viewModel.selectedPlaceToDetail) { location in
            LocationDetailView(location: location)
                .environmentObject(viewModel)
        }
        .sheet(item: $viewModel.selectedPlaceToEdit) { location in
            NavigationView {
                LocationEditView(location: location)
                    .environmentObject(viewModel)
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(dataManager: DataManager(), userLoggedInEmail: User.exampleUser.email) { }
    }
}
