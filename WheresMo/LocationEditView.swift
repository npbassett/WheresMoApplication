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
    @EnvironmentObject var viewModel: MapViewModel
    var location: Location
    
    @State private var landmark: String
    @State private var date: Date
    @State private var description: String
    @State private var coordinateRegion: MKCoordinateRegion
    @State private var coordinate: CLLocationCoordinate2D
    @State private var selectedPhotoData: Data? = nil
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Form {
            
            //TODO: when navigating to edit view from detail view, fetch saved image from firebase storage if it exists
            Section {
                if let selectedPhotoData {
                    let image = UIImage(data: selectedPhotoData)
                    
                    Image(uiImage: image!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 350, height: .infinity)
                } else {
                    VStack {
                        Image("Mo_background_removed")
                            .resizable()
                            .scaledToFit()
                            .padding(.bottom, -50)
                        HStack {
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(.red)
                            Text("Photo not found.")
                        }
                    }
                    .frame(width: 350, height: 350)
                }
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            PhotoSelector(selectedPhotoData: $selectedPhotoData)
            
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    var newLocation = location
                    newLocation.landmark = landmark
                    newLocation.date = date
                    newLocation.description = description
                    
                    viewModel.saveLocation(location: newLocation)
                    if selectedPhotoData != nil {
                        viewModel.dataManager.savePhoto(data: selectedPhotoData!, id: newLocation.id)
                    }
                    dismiss()
                } label: {
                    Text("Save")
                }
            }
        }
    }
    
    init(location: Location) {
        self.location = location
        
        _landmark = State(initialValue: location.landmark)
        _date = State(initialValue: location.date)
        _description = State(initialValue: location.description)
        _coordinateRegion = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
        _coordinate = State(initialValue: location.coordinate)
    }
}

struct LocationEditView_Previews: PreviewProvider {
    static var previews: some View {
        LocationEditView(location: Location.exampleLocation)
            .environmentObject(MapViewModel(dataManager: DataManager(),
                                            userLoggedInEmail: User.exampleUser.email))
    }
}
