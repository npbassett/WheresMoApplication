//
//  SettingsView.swift
//  WheresMo
//
//  Created by Neil Bassett on 12/12/22.
//

import Kingfisher
import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Button {
                ImageCache.default.clearMemoryCache()
                ImageCache.default.clearDiskCache()
            } label: {
                Text("Clear image cache")
            }
            .buttonStyle(.bordered)
            .padding(.top)
            
            Text("Clearing the image cache will free up local disk space, but may result in increased data usage.")
                .padding(.leading)
                .padding(.trailing)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("Where's Mo?")
                .foregroundColor(.secondary)
            
            Text("Copyright 2022, Neil Bassett")
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
