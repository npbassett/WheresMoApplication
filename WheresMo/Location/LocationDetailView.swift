//
//  LocationDetailView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/13/22.
//

import MapKit
import SwiftUI

struct LocationDetailView: View {
    @Environment(\.dismiss) var dismiss
    let location: Location
    let userLoggedIn: User
    let onDeleteLocation: () -> Void
    let onSaveLocation: (Location) -> Void
    
    @StateObject private var viewModel: LocationViewModel
    @State private var coordinateRegion: MKCoordinateRegion
    
    var showDescription: Bool {
        return !location.description.isEmpty
    }
    
    init(location: Location, userLoggedIn: User, onDeleteLocation: @escaping () -> Void, onSaveLocation: @escaping (Location) -> Void) {
        self.location = location
        self.userLoggedIn = userLoggedIn
        self.onDeleteLocation = onDeleteLocation
        self.onSaveLocation = onSaveLocation
        self._viewModel = StateObject(wrappedValue: LocationViewModel(location: location,
                                                                      userLoggedIn: userLoggedIn,
                                                                      onDeleteLocation: onDeleteLocation,
                                                                      onSaveLocation: onSaveLocation))
        self._coordinateRegion = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    }
    
    var body: some View {
        Form {
            Section {
                LocationPhoto(id: location.id)
                    .aspectRatio(contentMode: .fit)
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            Section(header: Text("Landmark"),
                    footer: Text(Image(systemName: "location.fill")) + Text(" \(location.coordinate.latitude), \(location.coordinate.longitude)")) {
                Text(location.landmark)
            }
            
            Section("Placed by") {
                NavigationLink {
                    ProfileView(userToShow: location.placedByUser, userLoggedIn: User.unknownUser, navigatedFromMainView: false, onLogout: { })
                        .navigationTitle("Placed By")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    HStack {
                        ProfilePhoto(email: location.placedByUser.email)
                            .frame(width: 30, height: 30)
                        
                        Text(location.placedByUser.displayName)
                    }
                }
            }
            
            Section("Date placed") {
                Text(location.date.formatted(date: .abbreviated, time: .shortened))
            }
            
            if showDescription {
                Section("Description") {
                    Text(location.description)
                }
            }
            
            Section {
                Map(coordinateRegion: $coordinateRegion,
                    annotationItems: [Location(placedByUser: User.exampleUser,
                                               latitude: location.coordinate.latitude,
                                               longitude: location.coordinate.longitude)]) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        LocationMarkerView()
                    }
                }
                .frame(width: 350, height: 200)
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .navigationTitle("Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.ableToEdit {
                    NavigationLink {
                        LocationEditView(location: location, navigatedFromDetailView: true)
                            .environmentObject(viewModel)
                    } label: {
                        Text("Edit")
                    }
                }
            }
        }
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetailView(location: Location.exampleLocation, userLoggedIn: User.exampleUser, onDeleteLocation: { }, onSaveLocation: { _ in })
    }
}
