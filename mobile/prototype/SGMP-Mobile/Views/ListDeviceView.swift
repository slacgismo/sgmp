//
//  ListDeviceView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/14/21.
//

import SwiftUI

struct ListDeviceView: View {
    
    @EnvironmentObject var env : Env
    @State private var searchText = ""
    
    
    var results: [Device] {
        if searchText.isEmpty {
            return env.devices
        } else {
            return env.devices.filter { $0.name.contains(searchText) || $0.description.contains(searchText) }
        }
    }
    
    var body: some View {
        List {
            Section {
                ForEach(results) { device in
                    NavigationLink {
                        SpecificDeviceView(device: device)
                    } label: {
                        HStack {
                            VStack {
                                HStack {
                                    Text("\(device.device_id)")
                                        .font(.caption.monospaced())
                                    Text("\(device.name)")
                                        .font(.headline.bold())
                                }
                                Text("\(device.type)")
                                    .font(.footnote)
                                    .foregroundColor(.init(UIColor.tertiaryLabel))
                            }
                            Spacer()
                            Text("\(device.description)")
                                .font(.caption)
                                .foregroundColor(.init(UIColor.secondaryLabel))
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search for device")
        .refreshable {
        }
        .onAppear(perform: {
            DeviceManager.shared.refreshEnvDevices { devices, err in
                
            }
        })
        .navigationTitle("Devices")
    }
}

struct ListDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        ListDeviceView()
    }
}
