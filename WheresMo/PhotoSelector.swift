//
//  PhotoSelector.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/22/22.
//

import PhotosUI
import SwiftUI

struct PhotoSelector: View {
    var label: AnyView
    @Binding var selectedPhotoData: Data?
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            label
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    print(data.count)
                    let image = UIImage(data: data)
                    guard image != nil else {
                        print("Error selecting image. Data could not be converted to a UIImage.")
                        return
                    }
                    let compressedImageData = image!.jpegData(compressionQuality: 0.0)
                    guard compressedImageData != nil else {
                        print("Error compressing image.")
                        return
                    }
                    print(compressedImageData!.count)
                    
                    selectedPhotoData = compressedImageData
                }
            }
        }
    }
}

struct PhotoSelector_Previews: PreviewProvider {
    static var previews: some View {
        PhotoSelector(label: AnyView(Label("Select a photo", systemImage: "photo")), selectedPhotoData: .constant(nil))
    }
}
