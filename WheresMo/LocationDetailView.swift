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
    var location: Location
    var onSave: (Location) -> Void
    var onDelete: (Location) -> Void
    
    @State private var coordinateRegion: MKCoordinateRegion
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Landmark"),
                        footer: Text(Image(systemName: "location.fill")) + Text(" \(location.coordinate.latitude), \(location.coordinate.longitude)")) {
                    Text(location.landmark)
                }
                
                Section("Placed by") {
                    Text(location.placedBy)
                }
                
                Section("Date placed") {
                    Text(location.date.formatted(date: .abbreviated, time: .shortened))
                }
                
                Section("Description") {
                    Text(location.description)
                }
                
                Section {
                    Map(coordinateRegion: $coordinateRegion,
                        annotationItems: [Location(latitude: location.coordinate.latitude,
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
                    NavigationLink {
                        LocationEditView(location: location, onSave: onSave, onDelete: onDelete)
                    } label: {
                            Text("Edit")
                    }
                }
            }
        }
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void, onDelete: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        self.onDelete = onDelete
        
        _coordinateRegion = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetailView(location: Location.exampleLocation, onSave: { _ in }, onDelete: { _ in })
    }
}
