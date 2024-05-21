//
//  ListItem.swift
//  AJiO
//
//  Created by Maksymilian Stan on 21/05/2024.
//

import SwiftUI
import CoreLocation

struct ListItem: View {
    var item: DataElement
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(item.attributes.benefit ?? "")
                    .font(.headline)
                
                Text(item.attributes.provider ?? "")
                    .font(.caption).bold()
            }
            .padding(.vertical, 2)
            
            HStack {
                Text("Najbliższy termin: ")
                    .font(.caption).bold()
                
                Text(item.attributes.dates?.date ?? "Brak informacji")
                    .font(.caption).bold()
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    HStack {
                        Image(systemName: "location")
                        Text(item.attributes.locality ?? "")
                            .font(.caption).bold()
                    }
                    
                    if let latitude = item.attributes.latitude, let longitude = item.attributes.longitude {
                        Text(LocationManager.shared.getProviderDistance(location: CLLocation(latitude: latitude, longitude: longitude)))
                            .font(.caption2)
                    }
                }
            }
        }
    }
}


#Preview {
    ListItem(item: .defaultDataElement)
}
