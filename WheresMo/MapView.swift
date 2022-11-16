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
    @EnvironmentObject var dataManager: DataManager
    var userLoggedIn: User
    var onLogout: () -> Void
    
    @StateObject var locationManager = LocationManager()
    @StateObject private var viewModel: ViewModel
    
    init(userLoggedIn: User, onLogout: @escaping () -> Void) {
        self.userLoggedIn = userLoggedIn
        self.onLogout = onLogout
        self._viewModel = StateObject(wrappedValue: ViewModel(userLoggedIn: userLoggedIn))
    }
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $locationManager.mapRegion,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: $viewModel.userTrackingMode,
                annotationItems: dataManager.locations
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
                                viewModel.addLocation(latitude: coordinate.latitude,
                                                      longitude: coordinate.longitude
                                )
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
            LocationDetailView(location: location,
                               onSave: { newLocation in viewModel.updateLocation(location: newLocation)},
                               onDelete: { newLocation in viewModel.deleteLocation(location: newLocation)}
            )
        }
        .sheet(item: $viewModel.selectedPlaceToEdit) { location in
            NavigationView {
                LocationEditView(location: location,
                                 onSave: { newLocation in viewModel.updateLocation(location: newLocation)},
                                 onDelete: { newLocation in viewModel.deleteLocation(location: newLocation)}
                )
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(userLoggedIn: User.exampleUser) { }
            .environmentObject(DataManager())
    }
}
