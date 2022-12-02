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
    @EnvironmentObject var viewModel: MainViewModel
    var location: Location
    var navigatedFromDetailView: Bool
    
    @State private var landmark: String
    @State private var date: Date
    @State private var description: String
    @State private var coordinateRegion: MKCoordinateRegion
    @State private var coordinate: CLLocationCoordinate2D
    @State private var selectedPhotoData: Data? = nil
    
    @State private var showingDeleteAlert = false
    
    var photoSelectionRequired: Bool {
        return selectedPhotoData == nil && !navigatedFromDetailView
    }
    
    var landmarkIsEmpty: Bool {
        return landmark.isEmpty
    }
    
    var body: some View {
        Form {
            Section {
                if let selectedPhotoData {
                    let image = UIImage(data: selectedPhotoData)
                    
                    Image(uiImage: image!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 350, height: 350)
                } else {
                    FirebaseImage(id: location.id)
                        .scaledToFill()
                        .frame(width: 350, height: 350)
                }
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            Section {
                PhotoSelector(selectedPhotoData: $selectedPhotoData)
            } footer: {
                if photoSelectionRequired {
                    (Text(Image(systemName: "exclamationmark.circle")) + Text(" Please select a photo"))
                        .foregroundColor(.red)
                }
            }
            
            Section {
                TextField("Enter landmark", text: $landmark)
            } header: {
                Text("Landmark")
            } footer: {
                VStack {
                    if landmarkIsEmpty {
                        (Text(Image(systemName: "exclamationmark.circle")) + Text(" Please enter a landmark"))
                            .foregroundColor(.red)
                    } else {
                        Text(Image(systemName: "location.fill")) + Text(" \(coordinate.latitude), \(coordinate.longitude)")
                    }
                }
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
                viewModel.deletePhoto(id: location.id)
                viewModel.deleteLocation(location: location)
                viewModel.selectedPlaceToEdit = nil
                viewModel.selectedPlaceToDetail = nil
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure?")
        }
        .toolbar {
            if !navigatedFromDetailView {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    var newLocation = location
                    newLocation.landmark = landmark
                    newLocation.date = date
                    newLocation.description = description
                    
                    viewModel.saveLocation(location: newLocation)
                    if selectedPhotoData != nil {
                        viewModel.savePhoto(data: selectedPhotoData!, id: newLocation.id)
                    }
                    dismiss()
                } label: {
                    Text("Save")
                }
                .disabled(photoSelectionRequired || landmarkIsEmpty)
            }
        }
    }
    
    init(location: Location, navigatedFromDetailView: Bool) {
        self.location = location
        self.navigatedFromDetailView = navigatedFromDetailView
        
        _landmark = State(initialValue: location.landmark)
        _date = State(initialValue: location.date)
        _description = State(initialValue: location.description)
        _coordinateRegion = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
        _coordinate = State(initialValue: location.coordinate)
    }
}

struct LocationEditView_Previews: PreviewProvider {
    static var previews: some View {
        LocationEditView(location: Location.exampleLocation, navigatedFromDetailView: false)
            .environmentObject(MainViewModel(userLoggedIn: User.exampleUser))
    }
}
