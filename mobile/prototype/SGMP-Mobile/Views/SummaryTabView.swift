//
//  SummaryTabView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/19/21.
//

import SwiftUI

struct SummaryTabView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                Text("Summary for today (\(Date())")
                    .font(.caption)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.horizontal)
                
                DashboardGlanceCellView(title: "Solar Power", iconName: "sun.min", iconColor: .yellow, number: "128 KWH")
                
                DashboardGlanceCellView(title: "Battery Discharging", iconName: "battery.100", iconColor: .green, number: "27 KW")
                
                DashboardGlanceCellView(title: "EV Charging", iconName: "car.fill", iconColor: .purple, number: "128 min")
                
                DashboardGlanceCellView(title: "Loads", iconName: "server.rack", iconColor: .red, number: "76 KW")
            }
            
        }.navigationTitle("Dashboard")
    }
}

struct SummaryTabView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryTabView()
    }
}
