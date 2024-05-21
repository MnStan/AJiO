//
//  AJiOApp.swift
//  AJiO
//
//  Created by Maksymilian Stan on 16/05/2024.
//

import SwiftUI

@main
struct AJiOApp: App {
    @ObservedObject var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            LoadingView(shouldShowNextScreen: $locationManager.didEndLocationWork).environmentObject(locationManager)
        }
    }
}
