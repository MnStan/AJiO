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
    @State var isShowingMarkers = false
    @State var counter = 1
    @State var isLoading = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $locationManager.cameraPosition) {
                UserAnnotation()
                if isShowingMarkers {
                    ForEach(locationManager.locations) { location in
                        Annotation("Searching", coordinate: location.coordinate) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.teal)
                                .frame(width: 25, height: 25)
                        }
                    }
                }
            }
            
            VStack {
                Text(locationManager.state ?? "Unknowned")
                    .padding()
                    .background(.secondary)
                    .clipShape(.capsule)
                    .padding(25)
                    .onTapGesture {
                        print(locationManager.locations)
                        isShowingMarkers.toggle()
                        print("COUNT", locationManager.locations.count)
                        print(locationManager.$nearVoivodeships)
                        
                    }
                
                if locationManager.isLoadingNearVoivodeships {
                    RoundedRectangle(cornerRadius: 10)
                         .fill(Color.blue)
                         .frame(width: 80, height: 20)
                         .offset(x: isLoading ? -50 : 50)
                         .animation(.easeInOut.repeatForever(), value: isLoading)
                         .onAppear {
                             self.isLoading = true
                         }
                         .padding()
                                
                } else {
                    Text("\(locationManager.nearVoivodeships)")
                }
            }
        }
        .alert("Wystąpił problem", isPresented: $locationManager.shouldShowThrottledError) {
            Button("Tak") {
                locationManager.getPointsVoivodeshipsAgain()
                isLoading = false
            }
            Button("Nie", role: .cancel) { }
        } message: {
            Text("Osiągnięto limit zapytań do wyszukiwania najbliższych województw.\nCzy chcesz pobrać je ponownie?")
        }

    }
}

#Preview {
    ContentView()
}
