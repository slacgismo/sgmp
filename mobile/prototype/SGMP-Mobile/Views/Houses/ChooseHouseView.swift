//
//  ChooseHouseView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/25/21.
//

import SwiftUI

struct ChooseHouseView: View {
    @EnvironmentObject var env : Env
    @State private var searchText = ""
    
    func refresh() -> Void {
        HouseManager.shared.refreshEnvHouses { houses, err in
            
        }
    }
    
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
                    HStack {
                        ZStack {
                            if (house.house_id == env.currentDashboardHouse?.house_id) {
                                Image(systemName: "checkmark")
                            }
                        }
                        .frame(width: 32)
                        Text("\(house.name)")
                            .font(.headline.bold())
                        Spacer()
                        Text("\(house.description)")
                            .font(.caption)
                            .foregroundColor(.init(UIColor.secondaryLabel))
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        env.currentDashboardHouse = house
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search for house")
        .refreshable {
            refresh()
        }
        .onAppear(perform: {
            refresh()
        })
        .navigationTitle("Choose House")
    }
}

struct ChooseHouseView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseHouseView()
    }
}
