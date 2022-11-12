//
//  LocationDetailView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/12/22.
//

import MapKit
import SwiftUI

struct LocationDetailView: View {
    @Environment(\.dismiss) var dismiss
    var location: Location
    
    var body: some View {
        NavigationView {
            Form {
                Section("Location") {
                    Text(location.landmark)
                }
                
                Section("Details") {
                    Text(location.details)
                }
            }
            .navigationTitle("Details")
        }
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetailView(location: Location.exampleLocation)
    }
}
