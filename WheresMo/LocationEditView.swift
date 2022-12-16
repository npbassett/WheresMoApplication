//
//  LocationEditView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/12/22.
//

import MapKit
import SwiftUI
import Kingfisher

struct LocationEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: LocationViewModel
    var location: Location
    var navigatedFromDetailView: Bool
    
    @State private var landmark: String
    @State private var date: Date
    @State private var description: String
    @State private var coordinateRegion: MKCoordinateRegion
    @State private var coordinate: CLLocationCoordinate2D
    @State private var selectedPhoto: UIImage?
    @State private var metadataDate: Date?
    @State private var metadataLatitude: Double?
    @State private var metadataLongitude: Double?
    
    @State private var showingPhotoPickerSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingUseMetadataAlert = false
    @State private var isSavingPhoto = false
    
    var photoSelectionRequired: Bool {
        return selectedPhoto == nil && !navigatedFromDetailView
    }
    
    var landmarkIsEmpty: Bool {
        return landmark.isEmpty
    }
    
    var body: some View {
        ZStack {
            Form {
                Section {
                    if let selectedPhoto {
                        Image(uiImage: selectedPhoto)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                    } else {
                        LocationPhoto(id: location.id)
                            .aspectRatio(contentMode: .fit)
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                    }
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                Section {
                    Button {
                        showingPhotoPickerSheet.toggle()
                    } label: {
                        Label("Select a photo", systemImage: "photo")
                    }
                    .onChange(of: metadataDate) { _ in
                        showingUseMetadataAlert.toggle()
                    }
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
            .blur(radius: isSavingPhoto ? 5 : 0)
            
            if isSavingPhoto {
                ProgressView()
                    .scaleEffect(2)
            }
        }
        .navigationTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete location?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteLocationPhoto(id: location.id)
                    await viewModel.deleteLocation(location: location)
                }
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure?")
        }
        .alert("Found photo metadata.", isPresented: $showingUseMetadataAlert) {
            Button("Yes") {
                guard metadataDate != nil else {
                    return
                }
                date = metadataDate!
                
                guard metadataLatitude != nil && metadataLongitude != nil else {
                    return
                }
                coordinate = CLLocationCoordinate2D(latitude: metadataLatitude!, longitude: metadataLongitude!)
            }
            Button("No", role: .cancel) { }
        } message: {
            Text("Would you like to use the metadata to set the date and location of this Mo?")
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
                    newLocation.latitude = coordinate.latitude
                    newLocation.longitude = coordinate.longitude
                    newLocation.landmark = landmark
                    newLocation.date = date
                    newLocation.description = description
                    
                    Task {
                        let selectedPhotoData = selectedPhoto?.jpegData(compressionQuality: 0.0)
                        if selectedPhotoData != nil {
                            // saveLocationPhoto function takes a closure as an argument that runs on completion.
                            // We want to wait until location photo has been uploaded to firebase before
                            // saving location so that when new post is created in FeedView, it can fetch
                            // the location photo from firebase.
                            isSavingPhoto = true
                            await viewModel.saveLocationPhoto(data: selectedPhotoData!, id: newLocation.id) {
                                await viewModel.saveLocation(location: newLocation)
                                isSavingPhoto = false
                                dismiss()
                            }
                        }
                    }
                } label: {
                    Text("Save")
                }
                .disabled(photoSelectionRequired || landmarkIsEmpty)
            }
        }
        .sheet(isPresented: $showingPhotoPickerSheet) {
            CustomPhotoPickerView(selectedImage: $selectedPhoto, date: $metadataDate, latitude: $metadataLatitude, longitude: $metadataLongitude)
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
