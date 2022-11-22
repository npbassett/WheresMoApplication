//
//  PhotoSelector.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/22/22.
//

import PhotosUI
import SwiftUI

struct PhotoSelector: View {
    @Binding var selectedPhotoData: Data?
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Label("Select a photo", systemImage: "photo")
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedPhotoData = data
                }
            }
        }
    }
}

struct PhotoSelector_Previews: PreviewProvider {
    static var previews: some View {
        PhotoSelector(selectedPhotoData: .constant(nil))
    }
}
