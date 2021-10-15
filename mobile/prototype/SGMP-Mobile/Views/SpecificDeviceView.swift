//
//  SpecificDeviceView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/14/21.
//

import SwiftUI

struct SpecificDeviceView: View {
    var device : Device
    @State var loadingDeviceDetail : Bool = false
    @State var deviceDetail : DeviceDetail?
    
    func loadDeviceDetail() {
        self.loadingDeviceDetail = true
        DeviceManager.shared.getDeviceDetail(deviceId: device.device_id) { detail, err in
            if let detail = detail {
                deviceDetail = detail
            } else if let err = err {
                print(err)
            }
            self.loadingDeviceDetail = false
        }
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text("Device ID")
                        .font(.footnote.smallCaps())
                        .foregroundColor(.init(UIColor.secondaryLabel))
                    Text("\(device.device_id)")
                        .font(.subheadline)
                }
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.footnote.smallCaps())
                        .foregroundColor(.init(UIColor.secondaryLabel))
                    Text("\(deviceDetail?.description ?? device.description)")
                        .font(.subheadline)
                }
                VStack(alignment: .leading) {
                    Text("Type")
                        .font(.footnote.smallCaps())
                        .foregroundColor(.init(UIColor.secondaryLabel))
                    Text("\(deviceDetail?.type ?? device.type)")
                        .font(.subheadline)
                }
                if let deviceDetail = deviceDetail {
                    VStack(alignment: .leading) {
                        Text("IP")
                            .font(.footnote.smallCaps())
                            .foregroundColor(.init(UIColor.secondaryLabel))
                        Text("\(deviceDetail.config.ip)")
                            .font(.subheadline.monospaced())
                            .textSelection(.enabled)
                    }
                }
            } header: {
                Text("Info")
            }
            
            if loadingDeviceDetail {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let deviceDetail = deviceDetail {
                if let keys = deviceDetail.config.keys, !keys.isEmpty {
                    Section {
                        ForEach(keys, id: \.self) { key in
                            ExpandableView(title: {
                                Text("\(key)")
                                    .font(.body.monospaced())
                            }, expandable: {
                                NavigationLink {
                                    SpecificDeviceKeyView(key: key, device: device)
                                } label: {
                                    SpecificDeviceKeyChartSelfLoadView(device: device, key: key, date: (Date(timeIntervalSinceNow: -300), Date()))
                                        .allowsHitTesting(false)
                                        .frame(height: 72)
                                }
                            }).frame(maxHeight: .infinity)
                        }
                    } header: {
                        Text("Keys")
                    }
                }
            } else {
                Button("Load Config") {
                    loadDeviceDetail()
                }
            }
        }
        .onAppear(perform: {
            loadDeviceDetail()
        })
        .refreshable {
            loadDeviceDetail()
        }
        .navigationTitle("\(deviceDetail?.name ?? device.name)")
        .animation(.easeInOut)
    }
}

struct SpecificDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        SpecificDeviceView(device: Device(device_id: 1, name: "Sonnon", description: "Test", type: "sonnon"))
    }
}
