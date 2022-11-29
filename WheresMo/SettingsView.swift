//
//  SettingsView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/28/22.
//

import SwiftUI

struct SettingsView: View {
    var onLogout: () -> Void
    
    var body: some View {
        Form {
            Section {
                Button {
                    onLogout()
                } label: {
                    Text(Image(systemName: "rectangle.portrait.and.arrow.right")) + Text(" Log Out")
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(onLogout: { })
    }
}
