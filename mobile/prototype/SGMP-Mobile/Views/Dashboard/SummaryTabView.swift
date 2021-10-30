//
//  SummaryTabView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/19/21.
//

import SwiftUI
import Toast
import Defaults
import SwiftUICharts

enum SummaryTabPresentView : String, Identifiable
{
    case showAllHouse
    var id: String {
        return self.rawValue
    }
}

struct SummaryTabView: View {
    @EnvironmentObject var env : Env
    @Default(.expandRowsInDashboard) var expandRowsInDashboard
    @State var refreshDate : Date = Date()
    @State var presentViewType : SummaryTabPresentView?
    
    func refresh(showSuccessToast : Bool = false) -> Void {
        env.updateHouses { houses, err in
            refreshDate = Date()
            if let err = err {
                Toast.default(image: .init(systemName: "exclamationmark.arrow.circlepath")!, title: "\(err.localizedDescription)").show()
            } else if showSuccessToast {
                Toast.default(image: .init(systemName: "clock.arrow.circlepath")!, title: "refreshed").show(haptic: .success)
            }
        }
    }
    
    var pinnedAnalyticsNames : [String] = ["solar", "battery", "ev", "load"]
    
    var body: some View {
        ZStack {
            if let house = env.currentDashboardHouse {
                List {
                    Section {
                        ForEach(env.currentDashboardAnalytics.filter({ a in
                            pinnedAnalyticsNames.contains(a.name)
                        })) { analytics in
                            AnalyticsSelectionCell(analytics: analytics, houseId: house.house_id, showId: false, showIcon: true, expanded: $expandRowsInDashboard)
                        }
                        NavigationLink {
                            ListAnalyticsView(houseId: house.house_id)
                        } label: {
                            Label {
                                Text(env.currentDashboardAnalytics.count > 0 ? "see all (\(env.currentDashboardAnalytics.count))" : "see all")
                                    .font(.body.bold())
                            } icon: {
                                Image(systemName: "chart.bar.fill")
                            }
                        }
                    } header: {
                        Text("Analytics")
                    }
                    
                    Section {
                        ForEach(env.currentDashboardDevices.prefix(3)) { device in
                            DeviceSelectionCell(device: device, showId: false, showIcon: true)
                        }
                        NavigationLink {
                            ListDeviceView(houseId: house.house_id)
                        } label: {
                            Label {
                                Text(env.currentDashboardDevices.count > 0 ? "see all (\(env.currentDashboardDevices.count))" : "see all")
                                    .font(.body.bold())
                            } icon: {
                                Image(systemName: "bolt.horizontal.fill")
                            }
                        }

                    } header: {
                        Text("Devices")
                    }
                    
                    
                    Text("- refreshed \(refreshDate, style: .relative) ago -")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.caption.smallCaps())
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .listStyle(PlainListStyle())
                        .listRowBackground(Color.clear)
                }
            } else {
                VStack(alignment: .center) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 120, weight: .medium, design: .default))
                        .foregroundColor(.init(UIColor.quaternaryLabel))
                    Text("No Data")
                        .font(.title.bold())
                        .foregroundColor(.init(UIColor.secondaryLabel))
                    Text("You currently don't have a house selected")
                        .font(.footnote)
                        .foregroundColor(.init(UIColor.tertiaryLabel))
                }
                .padding()
            }
        }
        .sheet(item: $presentViewType, onDismiss: {
            
        }, content: { viewType in
            if viewType == .showAllHouse {
                NavigationView {
                    ChooseHouseView()
                        .toolbar(content: {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    presentViewType = nil
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        })
                }
            }
        })
        .onAppear(perform: {
            if env.currentDashboardHouse == nil {
                refresh()
            }
        })
        .refreshable {
            refresh(showSuccessToast: true)
        }
        .toolbar(content: {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                
                Button {
                    expandRowsInDashboard.toggle()
                } label: {
                    Label {
                        Text(expandRowsInDashboard ? "Shrink" : "Expand")
                    } icon: {
                        Image(systemName: expandRowsInDashboard ? "rectangle.arrowtriangle.2.inward" : "rectangle.arrowtriangle.2.outward")
                    }
                }
                
                if env.houses.count > 1 {
                    Menu {
                        Button("see all (\(env.houses.count))", action: {
                            presentViewType = .showAllHouse
                        })
                        Divider()
                        ForEach(env.houses) { house in
                            Button {
                                env.currentDashboardHouse = house
                                refresh()
                            } label: {
                                Label {
                                    Text("\(house.name)")
                                } icon: {
                                    if (env.currentDashboardHouse?.house_id == house.house_id) {
                                        Image(systemName: "checkmark")
                                    }
                                }

                            }
                        }
                    } label: {
                        Label {
                            Text("House")
                        } icon: {
                            Image(systemName: "house.fill")
                        }
                    }
                }
            }
        })
        .navigationTitle("\(env.currentDashboardHouse?.name ?? "Dashboard")")
    }
}

struct SummaryTabView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryTabView()
    }
}
