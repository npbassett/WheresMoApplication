//
//  MainView.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/28/22.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var dataManager: DataManager
    var userLoggedIn: User
    var onLogout: () -> Void
    
    var body: some View {
        TabView {
            FeedView(dataManager: dataManager, userLoggedIn: userLoggedIn)
                .tabItem {
                    Label("Feed", systemImage: "list.dash")
                }
            
            MapView(dataManager: dataManager, userLoggedIn: userLoggedIn)
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
        MainView(dataManager: DataManager(), userLoggedIn: User.exampleUser, onLogout: { })
    }
}
