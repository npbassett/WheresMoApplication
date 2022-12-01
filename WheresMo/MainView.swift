//
//  MainView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/28/22.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var dataManager: DataManager
    var userLoggedInEmail: String
    var onLogout: () -> Void
    
    var body: some View {
        TabView {
            FeedView(dataManager: dataManager, userLoggedInEmail: userLoggedInEmail)
                .tabItem {
                    Label("Feed", systemImage: "list.dash")
                }
            
            MapView(dataManager: dataManager, userLoggedInEmail: userLoggedInEmail)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            SettingsView(onLogout: onLogout)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.systemBackground
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(dataManager: DataManager(), userLoggedInEmail: User.exampleUser.email, onLogout: { })
    }
}
