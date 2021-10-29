//
//  ARDeviceInfoPanel.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/28/21.
//

import SwiftUI

struct ARDeviceInfoPanelView: View {
    @EnvironmentObject var env : Env
    var body: some View {
        if let deviceDetail = env.arTrackingDevice, env.arActivelyTracking {
            NavigationView {
                List {
                    Section {
                        DeviceConfigCellView(title: "Description", content: "\(deviceDetail.description)")
                        DeviceConfigCellView(title: "Type", content: "\(deviceDetail.type)")
                    } header: {
                        Text("Info")
                    }
                    
                    switch deviceDetail.type {
                    case "sonnen":
                        DeviceConfigSonnenView(detail: deviceDetail)
                    case "powerflex":
                        DeviceConfigPowerflexView(detail: deviceDetail)
                    case "egauge":
                        DeviceConfigEgaugeView(detail: deviceDetail)
                    default:
                        DeviceConfigDefaultView(detail: deviceDetail)
                    }
                }
                .navigationTitle("\(deviceDetail.name)")
            }
        } else {
            ZStack {}
        }
    }
}

struct ARDeviceInfoPanelView_Previews: PreviewProvider {
    static var previews: some View {
        ARDeviceInfoPanelView()
    }
}
