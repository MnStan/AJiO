//
//  ContentView.swift
//  AJiO
//
//  Created by Maksymilian Stan on 16/05/2024.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $locationManager.cameraPosition) {
                UserAnnotation()
            }
            
            Text(locationManager.state ?? "Unknowned")
                .padding()
                .background(.secondary)
                .clipShape(.capsule)
                .padding(25)
        }
    }
}

#Preview {
    ContentView()
}
