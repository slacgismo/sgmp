//
//  AnalyticsView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/31/21.
//

import SwiftUI

struct AnalyticsView: View {
    
    @Namespace private var animation
    @State var analytics : DefinedAnalytics
    @State var houseId : UInt64
    @State var currentValue : Double? = nil
    @State var loading : Bool = false
    
    func refresh () {
        loading = true
        NetworkManager.shared.getAnalyticsOneshot(houseId: houseId, startDate: .init(timeIntervalSinceNow: -3600), endDate: .now, analyticsName: analytics.name) { frame, err in
            DispatchQueue.main.async {
                currentValue = frame?.value
            }
            self.loading = false
        }
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text("Current Value")
                        .foregroundColor(.init(UIColor.secondaryLabel))
                        .font(.headline)
                        .matchedGeometryEffect(id: "view.current", in: animation)
                    if loading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .matchedGeometryEffect(id: "view.loading", in: animation)
                    } else {
                        Text("\(currentValue?.formatted(.number) ?? "-")")
                            .font(.title.bold())
                            .foregroundColor(.init(UIColor.label))
                            .matchedGeometryEffect(id: "view.currentValue", in: animation)
                    }
                }
                
                TitleDescCellView(title: "ID", content: "\(analytics.analytics_id)")
                TitleDescCellView(title: "Name", content: "\(analytics.name)")
                TitleDescCellView(title: "Formula", content: "\(analytics.formula)")
                TitleDescCellView(title: "Continuous Aggregation", content: "\(analytics.continuous_aggregation)")
            } header: {
                Text("Stats")
            }
            
            Section {
                AnalyticsChartView(analytics: analytics, houseId: houseId)
            } header: {
                Text("History")
            }
        }
        .animation(.easeInOut)
        .onAppear(perform: {
            if currentValue == nil && !loading {
                refresh()
            }
        })
        .refreshable {
            refresh()
        }
        .navigationTitle("\(analytics.description)")
        .toolbar {
            ToolbarItem {
                Button {
                    let text = "\(analytics.description) (\(analytics.formula)) now at \(currentValue?.formatted(.number) ?? "-")"
                    let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                    UIApplication.shared.windows.first?.rootViewController!.present(activityController, animated: true, completion: nil)
                } label: {
                    Label {
                        Text("Share chart")
                    } icon: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

//struct AnalyticsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AnalyticsView()
//    }
//}
