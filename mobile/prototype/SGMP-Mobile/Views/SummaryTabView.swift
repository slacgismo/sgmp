//
//  SummaryTabView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/19/21.
//

import SwiftUI
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
    @State var refreshDate : Date = Date()
    @State var presentViewType : SummaryTabPresentView?
    
    func refresh() {
        HouseManager.shared.refreshEnvHouses { houses, err in
            if env.currentDashboardHouse == nil {
                env.currentDashboardHouse = houses.first
            }
            refreshDate = Date()
        }
    }
    
    var body: some View {
        ZStack {
            if let house = env.currentDashboardHouse {
                List {
                    Section {
                        NavigationLink {
                            ListDeviceView(houseId: house.house_id)
                        } label: {
                            Label("Devices", systemImage: "bolt.horizontal.fill")
                        }

                    } header: {
                        Text("Summary for today (refreshed \(refreshDate, style: .relative) ago)")
                            .font(.caption.smallCaps())
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                    
                    Section {
                        NavigationLink {
                            
                        } label: {
                            SummaryMetricCardView(refreshDate: $refreshDate, title: "Solar Power", iconName: "sun.min", iconColor: .yellow, number: "- Wh", numberCallback: { value in String(format: "%.5f Wh", value)}, formula: "egauge.A.Solar", aggregateFunction: .avg)
                        }
                        SummaryMetricCardView(refreshDate: $refreshDate, title: "Battery", iconName: "battery.100", iconColor: .green, number: "- kWh", numberCallback: { value in String(format: "%.5f kWh", value) }, formula: "sonnen.status.Pac_total_W/1000", aggregateFunction: .avg)
                        SummaryMetricCardView(refreshDate: $refreshDate, title: "EV", iconName: "car.fill", iconColor: .purple, number: "- Wh", numberCallback: { value in String(format: "%.5f Wh", value) }, formula: "-egauge.A.EV", aggregateFunction: .avg)
                        SummaryMetricCardView(refreshDate: $refreshDate, title: "Loads", iconName: "server.rack", iconColor: .red, number: "0 kW", numberCallback: { value in String(format: "%.5f kW", value) }, formula: "-egauge.A.SubPanel", aggregateFunction: .avg)
                    }
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
            refresh()
        })
        .refreshable {
            refresh()
        }
        .toolbar(content: {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu("\(env.currentDashboardHouse?.name ?? "Choose House")") {
                    Button("See all", action: {
                        presentViewType = .showAllHouse
                    })
                    Divider()
                    ForEach(env.houses) { house in
                        Button {
                            env.currentDashboardHouse = house
                            refreshDate = Date()
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
                }
            }
        })
        .navigationTitle("Dashboard")
    }
}

struct SummaryTabView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryTabView()
    }
}
