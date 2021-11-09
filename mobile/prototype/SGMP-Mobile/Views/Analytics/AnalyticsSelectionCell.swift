//
//  AnalyticsSelectionCell.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/29/21.
//

import SwiftUI
import Defaults

struct AnalyticsSelectionCell: View {
    @Namespace private var animation
    @State var analytics : DefinedAnalytics
    @State var houseId : UInt64
    @State var showId : Bool = true
    @State var showIcon : Bool = false
    @Default(.showIconInAnalyticsList) var defaultShowIcon
    @Binding var expanded : Bool
    @State var loading : Bool = false
    @State var value : Double? = nil
    
    func refresh () {
        loading = true
        NetworkManager.shared.getAnalyticsAggregated(analyticsName: analytics.name, houseId: houseId, aggregateFunction: .max, startDate: .init(timeIntervalSinceNow: -20), endDate: .now) { value, err in
            DispatchQueue.main.async {
                self.value = value
            }
            self.loading = false
        }
//        NetworkManager.shared.getAnalyticsOneshot(houseId: houseId, startDate: .init(timeIntervalSinceNow: -20), endDate: .now, analyticsName: analytics.name) { frame, err in
//            DispatchQueue.main.async {
//                value = frame?.value
//            }
//            self.loading = false
//        }
    }
    
    var body: some View {
        NavigationLink {
            AnalyticsView(analytics: analytics, houseId: houseId, currentValue: value)
        } label: {
            HStack {
                VStack(alignment: .center, spacing: 8) {
                    if showIcon || defaultShowIcon {
                        Image(systemName: analytics.sfSymbolName)
                            .font(expanded ? .title : .body)
                            .matchedGeometryEffect(id: "view.icon", in: animation)
                    }
                    if showId {
                        Text("\(analytics.analytics_id)")
                            .font(.caption.monospaced())
                            .matchedGeometryEffect(id: "view.id", in: animation)
                    }
                }
                .frame(width: (expanded && (showIcon || defaultShowIcon)) ? 64 : (showIcon || defaultShowIcon || showId) ? 32 : 0, alignment: .center)
                
                VStack(alignment: .leading) {
                    Text("\(analytics.description)")
                        .foregroundColor(expanded ? .init(UIColor.secondaryLabel) : .init(UIColor.label))
                        .font(expanded ? .headline : .headline.bold())
                        .matchedGeometryEffect(id: "view.description", in: animation)
                    if expanded {
                        Text("\(value?.formatted(.number) ?? "-")")
                            .font(.title.bold())
                            .foregroundColor(.init(UIColor.label))
                            .matchedGeometryEffect(id: "view.value", in: animation)
                    }
                }
                .padding(.vertical, expanded ? 8 : 0)
                
                Spacer()
                if loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .matchedGeometryEffect(id: "view.loading", in: animation)
                } else if !expanded {
                    Text("\(value?.formatted(.number) ?? "-")")
                        .font(.footnote.monospaced())
                        .foregroundColor(.init(UIColor.secondaryLabel))
                        .matchedGeometryEffect(id: "view.value", in: animation)
                }
            }
            .contextMenu {
                Label {
                    Text("\(analytics.name)")
                } icon: {
                    Image(systemName: analytics.sfSymbolName)
                }
                Divider()
                Button {
                    refresh()
                } label: {
                    Label {
                        Text("refresh")
                    } icon: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
            }
            .onAppear(perform: {
                if value == nil && !loading {
                    refresh()
                }
            })
            .animation(.easeInOut)
        }
    }
}


//struct AnalyticsSelectionCell_Previews: PreviewProvider {
//    static var previews: some View {
//        AnalyticsSelectionCell()
//    }
//}
