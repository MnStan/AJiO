//
//  ListItemDetails.swift
//  AJiO
//
//  Created by Maksymilian Stan on 21/05/2024.
//

import SwiftUI

struct ListItemDetails: View {
    var item: DataElement
    
    var body: some View {
        GroupBox(label: Text("Głowne informacje")) {
            VStack(alignment: .center, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                    
                    VStack {
                        Text(item.attributes.provider ?? "")
                            .font(.title3).bold()
                            .multilineTextAlignment(.center)
                        
                        Text(item.attributes.locality ?? "")
                            .font(.headline).bold()
                            .padding(2)
                        
                        Text(item.attributes.address ?? "")
                            .font(.headline).bold()
                            .padding(2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            GroupBox(label: Text("Udogodnienia")) {
                VStack(alignment: .leading, spacing: 10) {
                    let benefitsForChildren = item.attributes.benefitsForChildren
                    if benefitsForChildren == "Y" {
                        HStack {
                            Image(systemName: "figure.and.child.holdinghands")
                            Text("Świadczenia dla dzieci")
                        }
                    }
                    
                    let toilet = item.attributes.toilet
                    if toilet == "Y" {
                        HStack {
                            Image(systemName: "toilet.fill")
                            Text("Toalety")
                        }
                    }
                    
                    let ramp = item.attributes.ramp
                    if ramp == "Y" {
                        HStack {
                            Image(systemName: "figure.roll")
                            Text("Rampa dla niepełnosprawnych")
                        }
                    }
                    
                    let carPark = item.attributes.carPark
                    if carPark == "Y" {
                        HStack {
                            Image(systemName: "parkingsign.circle.fill")
                            Text("Parking")
                        }
                    }
                    
                    let elevator = item.attributes.elevator
                    if elevator == "Y" {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                            Text("Winda")
                        }
                    }
                }
                .padding(.top, 15)
                .frame(maxWidth: .infinity)
            }
            
            if let statistics = item.attributes.statistics {
                if let providerData = statistics.providerData {
                    
                    GroupBox(label: Text("Informacje o kolejce")) {
                        HStack {
                            GroupBox(label: Text("Ostatnia aktualizacja: \(providerData.update)")) {
                                VStack {
                                    Text("Oczekujący")
                                    Text("\(providerData.awaiting)")
                                        .bold()
                                }
                                .padding(.top, 3)
                                
                                VStack {
                                    Text("Średni czas oczekiwania")
                                        .multilineTextAlignment(.center)
                                    Text("\(providerData.averagePeriod ?? 0) dni")
                                        .bold()
                                }
                                .padding(.top, 3)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
            }
            
            if let phoneNumber = item.attributes.phone {
                let formattedPhoneNumber = phoneNumber.formatPhoneNumber()

                GroupBox {
                    if let phoneURL = URL(string: "tel:+\(formattedPhoneNumber)") {
                        Link("\(formattedPhoneNumber)", destination: phoneURL)
                            .foregroundColor(.blue)
                            .padding()
                    } else {
                        Text("Unable to create phone link.")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding()
    }
}

#Preview {
    ListItemDetails(item: .defaultDataElement)
}
