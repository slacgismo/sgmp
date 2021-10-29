//
//  SummaryTabView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/19/21.
//

import SwiftUI
import Toast
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
    
    func refresh(showSuccessToast : Bool = false) -> Void {
        env.updateHouses { houses, err in
            refreshDate = Date()
            if let err = err {
                Toast.default(image: .init(systemName: "exclamationmark.arrow.circlepath")!, title: "\(err.localizedDescription)").show()
            } else if showSuccessToast {
                Toast.default(image: .init(systemName: "clock.arrow.circlepath")!, title: "refreshed").show(haptic: .success)
            }
//            env.updateCurrentHouseDevices()
        }
    }
    
    var body: some View {
        ZStack {
            if let house = env.currentDashboardHouse {
                List {
                    Text("Summary for \(house.name) (refreshed \(refreshDate, style: .relative) ago)")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.caption.smallCaps())
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    
                    Section {
                        NavigationLink {
//                            DeviceView(
                        } label: {
                            SummaryMetricCardView(refreshDate: $refreshDate, title: "Solar Power", iconName: "sun.min", iconColor: .yellow, number: "- Wh", numberCallback: { value in String(format: "%.5f Wh", value)}, formula: "egauge.A.Solar", aggregateFunction: .avg)
                        }
                        SummaryMetricCardView(refreshDate: $refreshDate, title: "Battery", iconName: "battery.100", iconColor: .green, number: "- kWh", numberCallback: { value in String(format: "%.5f kWh", value) }, formula: "sonnen.status.Pac_total_W/1000", aggregateFunction: .avg)
                        SummaryMetricCardView(refreshDate: $refreshDate, title: "EV", iconName: "car.fill", iconColor: .purple, number: "- Wh", numberCallback: { value in String(format: "%.5f Wh", value) }, formula: "-egauge.A.EV", aggregateFunction: .avg)
                        SummaryMetricCardView(refreshDate: $refreshDate, title: "Loads", iconName: "server.rack", iconColor: .red, number: "- kW", numberCallback: { value in String(format: "%.5f kW", value) }, formula: "-egauge.A.SubPanel", aggregateFunction: .avg)
                    } header: {
                        Text("Pinned")
                    }
                    
                    Section {
                        if env.currentDashboardDevices.count > 0 {
                            ForEach(env.currentDashboardDevices.prefix(3)) { device in 
                                DeviceSelectionCell(device: device)
                            }
                            NavigationLink {
                                ListDeviceView(houseId: house.house_id)
                            } label: {
                                Label("See all", systemImage: "bolt.horizontal.fill")
                            }
                        } else {
                            NavigationLink {
                                ListDeviceView(houseId: house.house_id)
                            } label: {
                                Label("Devices", systemImage: "bolt.horizontal.fill")
                            }
                        }

                    } header: {
                        Text("Devices")
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
            refresh(showSuccessToast: true)
        }
        .toolbar(content: {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu("\(env.currentDashboardHouse?.name ?? "Choose House")") {
                    if (env.houses.count > 0) {
                        Button("See all", action: {
                            presentViewType = .showAllHouse
                        })
                        Divider()
                    } else {
                        Button("Refresh", action: {
                            refresh()
                        })
                        Divider()
                    }
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
