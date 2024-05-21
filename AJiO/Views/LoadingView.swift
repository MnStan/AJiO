//
//  LoadingView.swift
//  AJiO
//
//  Created by Maksymilian Stan on 20/05/2024.
//

import SwiftUI

struct LoadingView: View {
//    @Binding var shouldShowNextScreen: Bool
    @ObservedObject var locationManager = LocationManager.shared
    @State private var isAnimating = false
    @State private var currentSymbol = "location"
    @State private var rotationAngle: Double = 0
    @State private var displayedText: String = ""
    @State var isLoading = false
    private let interval = 0.05
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Image(systemName: "globe.americas.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                
                Spacer()
                
                Text(displayedText)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .onAppear {
                        startTypewriterAnimation()
                    }
                
                Spacer()
            }
            .onAppear {
                isAnimating = true
                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            }
            .alert("Wystąpił problem", isPresented: $locationManager.shouldShowThrottledError) {
                Button("Tak") {
                    locationManager.getPointsVoivodeshipsAgain()
                    isLoading = false
                }
                Button("Nie", role: .cancel) { exit(0) }
            } message: {
                Text("Osiągnięto limit zapytań do wyszukiwania najbliższych województw.\nCzy chcesz pobrać je ponownie?")
            }
            .navigationDestination(isPresented: .constant(locationManager.didEndLocationWork && !$locationManager.isLoadingNearVoivodeships.wrappedValue)) {
                ContentView().environmentObject(locationManager).navigationBarBackButtonHidden()
            }
        }
        .statusBar(hidden: true)
    }
    
    private func startTypewriterAnimation() {
        displayedText = ""
        let fullTextArray = Array("Pobieranie lokalizacji\noraz pobliskich województw...")
        for (index, character) in fullTextArray.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(index)) {
                displayedText.append(character)
            }
        }
    }
}


#Preview {
    LoadingView()
}
