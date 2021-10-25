//
//  ListDeviceView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/14/21.
//

import SwiftUI

struct ListDeviceView: View {
    
    var houseId : Int64
    
    @EnvironmentObject var env : Env
    @State private var searchText = ""
    @State var devices : [Device] = []
    
    func refresh() -> Void {
        DeviceManager.shared.getDevices(houseId: houseId) { devices, err in
            if let devices = devices {
                self.devices = devices
            }
        }
    }
    
    
    var results: [Device] {
        if searchText.isEmpty {
            return devices
        } else {
            return devices.filter { $0.name.contains(searchText) || $0.description.contains(searchText) }
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
            refresh()
        }
        .onAppear(perform: {
            refresh()
        })
        .navigationTitle("Devices")
    }
}

struct ListDeviceView_Previews: PreviewProvider {
    static var previews: some View {
///       ListDeviceView()
        ZStack {}
    }
}
