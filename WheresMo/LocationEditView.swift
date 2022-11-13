//
//  LocationEditView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/12/22.
//

import SwiftUI

struct LocationEditView: View {
    @Environment(\.dismiss) var dismiss
    var location: Location
    var onSave: (Location) -> Void
    var onDelete: (Location) -> Void
    
    @State private var landmark: String
    @State private var placedBy: String
    @State private var description: String
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Landmark") {
                    TextField("Enter landmark", text: $landmark)
                }
                Section("Placed by") {
                    TextField("Enter name", text: $placedBy)
                }
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(height: 150)
                }
            }
            .navigationTitle("Edit")
            .alert("Delete location?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    onDelete(location)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure?")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        var newLocation = location
                        newLocation.id = UUID()
                        newLocation.landmark = landmark
                        newLocation.placedBy = placedBy
                        newLocation.description = description
                        
                        onSave(newLocation)
                        dismiss()
                    } label: {
                        Text("Save")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void, onDelete: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        self.onDelete = onDelete
        
        _landmark = State(initialValue: location.landmark)
        _placedBy = State(initialValue: location.placedBy)
        _description = State(initialValue: location.description)
    }
}

struct LocationEditView_Previews: PreviewProvider {
    static var previews: some View {
        LocationEditView(location: Location.exampleLocation,
                         onSave: { _ in },
                         onDelete: { _ in }
        )
    }
}
