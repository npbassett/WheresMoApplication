//
//  LocationMarkerView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/12/22.
//

import SwiftUI

struct LocationMarkerView: View {
    let accentColor = Color.red
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(accentColor)
                    .frame(width: 44, height: 44)
                    .font(.headline)
                
                Text("🐈")
                    .font(.title)
            }
            
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(accentColor)
                .frame(width: 15, height: 15)
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -5)
                .padding(.bottom, 40)
        }
    }
}

struct LocationMarkerView_Previews: PreviewProvider {
    static var previews: some View {
        LocationMarkerView()
    }
}
