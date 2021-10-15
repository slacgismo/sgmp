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
    @State var now : Date = Date()
    var body: some View {
        List {

            Section {
                NavigationLink {
                    ListDeviceView()
                } label: {
                    Label("Devices", systemImage: "bolt.horizontal.fill")
                }

            } header: {
                Text("Summary for today (refreshed \(now, style: .relative) ago)")
                    .font(.caption.smallCaps())
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
            
            Section {
                DashboardGlanceCellView(title: "Solar Power", iconName: "sun.min", iconColor: .yellow, number: "128 KWH")
                DashboardGlanceCellView(title: "Battery Discharging", iconName: "battery.100", iconColor: .green, number: "27 KW")
                DashboardGlanceCellView(title: "EV Charging", iconName: "car.fill", iconColor: .purple, number: "128 min")
                DashboardGlanceCellView(title: "Loads", iconName: "server.rack", iconColor: .red, number: "76 KW")
                VStack {
                    HStack {
                        Text("Power Consumption")
                            .font(.caption.bold())
                        Spacer()
                    }
                    BarChart()
                            .data([8, 2, 4, 6, 12, 9, 2])
                            .chartStyle(ChartStyle(backgroundColor: .white,
                                                   foregroundColor: ColorGradient(.blue, .purple)))
                            .frame(height: 128)
                }
                
                VStack {
                    HStack {
                        Text("Energy Generation")
                            .font(.caption.bold())
                        Spacer()
                    }
                    LineChart()
                            .data([12, 2, 7, 6, 0, 3, 2])
                            .chartStyle(ChartStyle(backgroundColor: .white,
                                                   foregroundColor: ColorGradient(.blue, .purple)))
                            .frame(height: 128)
                }
            }
        }
        .refreshable {
            now = Date()
        }
        .navigationTitle("Dashboard")
    }
}

struct SummaryTabView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryTabView()
    }
}
