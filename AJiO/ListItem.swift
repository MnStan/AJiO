//
//  ListItem.swift
//  AJiO
//
//  Created by Maksymilian Stan on 21/05/2024.
//

import SwiftUI

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
                
                Image(systemName: "location")
                Text(item.attributes.locality ?? "")
                    .font(.caption).bold()
            }
        }
    }
}

#Preview {
    ListItem(item: .defaultDataElement)
}
