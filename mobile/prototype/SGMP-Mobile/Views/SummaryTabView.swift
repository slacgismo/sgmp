//
//  SummaryTabView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/19/21.
//

import SwiftUI
import SwiftUICharts

struct SummaryTabView: View {
    
    @State private var favoriteColor = 0
    @State var refreshDate : Date = Date()
    var body: some View {
        List {

            Section {
                NavigationLink {
                    ListHouseView()
                } label: {
                    Label("Houses", systemImage: "house.fill")
                }
                
                NavigationLink {
                    ListDeviceView()
                } label: {
                    Label("Devices", systemImage: "bolt.horizontal.fill")
                }

            } header: {
                Text("Summary for today (refreshed \(refreshDate, style: .relative) ago)")
                    .font(.caption.smallCaps())
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
            
            Section {
                SummaryMetricCardView(refreshDate: $refreshDate, title: "Solar Power", iconName: "sun.min", iconColor: .yellow, number: "- Wh", numberCallback: { value in String(format: "%.5f Wh", value)}, formula: "egauge.A.Solar", aggregateFunction: .avg)
                SummaryMetricCardView(refreshDate: $refreshDate, title: "Battery", iconName: "battery.100", iconColor: .green, number: "- kWh", numberCallback: { value in String(format: "%.5f kWh", value) }, formula: "sonnen.status.Pac_total_W/1000", aggregateFunction: .avg)
                SummaryMetricCardView(refreshDate: $refreshDate, title: "EV", iconName: "car.fill", iconColor: .purple, number: "- Wh", numberCallback: { value in String(format: "%.5f Wh", value) }, formula: "-egauge.A.EV", aggregateFunction: .avg)
                SummaryMetricCardView(refreshDate: $refreshDate, title: "Loads", iconName: "server.rack", iconColor: .red, number: "76 KW")
            }
        }
        .onAppear(perform: {
            refreshDate = Date()
        })
        .refreshable {
            refreshDate = Date()
        }
        .navigationTitle("Dashboard")
    }
}

struct SummaryTabView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryTabView()
    }
}
