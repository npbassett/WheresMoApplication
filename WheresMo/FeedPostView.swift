//
//  FeedPostView.swift
//  WheresMo
//
//  Created by Neil Bassett on 12/1/22.
//

import SwiftUI

struct FeedPostView: View {
    @ObservedObject var viewModel: FeedViewModel
    var location: Location
    
    @State private var isLiked = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                FirebaseImage(id: location.id)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 150, height: 150)
                
                VStack(alignment: .leading, spacing: 10) {
                    (Text(Image(systemName: "person.fill")) + Text(" ") + Text(viewModel.dataManager.userTable[location.placedByEmail]?.displayName ?? "Unknown User").font(.headline))
                        .lineLimit(1)
                    
                    (Text(Image(systemName: "mappin")) + Text("  \(location.landmark)"))
                        .lineLimit(1)
                    
                    (Text(Image(systemName: "calendar")) + Text(" ") + Text(location.date.formatted(date: .abbreviated, time: .omitted)))
                        .lineLimit(1)
                    
                    (Text(Image(systemName: "text.alignleft")) + Text(" ") + Text(location.description))
                        .lineLimit(2)
                }
            }
            
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.primary.opacity(0.5))
            
            HStack {
                Button {
                    // TODO: Add like funcitonality
                    isLiked.toggle()
                } label: {
                    Text(Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")) + Text(" Like")
                }
                .frame(maxWidth: .infinity)
                
                Button {
                    // TODO: Add comment functionality
                } label: {
                    Text(Image(systemName: "bubble.left")) + Text(" Comment")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct FeedPostView_Previews: PreviewProvider {
    static var previews: some View {
        FeedPostView(viewModel: FeedViewModel(dataManager: DataManager(), userLoggedInEmail: User.exampleUser.email), location: Location.exampleLocation)
    }
}
