//
//  FeedPostView.swift
//  WheresMo
//
//  Created by Neil Bassett on 12/1/22.
//

import SwiftUI

struct FeedPostView: View {
    var location: Location
    
    @State private var isLiked = false
    
    var showDescription: Bool {
        return !location.description.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ProfilePhoto(email: location.placedByUser.email)
                    .frame(width:40, height:40)
                
                VStack(alignment: .leading) {
                    Text(location.placedByUser.displayName).font(.title3).bold()
                    
                    (Text(Image(systemName: "mappin")) + Text(" ") + Text(location.landmark))
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            LocationPhoto(id: location.id)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: 320, height: 320)
            
            (Text(Image(systemName: "calendar")) + Text(" ") + Text(location.date.formatted(date: .abbreviated, time: .omitted)))
                .lineLimit(1)
            
            if showDescription {
                (Text(Image(systemName: "text.alignleft")) + Text(" ") + Text(location.description))
                    .lineLimit(3)
            }
            
// I removed like and comment buttons for now.
//            Rectangle()
//                .frame(height: 0.5)
//                .foregroundColor(.primary.opacity(0.5))
//
//            HStack {
//                Button {
//                    // TODO: Add like funcitonality
//                    isLiked.toggle()
//                } label: {
//                    Text(Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")) + Text(" Like")
//                }
//                .frame(maxWidth: .infinity)
//
//                Button {
//                    // TODO: Add comment functionality
//                } label: {
//                    Text(Image(systemName: "bubble.left")) + Text(" Comment")
//                }
//                .frame(maxWidth: .infinity)
//            }
//            .buttonStyle(BorderlessButtonStyle())
        }
        .padding()
    }
}

struct FeedPostView_Previews: PreviewProvider {
    static var previews: some View {
        FeedPostView(location: Location.exampleLocation)
    }
}
