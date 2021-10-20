//
//  ListHouseView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/19/21.
//

import SwiftUI

struct ListHouseView: View {
    
    @EnvironmentObject var env : Env
    
    @State private var searchText = ""
    
    var results: [House] {
        if searchText.isEmpty {
            return env.houses
        } else {
            return env.houses.filter { $0.name.contains(searchText) || $0.description.contains(searchText) }
        }
    }
    
    var body: some View {
        List {
            Section {
                ForEach(results) { house in
                    NavigationLink {
                        ZStack {
                            
                        }
                    } label: {
                        HStack {
                            VStack {
                                HStack {
                                    Text("\(house.house_id)")
                                        .font(.caption.monospaced())
                                    Text("\(house.name)")
                                        .font(.headline.bold())
                                }
                            }
                            Spacer()
                            Text("\(house.description)")
                                .font(.caption)
                                .foregroundColor(.init(UIColor.secondaryLabel))
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search for house")
        .refreshable {
        }
        .onAppear(perform: {
            HouseManager.shared.refreshEnvHouses { houses, err in
                
            }
        })
        .navigationTitle("Houses")
    }
}

struct ListHouseView_Previews: PreviewProvider {
    static var previews: some View {
        ListHouseView()
    }
}
