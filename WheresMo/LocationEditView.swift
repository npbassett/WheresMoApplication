//
//  LocationEditView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/12/22.
//

import MapKit
import SwiftUI

struct LocationEditView: View {
    @Environment(\.dismiss) var dismiss
    var location: Location
    var onSave: (Location) -> Void
    var onDelete: (Location) -> Void
    
    @State private var landmark: String
    @State private var date: Date
    @State private var description: String
    @State private var coordinateRegion: MKCoordinateRegion
    @State private var coordinate: CLLocationCoordinate2D
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Landmark"),
                    footer: Text(Image(systemName: "location.fill")) + Text(" \(coordinate.latitude), \(coordinate.longitude)")) {
                TextField("Enter landmark", text: $landmark)
            }
            
            Section("Date placed") {
                DatePicker("Enter the date and time when this Mo was placed", selection: $date)
                    .labelsHidden()
            }
            
            Section("Description") {
                TextEditor(text: $description)
                    .frame(height: 150)
            }
            
            Button {
                showingDeleteAlert = true
            } label: {
                (Text(Image(systemName: "trash")) + Text(" Delete Location"))
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete location?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                onDelete(location)
                // TODO: dismiss parent DetailView after deleting location
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure?")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    var newLocation = location
                    newLocation.landmark = landmark
                    newLocation.description = description
                    
                    onSave(newLocation)
                    dismiss()
                } label: {
                    Text("Save")
                }
            }
        }
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void, onDelete: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        self.onDelete = onDelete
        
        _landmark = State(initialValue: location.landmark)
        _date = State(initialValue: location.date)
        _description = State(initialValue: location.description)
        _coordinateRegion = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
        _coordinate = State(initialValue: location.coordinate)
    }
}

struct LocationEditView_Previews: PreviewProvider {
    static var previews: some View {
        LocationEditView(location: Location.exampleLocation, onSave: { _ in }, onDelete: { _ in })
    }
}
