//
//  SummaryMetricCardView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/19/21.
//

import SwiftUI

struct SummaryMetricCardView: View {
    
    @Binding var refreshDate : Date
    @State var refreshing : Bool = false
    
    @State var title : String = "Metric Title"
    @State var iconName : String = "barometer"
    @State var iconColor : Color = Color.accentColor
    @State var number : String = "Metric Value"
    
    var numberCallback: ((Double) -> String)?
    var formula : String?
    var aggregateFunction : AggregateFunction?
    
    func refresh() {
        if let formula = formula, let aggregateFunction = aggregateFunction, let numberCallback = numberCallback {
            
            refreshing = true
            DataManager.shared.getAnalyticsAggregated(formula: formula, aggregateFunction: aggregateFunction, startDate: .init(timeIntervalSinceNow: -600), endDate: .now) { value, err in
                if let value = value {
                    number = numberCallback(value)
                }
                refreshing = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Spacer()
            }
            .opacity(refreshing ? 1 : 0)
            
            HStack {
                ZStack {
                    Image(systemName: iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(iconColor)
                }
                .frame(maxHeight: 36)
                .padding()
                .aspectRatio(1, contentMode: .fit)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.headline)
                    Text(number)
                        .font(.title).bold()
                }
                Spacer()
            }
            .opacity(refreshing ? 0 : 1)
        }
        .contextMenu {
            Menu("Data") {
                Text("\(formula ?? "")")
                Text("\(aggregateFunction?.rawValue ?? "")")
            }
            Divider()
            Button {
                refresh()
            } label: {
                Label("Refresh", systemImage: "repeat")
            }
        }
        .onChange(of: refreshDate) { newDate in
            refresh()
        }
    }
}

struct SummaryMetricCardView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryMetricCardView(refreshDate: .constant(.now), numberCallback: {(value) in
            "\(value)"
        })
    }
}
