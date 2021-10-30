//
//  ListAnalyticsView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/29/21.
//

import SwiftUI
import Defaults
import Toast

struct ListAnalyticsView: View {
    
    var houseId : UInt64
    
    @EnvironmentObject var env : Env
    @State private var searchText = ""
    @State var analytics : [DefinedAnalytics] = []
    @Default(.showIconInAnalyticsList) var showIconInAnalyticsList
    @Default(.expandRowsInAnalyticsList) var expandRowsInAnalyticsList
    
    func refresh(showSuccessToast : Bool = false) -> Void {
        let callback : ( ([DefinedAnalytics]?, Error?) -> Void) = { analytics, err in
            DispatchQueue.main.async {
                if let err = err {
                    Toast.default(image: .init(systemName: "exclamationmark.arrow.circlepath")!, title: "\(err.localizedDescription)").show()
                } else if let analytics = analytics {
                    if showSuccessToast { Toast.default(image: .init(systemName: "clock.arrow.circlepath")!, title: "refreshed", subtitle: "\(analytics.count) analytics").show(haptic: .success) }
                    self.analytics = analytics
                }
            }
        }
        if houseId == env.currentDashboardHouse?.house_id {
            env.updateCurrentHouseAnalytics(callback: callback)
        } else {
            NetworkManager.shared.getDefinedAnalytics(houseId: houseId, callback: callback)
        }
    }
    
    
    var results: [DefinedAnalytics] {
        if searchText.isEmpty {
            return analytics
        } else {
            return analytics.filter { $0.name.contains(searchText) || $0.description.contains(searchText) || $0.formula.contains(searchText) }
        }
    }
    
    var body: some View {
        List {
            Section {
                ForEach(results) { a in
                    AnalyticsSelectionCell(analytics: a, houseId: houseId, expanded: $expandRowsInAnalyticsList)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search for analytics")
        .refreshable {
            refresh(showSuccessToast: true)
        }
        .onAppear(perform: {
            refresh()
        })
        .navigationTitle("Analytics")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showIconInAnalyticsList.toggle()
                    } label: {
                        Label {
                            Text("\(showIconInAnalyticsList ? "Hide" : "Show") icons")
                        } icon: {
                            Image(systemName: "sidebar.squares.leading")
                        }
                    }
                    
                    Button {
                        expandRowsInAnalyticsList.toggle()
                    } label: {
                        Label {
                            Text("\(expandRowsInAnalyticsList ? "Shrink" : "Expand") rows")
                        } icon: {
                            Image(systemName: expandRowsInAnalyticsList ? "rectangle.arrowtriangle.2.inward" : "rectangle.arrowtriangle.2.outward")
                        }
                    }
                } label: {
                    Label {
                        Text("More")
                    } icon: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
    }
}
