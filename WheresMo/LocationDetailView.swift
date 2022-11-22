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
    @EnvironmentObject var viewModel: MapViewModel
    var location: Location
    
    @State private var coordinateRegion: MKCoordinateRegion
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    FirebaseImage(id: location.id)
                        .frame(width: 350, height: 350)
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                Section(header: Text("Landmark"),
                        footer: Text(Image(systemName: "location.fill")) + Text(" \(location.coordinate.latitude), \(location.coordinate.longitude)")) {
                    Text(location.landmark)
                }
                
                Section("Placed by") {
                    Text(viewModel.dataManager.userTable[location.placedByEmail]?.displayName ?? "Unknown User")
                }
                
                Section("Date placed") {
                    Text(location.date.formatted(date: .abbreviated, time: .shortened))
                }
                
                Section("Description") {
                    Text(location.description)
                }
                
                Section {
                    Map(coordinateRegion: $coordinateRegion,
                        annotationItems: [Location(placedByEmail: User.exampleUser.email,
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.ableToEdit {
                        NavigationLink {
                            LocationEditView(location: location)
                                .environmentObject(viewModel)
                        } label: {
                            Text("Edit")
                        }
                    }
                }
            }
        }
    }
    
    init(location: Location) {
        self.location = location
        
        _coordinateRegion = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetailView(location: Location.exampleLocation)
            .environmentObject(MapViewModel(dataManager: DataManager(),
                                            userLoggedInEmail: User.exampleUser.email))
    }
}
