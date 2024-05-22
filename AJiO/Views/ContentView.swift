//
//  ContentView.swift
//  AJiO
//
//  Created by Maksymilian Stan on 16/05/2024.
//

import SwiftUI
import MapKit
import Combine

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    @ObservedObject var networkManager = NetworkManager.shared
    @State var isShowingMarkers = false
    @State var counter = 1
    @State var searchText = ""
    @State private var searchCancellable: AnyCancellable?
    @State var showDetailView = false
    @FocusState private var isTextFieldFocused: Bool
    
    @Namespace var namespace
    @State private var isShowingSearching = false
    @State private var selectedItem: DataElement? = nil
    
    var body: some View {
        NavigationStack {
            Text("\(NetworkManager.shared.shouldFetchMore)")
            ZStack {
                if isShowingSearching {
                    VStack {
                        ZStack(alignment: .topTrailing) {
                            Map(position: $locationManager.position) {
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
                            .matchedGeometryEffect(id: "map", in: namespace)
                            .hidden()
                            
                            VStack {
                                Button {
                                    withAnimation {
                                        isShowingSearching.toggle()
                                    }
                                } label: {
                                    Image(systemName: "x.circle")
                                        .resizable()
                                        .padding()
                                        .background(.gray)
                                        .foregroundStyle(.black)
                                        .clipShape(.capsule)
                                        .frame(width: 50, height: 50)
                                        .matchedGeometryEffect(id: "searchButton", in: namespace)
                                }
                                .offset(x: 40)
                                
                                Text(locationManager.state ?? "Unknowned")
                                    .padding()
                                    .background(.secondary)
                                    .clipShape(.capsule)
                                    .padding(25)
                                    .onTapGesture { }
                                    .matchedGeometryEffect(id: "voivodeship", in: namespace)
                                    .hidden()
                                    .frame(height: 0)
                            }
                            .matchedGeometryEffect(id: "buttons", in: namespace)
                            .padding()
                        }
                        .frame(height: 50)
                        
                        TextField("Szukaj...", text: $searchText)
                            .matchedGeometryEffect(id: "textField", in: namespace)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.black, lineWidth: 1)
                            )
                            .padding()
                            .onChange(of: searchText) { oldValue, newValue in
                                if oldValue != newValue {
                                    networkManager.cancelFetch()
                                }
                                searchCancellable?.cancel()
                                searchCancellable = Timer.publish(every: 0.5, on: .main, in: .common)
                                    .autoconnect()
                                    .first()
                                    .sink { _ in
                                        guard newValue.count > 2 else { return }
                                        isTextFieldFocused = false
                                        Task {
                                            do {
                                                guard let voivodeShipNumber = locationManager.getVoivodeshipCode() else { return }
                                                try await networkManager.fetchData(province: voivodeShipNumber, benefit: newValue)
                                            } catch {
                                                print(error)
                                            }
                                        }
                                    }
                            }
                            .focused($isTextFieldFocused)
                        
                        List {
                            Section("Twoje województwo") {
                                ForEach(networkManager.dataArray, id: \.id) { item in
                                    ListItem(item: item)
                                        .onTapGesture {
                                            showDetailView = true
                                            selectedItem = item
                                        }
                                }
                            }
                            
                            if !networkManager.nearVoivodeshipsDataArray.isEmpty {
                                Section("Pobliskie województwa") {
                                    ForEach(networkManager.nearVoivodeshipsDataArray, id: \.id) { item in
                                        ListItem(item: item)
                                            .onTapGesture {
                                                showDetailView = true
                                                selectedItem = item
                                            }
                                    }
                                }
                            }
                        }
                        .matchedGeometryEffect(id: "list", in: namespace)
                        .scrollContentBackground(.hidden)
                        
                        Spacer()
                    }
                    .matchedGeometryEffect(id: "background", in: namespace)
                    .background(.thinMaterial)
                } else {
                    ZStack(alignment: .bottomTrailing) {
                        Map(position: $locationManager.position) {
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
                        .matchedGeometryEffect(id: "map", in: namespace)
                        
                        VStack {
                            Button {
                                withAnimation {
                                    isShowingSearching.toggle()
                                }
                            } label: {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .padding()
                                    .background(.gray)
                                    .foregroundStyle(.black)
                                    .clipShape(.capsule)
                                    .frame(width: 50, height: 50)
                                    .matchedGeometryEffect(id: "searchButton", in: namespace)
                            }
                            
                            Text(locationManager.state ?? "Unknowned")
                                .padding()
                                .background(.secondary)
                                .clipShape(.capsule)
                                .padding(25)
                                .onTapGesture {
                                    isShowingMarkers.toggle()
                                    print(locationManager.nearVoivodeships)
                                }
                                .matchedGeometryEffect(id: "voivodeship", in: namespace)
                            
                            TextField("Szukaj", text: $searchText)
                                .matchedGeometryEffect(id: "textField", in: namespace)
                                .padding(.horizontal, 50)
                                .frame(width: 0, height: 0)
                                .hidden()
                            
                            List { }
                                .matchedGeometryEffect(id: "list", in: namespace)
                                .frame(width: 0, height: 0)
                                .hidden()
                        }
                        .matchedGeometryEffect(id: "buttons", in: namespace)
                        .matchedGeometryEffect(id: "background", in: namespace)
                        .background(Color.clear)
                    }
                }
            }
        }
        .onChange(of: showDetailView) {}
        .sheet(isPresented: $showDetailView) {
            if let selectedItem {
                ListItemDetails(item: selectedItem)
            }
        }
        .onAppear {
            
        }
    }
}

#Preview {
    ContentView().environmentObject(LocationManager())
}
